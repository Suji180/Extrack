import 'package:extrack/Login_sign_up_page/loginpage.dart';
import 'package:flutter/material.dart';

void main()
{
  runApp(const ConfirmPass());
}

class ConfirmPass extends StatefulWidget {
  final String? email;
  final int? otp;

  const ConfirmPass({super.key, this.email, this.otp});

  @override
  State<ConfirmPass> createState() => _ConfirmPassState();
}

class _ConfirmPassState extends State<ConfirmPass> {
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  bool _isMatching=false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 150.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 50),
                      child: const Text('Change Password', style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(150, 0, 0, 0)
                      ),
                      ),
                    ),
                    const SizedBox(height: 50,),

                    Padding(padding: EdgeInsets.only(left: 20.0),
                      child: Text("Create a strong password"
                        , style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(150, 0, 0, 0)
                        ),),
                    ),
                    const SizedBox(height: 10,),

                    Padding(padding: EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Create a strong new,password that you don't use for other website."
                        , style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87
                      ),),
                    ),
                    const SizedBox(height: 20,),

                    Container(
                        padding: EdgeInsets.only(left: 25),
                        margin: EdgeInsets.only(left: 25, right: 25),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.phonelink_lock_outlined),
                            hintText: 'Enter password',
                            hintStyle: TextStyle(
                                color: Colors.black38, fontSize: 14),
                          ),
                        )
                    ),
                    const SizedBox(height: 20),

                    Container(
                        padding: EdgeInsets.only(left: 25),
                        margin: EdgeInsets.only(left: 25, right: 25),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: TextField(
                          controller: _confirmpasswordController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.phonelink_lock_outlined),
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(
                                color: Colors.black38, fontSize: 14),
                          ),
                        )
                    ),
                    const SizedBox(height: 40,),
                  Builder(
                      builder: (BuildContext context){
                  return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  Padding(padding: EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                  style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Color
                      .fromARGB(255, 57, 116, 219)),
                  minimumSize: WidgetStateProperty.all(Size(
                  50, 40)),
                  ),

                  onPressed: () {
                  String password = _passwordController.text
                      .trim();
                  String confirmpassword = _confirmpasswordController
                      .text.trim();
                  (password == confirmpassword) ? _isMatching =
                  true : _isMatching = false;
                  if (!_isMatching) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(
                  "Password doesn't match"))
                  );
                  }
                  else if (password.isEmpty ||
                  confirmpassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                  content: Text('Field is empty'))
                  );
                  }
                  else {
                  Navigator.push(context,
                  MaterialPageRoute(
                  builder: (context) => LoginPage()
                  )
                  );
                  }
                  },
                  child: Text('Finish', style: TextStyle(
                  color: Colors.white),)
                  ),
                  )
                  ],
                  );
                  }
                 ),
                  ],
                )
            ),
          )
      ),
    );
  }
}