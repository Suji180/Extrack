import 'package:extrack/Login_sign_up_page/Secondpage.dart';
import 'package:extrack/main.dart';
import 'package:flutter/material.dart';
import 'package:extrack/Login_sign_up_page/PasswordConfirm.dart';
import 'package:extrack/server_logic.dart/server.dart';

class Resetpass extends StatefulWidget {
  const Resetpass({super.key});

  @override
  State<Resetpass> createState() => _ResetpassState();
}

class _ResetpassState extends State<Resetpass> {
  final _mailController = TextEditingController();
  bool _invalidMail = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: const Text(
                    'Account Recovery',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),

                Container(
                  child: Text(
                    'Enter the mail id associated \nwith your account.',
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 25),
                      margin: EdgeInsets.only(left: 25, right: 25),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: TextField(
                        controller: _mailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.mail_outline_outlined),
                          hintText: 'Enter mail id',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    if (_invalidMail)
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 50),
                        child: Text(
                          'Enter a valid mail',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Color.fromARGB(255, 57, 116, 219),
                          ),
                          minimumSize: WidgetStateProperty.all(Size(50, 40)),
                        ),

                        onPressed: () async {
                          if (!_mailController.text.contains('@gmail.com') ||
                              _mailController.text.isEmpty) {
                            setState(() {
                              _invalidMail = true;
                            });
                          } else {
                            _invalidMail = false;
                          }
                          if (!_invalidMail) {
                            await resetpassword(_mailController.text.trim());

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SecondPage(
                                  email: _mailController.text.trim(),
                                  nextPage: Container(),
                                  isPasswordReset: true,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Next',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
