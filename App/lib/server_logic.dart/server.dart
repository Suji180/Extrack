import 'dart:convert';
import 'dart:convert' as response;
import 'package:flutter/material.dart';
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
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:math';
import 'package:path/path.dart';

late StreamSubscription subscription;

//New bracnh created name : frontend
class DatabaseHelper {
  static Database? _database;
  static const String _tablename1 = 'expenses';
  static const String _tablename2 = 'users';
  static const String _tablename3 = 'income';
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
  _pk INTEGER PRIMARY KEY AUTOINCREMENT,
    id TEXT ,
    category TEXT,
    amount REAL,
    date TEXT ,
    receipt TEXT DEFAULT null,
    imagePath TEXT DEFAULT null,
    status TEXT DEFAULT 'pending' 
  )
  ''');
  await db.execute('''
  CREATE TABLE ${DatabaseHelper._tablename3}(
    id TEXT ,
    salaryType TEXT,
    salaryAmount INTEGER DEFAULT null,
    salaryDate TEXT,
    status TEXT DEFAULT 'pending'
    )
  ''');
  print("✅ Income table created!");
  await db.execute('''
  CREATE TABLE ${DatabaseHelper._tablename2}(
    id INTEGER ,
    username TEXT
  )
  ''');
}

Future<int> saveIncome(Map<String, dynamic> income) async {
  final db = await DatabaseHelper().database;
  print("inserting income into local database: $income");
  return await db.insert(DatabaseHelper._tablename3, income);
}

Future<List<Map<String, dynamic>>> getIncome() async {
  final db = await DatabaseHelper().database;
  final List<Map<String, dynamic>> result = await db.query(
    DatabaseHelper._tablename3,
  );

  print("Fetched income from local database: $result");
  return result;
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
  final storage = FlutterSecureStorage();
  final String? userid = await storage.read(key: 'userid');
  if (result.isEmpty) {
    print("No expenses found in local database.");
    return [];
  }

  final userExpenses = result
      .where((item) => item['id'] != null && item['id'].toString() == userid)
      .toList();

  if (userExpenses.isNotEmpty) {
    print("Fetched expenses for user $userid: $userExpenses");
    return userExpenses;
  } else {
    print("No expenses found for user $userid.");
    return [];
  }
}

void connectionlistener() async {
  final connectivity = Connectivity();
  print("Setting up connectivity listener...");

  subscription = connectivity.onConnectivityChanged.listen((
    List<ConnectivityResult> results,
  ) {
    final result = results.first;
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet) {
      print("Device is online. Syncing local data with server...");
      postlocaldata();
      postincomelocaldata();
    } else {
      print("Device is offline.");
    }
  });
}

Future<void> updatestatus(
  Database db,
  String id,
  String category,
  double amount,
) async {
  print("the update status data is $db,$id,$category,$amount");
  var updated = await db.update(
    DatabaseHelper._tablename1,
    {'status': 'synced'},
    where: 'id = ? AND category = ? AND amount = ?',
    whereArgs: [id, category, amount],
  );
  print("the update is $updated");
  print("Expense with id $id marked as synced in local database.");
}

Future<void> updateincomestatus(Database db, String id) async {
  await db.update(
    DatabaseHelper._tablename3,
    {'status': 'synced'},
    where: 'id = ?',
    whereArgs: [id],
  );
  print("income with $id marked as synced in local database");
}

Future<List<Map<String, dynamic>>> formattedExpenses() async {
  final expenses = await getExpenses();
  List<Map<String, dynamic>> pendingExpenses = expenses
      .where((exp) => exp['status'] == 'pending')
      .map((expense) {
        return {
          'local_id': expense['id'].toString(),
          'date': expense['date'].toString(),
          'category': expense['category'],
          'amount': expense['amount'],
        };
      })
      .toList();

  return pendingExpenses;
}

Future<List<Map<String, dynamic>>> formattedIncome() async {
  final incomes = await getIncome();
  List<Map<String, dynamic>> pendingincomes = incomes
      .where((exp) => exp['status'] == 'pending')
      .map((income) {
        return {
          'user_id': income['id'].toString(),
          'salaryType': income['salaryType'].toString(),
          'salaryAmount': income['salaryAmount'].toString(),
          'salaryDate': income['salaryDate'].toString(),
        };
      })
      .toList();
  print("pending incomes is $pendingincomes");
  return pendingincomes;
}

Future<void> postincomelocaldata() async {
  final incomes = await formattedIncome();
  print("after format income $incomes");
  if (incomes.isEmpty) {
    print("No pending incomes to sync.");
    return;
  }
  final storage = FlutterSecureStorage();
  final String? token = await gettoken();
  if (token == null) {
    print("no token found in local storage");
    return;
  }

  final user = await storage.read(key: "userid");
  for (final income in incomes) {
    if (user == income['user_id']) {
      try {
        final url = Uri.parse("http://10.0.2.2:8000/sync_income");
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-type': 'application/json',
          },
          body: jsonEncode(income),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          print("it successfully send the data in db");
          final db = await DatabaseHelper().database;
          await updateincomestatus(db, income['user_id']);
        } else {
          print("Failed to sync income");
        }
      } catch (e) {
        print("Error syncing local data: $e");
      }
    }
  }
}

Future<void> postlocaldata() async {
  final expense = await formattedExpenses();
  if (expense.isEmpty) {
    print("no expense is pending");
    return;
  }
  print("Posting local data to server: $expense");

  final String? token = await gettoken();
  if (token == null) {
    print("No valid token found. Cannot sync data.");
    return;
  }
  try {
    final url = Uri.parse("http://10.0.2.2:8000/sync_data");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(expense),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Expense synced successfully: ${expense}");
      final db = await DatabaseHelper().database;
      for (var exp in expense) {
        await updatestatus(db, exp['local_id'], exp['category'], exp['amount']);
      }
    } else {
      print("Failed to sync expense: ${expense}");
    }
  } catch (e) {
    print("Error syncing local data: $e");
  }
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

int generaterandomnumber() {
  final random = Random();
  return 10000000 + random.nextInt(90000000);
}

const storage = FlutterSecureStorage();
Future<String> getOrCreateDeviceId() async {
  String? deviceId = await storage.read(key: 'device_id');
  if (deviceId == null) {
    final randomId = generaterandomnumber().toString();
    await storage.write(key: 'device_id', value: randomId);
    deviceId = randomId;
    print("successfully created device id $deviceId. it is fresh account ");
  }
  print("successfully created device id $deviceId. it is no fresh account ");

  return deviceId;
}

Future<bool> getuser(String email, String password) async {
  try {
    final Device_id = await getOrCreateDeviceId();
    print(Device_id);
    final url = Uri.parse("http://10.0.2.2:8000/login");
    final response = await http.post(
      url,
      headers: {
        'Content-type': 'application/json',
        'Device_id': 'Bearer $Device_id',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
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
      print(jsonresponse['status']);
      if (jsonresponse['status']) {
        final result = await getfullbackup();
        return result;
      }
      return true;
    } else {
      print("not signin ");
      return false;
    }
  } catch (e) {
    print("error occured $e");
    return false;
  }
}

Future<bool> getfullbackup() async {
  try {
    final String? token = await gettoken();
    final db = await DatabaseHelper().database;
    if (token == null) {
      print("No valid token found. Cannot sync data.");
    }
    final url = Uri.parse("http://10.0.2.2:8000/full_sync");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("backup $data");
      print(data['Income']);
      final income = data['Income'];
      print("the income is $income");
      await saveIncome(data['Income']);
      await updateincomestatus(db, income['id']);

      print("the expense is ${data['Expenses']}");
      final expenses = data['Expenses'];
      if (expenses is List) {
        for (var expense in expenses) {
          final id = expense['id'];
          final category = expense['category'];
          final amount = expense['amount'];
          print("update status in sync function is $id , $category, $amount");
          await addExpenses(Map<String, dynamic>.from(expense));
          await updatestatus(
            db,
            expense['id'],
            expense['category'],
            expense['amount'],
          );
        }
        print("backup process is successfully");

        return true;
      } else if (response.statusCode == 404) {
        return true;
      } else {
        print("no it is list");
        return false;
      }
    } else {
      print("no backup");
      return false;
    }
  } catch (e) {
    print("the error is $e");
    return false;
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

Future<void> passwordresetotp(String email, int otp) async {
  print("inside password reset otp function");
  print(email);
  print(otp);
  try {
    final url = Uri.parse("http://10.0.2.2:8000/submit_otp");
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      print("otp verify Successfully");
    } else {
      print("password not reset ");
    }
  } catch (e) {
    print("error occured $e");
  }
}

Future<void> passwordresetconfirm(
  String email,
  int otp,
  String newpasswsord,
) async {
  print("inside password reset confirm function");
  print(email);
  print(newpasswsord);
  print(otp);
  try {
    final url = Uri.parse("http://10.0.2.2:8000/set_new_pass");
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp, 'password': newpasswsord}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("password reset successfully");
    } else {
      print("password not reset ");
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
  final db = await DatabaseHelper().database;
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
    request.fields['amount'] = amount;
    request.fields['receipt'] = receipt;
    request.files.add(await http.MultipartFile.fromPath('image', filepath));
    var response = await request.send();
    var body = await response.stream.bytesToString();
    var data = jsonDecode(body);
    print(data);
    final expense = data['Added'];
    print("the is post expense output is $expense");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Expense added successfully");
      await updatestatus(
        db,
        expense['id'],
        expense['category'],
        expense['amount'],
      );
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
      "https://app.selfmade.social/webhook/b999aaa2-0b88-4d03-9fc8-0766de85835f",
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
    final db = await DatabaseHelper().database;

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
      // saveincome(salaryAmount.toString());
      // saveincomedata(salaryType, salaryDate);
      final data = jsonDecode(response.body);
      final income = data['income_id'];
      await updateincomestatus(db, income['id']);
    } else {
      print("income not added");
    }
  } catch (e) {
    print("error occured $e");
  }
}

// Future<void> saveincomedata(String salaryType, String salaryDate) async {
//   final storage = FlutterSecureStorage();
//   final String? user = await storage.read(key: 'username');
//   await storage.write(key: 'salaryType$user', value: salaryType);
//   await storage.write(key: 'salaryDate$user', value: salaryDate);
//   print(salaryType);
//   print(salaryDate);
// }

// Future<void> saveincome(String income) async {
//   final storage = FlutterSecureStorage();
//   final String? user = await storage.read(key: 'username');
//   final expiryincome = DateTime.now().add(const Duration(days: 30));
//   await storage.write(key: 'income$user', value: income);
//   await storage.write(
//     key: 'income_expiry',
//     value: expiryincome.toIso8601String(),
//   );

//   print("Income saved successfully  in secure storage");
// }

// Future<String?> getincome() async {
//   final storage = FlutterSecureStorage();
//   final String? user = await storage.read(key: 'username');
//   final income = await storage.read(key: 'income$user');
//   final expiryincomeString = await storage.read(key: 'income_expiry');
//   if (income == null || expiryincomeString == null) {
//     return null;
//   }
//   // final expiryincome = DateTime.tryParse(expiryincomeString);
//   return income;
// }

Future<String> getincome() async {
  final storage = FlutterSecureStorage();
  final String? user = await storage.read(key: "userid");
  final income = await getIncome();
  print("");

  print("Income from local database: $income");
  if (income.isEmpty) {
    print("no income found in local database");
    return "null";
  }
  for (var entry in income) {
    if (entry['id'].toString() == user) {
      print("it sync account salary");

      print(entry['salaryAmount'].toString());
      return entry['salaryAmount'].toString();
      return entry['salaryType'].toString();
    }
  }
  return "null";
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
