import 'dart:convert';
import 'dart:convert' as response;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

//New bracnh created name : frontend
class DatabaseHelper {
  static Database? _database;
  static const String _tablename1 = 'expenses';
  static const String _tablename2 = 'users';
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
}

Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'expenses.db');
  return await openDatabase(
    path,
    version: 2,
    onCreate: _onCreate,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE expenses ADD COLUMN date TEXT');
        print("Database upgraded to version $newVersion");
      }
    },
  );
}

Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
  CREATE TABLE ${DatabaseHelper._tablename1}(
    id numeric ,
    category TEXT,
    amount REAL,
    date TEXT,
    receipt TEXT,
    imagePath TEXT
  )
  ''');
  await db.execute('''
  CREATE TABLE ${DatabaseHelper._tablename2}(
    id INTEGER ,
    username TEXT
  )
  ''');
}

Future<int> insertuser(Map<String, dynamic> user) async {
  final db = await DatabaseHelper().database;
  final storage = FlutterSecureStorage();

  print("Inserting user into local database: $user");
  await storage.write(key: 'userid', value: user['id'].toString());
  print("User ID saved in secure storage: ${user['id']}");

  return await db.insert(DatabaseHelper._tablename2, user);
}

Future<int> addExpenses(Map<String, dynamic> expense) async {
  final db = await DatabaseHelper().database;
  print("Inserting expense into local database: $expense");
  return await db.insert(DatabaseHelper._tablename1, expense);
}

Future<List<Map<String, dynamic>>> getExpenses() async {
  final db = await DatabaseHelper().database;
  final List<Map<String, dynamic>> result = await db.query(
    DatabaseHelper._tablename1,
  );
  print("Fetched expenses from local database: $result");
  return result;
}

Future<void> postUser(String name, String age) async {
  final url = Uri.parse("http://10.0.2.2:8000/signup");
  final response = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: jsonEncode({'username': name, 'age': age}),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    print("user posted successfully ${response.body}");
  } else {
    print("user not posted successfully ");
    print(response.body);
  }
}
// void main() {
//   postUser("Saravanesh", "21");
// }

Future<void> adduser(String email) async {
  try {
    final url = Uri.parse("http://10.0.2.2:8000/signup");
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("sign up Successfully");
    } else {
      print("not signup ");
    }
  } catch (e) {
    print("error occured $e");
  }
}

Future<void> otpverify(
  String email,
  String password,
  int otp,
  VoidCallback onSuccess,
) async {
  try {
    final url = Uri.parse("http://10.0.2.2:8000/otp");
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'otp': otp}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("otp verify Successfully");
      onSuccess();
    } else {
      print("otp not verify ");
    }
  } catch (e) {
    print("error occured $e");
  }
}

Future<void> getuser(String email, String password) async {
  try {
    final url = Uri.parse("http://10.0.2.2:8000/login");
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("sign in Successfully");
      var jsonresponse = json.decode(response.body);
      print(jsonresponse["session_token"]);
      final jwt = JWT.decode(jsonresponse["session_token"]);
      print("Decoded JWT payload: ${jwt.payload}");
      final email = jwt.payload['email'];
      print("Email from JWT payload: $email");
      final id = jwt.payload['sub'];
      insertuser({'id': id, 'username': email});
      print(jsonresponse["username"]);
      await savetoken(jsonresponse["session_token"], jsonresponse["username"]);
    } else {
      print("not signin ");
    }
  } catch (e) {
    print("error occured $e");
  }
}

Future<void> resetpassword(String email) async {
  try {
    final url = Uri.parse("http://10.0.2.2:8000/forget_password");
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("reset password link sent Successfully");
    } else {
      print("reset password link not sent ");
    }
  } catch (e) {
    print("error occured $e");
  }
}

Future<void> postexpenses(
  String category,
  String amount,
  String receipt,
  String filepath,
) async {
  print("inside post expenses function");
  print(filepath);
  print(receipt);
  print(amount);
  print(category);
  String? token = await gettoken();
  print(token);
  if (token == null) {
    print("No token found. user mat no be logged in or token is expired");
    return;
  }
  try {
    var url = Uri.parse("http://10.0.2.2:8000/add");
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    });
    request.fields['category'] = category;
    request.fields['amount'] = amount.toString();
    request.fields['receipt'] = receipt;
    request.files.add(await http.MultipartFile.fromPath('image', filepath));
    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Expense added successfully");
    } else {
      print("Expense adding failed");
    }
  } catch (e) {
    print("Error Adding expense: $e");
  }
}

Future<Map<String, dynamic>?> postimageinn8n(String filepath) async {
  try {
    print("Posting image to inn8n workflow");
    var url = Uri.parse(
      "https://saroo.app.n8n.cloud/webhook/b999aaa2-0b88-4d03-9fc8-0766de85835f",
    );
    var request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        filepath,
        filename: filepath.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      var innerText = jsonResponse["content"]["parts"][0]["text"];

      innerText = innerText.replaceAll(RegExp(r'```json|```'), '').trim();

      var actualData = json.decode(innerText);
      print("updated data from inn8n:");

      print("Category: ${actualData["category"]}");
      print("Amount: ${actualData["amount"]}");
      return actualData;
    } else {
      print("Image posting to inn8n failed");
    }
  } catch (e) {
    print("Error posting image to inn8n: $e");
  }
}

Future<void> google_auth(String authCode) async {
  try {
    final url = Uri.parse("http://10.0.2.2:8000/glogin");
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'AuthCode': authCode}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Google signin Successfull");
      var jsonresponse = json.decode(response.body);
      print(jsonresponse["session_token"]);
      print(jsonresponse["username"]);
      await savetoken(jsonresponse["session_token"], jsonresponse["username"]);
    } else {
      print("not signup ");
    }
  } catch (e) {
    print("error occured $e");
  }
}

Future<void> savetoken(String token, String username) async {
  final storage = FlutterSecureStorage();
  final expiryDate = DateTime.now().add(const Duration(days: 7));
  await storage.write(key: 'session_token', value: token);
  await storage.write(key: 'username', value: username);
  await storage.write(
    key: 'session_expiry',
    value: expiryDate.toIso8601String(),
  );
}

Future<String?> gettoken() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'session_token');
  final expiryDateString = await storage.read(key: 'session_expiry');

  if (token == null || expiryDateString == null) {
    return null;
  }

  final expiryDate = DateTime.tryParse(expiryDateString);

  if (expiryDate == null || expiryDate.isBefore(DateTime.now())) {
    print("Got token but it's expired on Device !");
    return null;
  }
  return token;
}

Future<void> addincome(
  String salaryType,
  int salaryAmount,
  String salaryDate,
) async {
  try {
    String? token = await gettoken();
    print(token);
    print("inside add income function");
    print(salaryType);
    print(salaryAmount);
    print(salaryDate);
    if (token == null) {
      print("No token found. user mat no be logged in or token is expired");
      return;
    }

    final url = Uri.parse("http://10.0.2.2:8000/income");
    final response = await http.post(
      url,
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'salaryType': salaryType,
        'salaryAmount': salaryAmount,
        'salaryDate': salaryDate,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Income added Successfully");
      saveincome(salaryAmount.toString());
      saveincomedata(salaryType, salaryDate);
    } else {
      print("income not added");
    }
  } catch (e) {
    print("error occured $e");
  }
}

Future<void> saveincomedata(String salaryType, String salaryDate) async {
  final storage = FlutterSecureStorage();
  final String? user = await storage.read(key: 'username');
  await storage.write(key: 'salaryType$user', value: salaryType);
  await storage.write(key: 'salaryDate$user', value: salaryDate);
  print(salaryType);
  print(salaryDate);
}

Future<void> saveincome(String income) async {
  final storage = FlutterSecureStorage();
  final String? user = await storage.read(key: 'username');
  final expiryincome = DateTime.now().add(const Duration(days: 30));
  await storage.write(key: 'income$user', value: income);
  await storage.write(
    key: 'income_expiry',
    value: expiryincome.toIso8601String(),
  );

  print("Income saved successfully  in secure storage");
}

Future<String?> getincome() async {
  final storage = FlutterSecureStorage();
  final String? user = await storage.read(key: 'username');
  final income = await storage.read(key: 'income$user');
  final expiryincomeString = await storage.read(key: 'income_expiry');
  if (income == null || expiryincomeString == null) {
    return null;
  }
  // final expiryincome = DateTime.tryParse(expiryincomeString);
  return income;
}

Future<void> logout() async {
  final storage = FlutterSecureStorage();
  String? jwt = await storage.read(key: 'session_token');
  if (jwt == null) {
    print("No jwt found, so cannot logout");
    return;
  }
  await storage.delete(key: 'session_token');
  await storage.delete(key: 'expense_with_expiry_$jwt');
  print("User logged out successfully");
}
