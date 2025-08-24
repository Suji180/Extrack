import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';



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
  final url = Uri.parse("http://127.0.0.1:8000/add");
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
Future<void>adduser(String email,String password)async{
  try{
    final url = Uri.parse("http://127.0.0.1:8000/signup");
    final response = await http.post(
      url,
      headers:{
        'Content-type': 'application/json'
      },
      body: jsonEncode({
        'email' : email,
        'password' : password,
        
      })
    );
    if(response.statusCode == 200 || response.statusCode == 201){
      print("sign up Successfully");
    }
    else{
      print("not signup ");
    }
  }
  catch(e){
    print("error occured $e");
  }
}
Future<void>getuser(String username,int password)async{
  try{
    final url = Uri.parse("");
    final response = await http.post(
      url,
      headers:{
        'Content-type': 'application/json'
      },
      body: jsonEncode({
        'username' : username,
        'password' : password,
      
      })
    );
    if(response.statusCode == 200 || response.statusCode == 201){
      print("sign up Successfully");
    }
    else{
      print("not signup ");
    }
  }
  catch(e){
    print("error occured $e");
  }
}

Future<void> postimage(String filepath) async{
  try{
    var url = Uri.parse("");
    var request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath('image', filepath,)
    );
    var response = await request.send();
    if(response.statusCode == 200 || response.statusCode == 201){
      print("successfully upload image");
    }
    else{
      print("not upload image");
    }
  }
  catch(e){
    print("Error uplaoding image: $e");
  }
}