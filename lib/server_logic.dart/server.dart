import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:extrack/home.dart';

Future<void> postUser(String name , String age) async{
  final url = Uri.parse("http://127.0.0.1:8000/signup");
  final response = await http.post(
    url,
    headers:{
      'Content-type': 'application/json'
    },
    body: jsonEncode({
      'username' : name,
      'age' : age,
    }),
  );
  if(response.statusCode == 200 || response.statusCode == 201){
    print("user posted successfully ${response.body}");
  }
  else{
    print("user not posted successfully ");
    print(response.body);
  }
}
// void main() {
//   postUser("Saravanesh", "21");
// }

Future<void> postaddexpenses(String category, int amount) async{
  try{
  final url = Uri.parse(uri);
  final response = await http.post(
    url,
    headers:{
      'Content-type': 'application/json'
    },
    body: jsonEncode({
      'category': category,
      'amount': amount,
    }),
  );
  if(response.statusCode == 200 || response.statusCode == 201){
    print("user add expense successfully");
  }
  else{
    print("user not add expense");
  }
  }
  catch(e){
    print("error occured");
  }
 
}