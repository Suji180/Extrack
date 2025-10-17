import 'dart:convert';
import 'dart:convert' as response;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//New bracnh created name : frontend

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

Future<void> adduser(String email, String password) async {
  try {
    final url = Uri.parse("http://10.0.2.2:8000/signup");
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
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
      print(jsonresponse["username"]);
      await savetoken(jsonresponse["session_token"], jsonresponse["username"]);
    } else {
      print("not signin ");
    }
  } catch (e) {
    print("error occured $e");
  }
}

Future<void> postexpenses(
  String category,
  int amount,
  String receipt,
  String filepath,
) async {
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
      'Content-Type':
          'multipart/form-data', 
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
    } else {
      print("income not added");
    }
  } catch (e) {
    print("error occured $e");
  }
}

Future<void> saveincome(String income) async{
  final storage = FlutterSecureStorage();
  final expiryincome = DateTime.now().add(const Duration(days: 30));
  await storage.write(key: 'income', value: income);
  await storage.write(key:'income_expiry', value: expiryincome.toIso8601String());
  print("Income saved successfully  in secure storage");
}
Future<String?> getincome() async{
  final storage = FlutterSecureStorage();
  final income = await storage.read(key: 'income');
  final expiryincomeString = await storage.read(key: 'income_expiry');
  if(income == null || expiryincomeString == null){
    return null;
  }
  // final expiryincome = DateTime.tryParse(expiryincomeString);
  return income;
}
Future<void> logout()async{
  final storage = FlutterSecureStorage();
  String? jwt = await storage.read(key: 'session_token');
  if(jwt == null){
    print("No jwt found, so cannot logout");
    return;
  }
  await storage.delete(key: 'session_token');
  await storage.delete(key: 'expense_with_expiry_$jwt');
  print("User logged out successfully");
}
