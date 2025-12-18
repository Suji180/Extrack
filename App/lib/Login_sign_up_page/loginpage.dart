import 'package:extrack/Login_sign_up_page/SignUP%20page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extrack/server_logic.dart/server.dart';
import 'package:extrack/Login_sign_up_page/googleauth.dart';

import 'package:extrack/main.dart';
import 'package:extrack/Login_sign_up_page/ForgetPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => SecondPageState();
}

class SecondPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /*
  Future signIN() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
     email : _emailController.text.trim(),
     password : _passwordController.text.trim(),

    );

  }
  dei nivas i think these can help you and you have to remove only firebaseauth line 
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
        Container(
        height: MediaQuery.of(context).size.height*0.37,
        //width: MediaQuery.of(context).size.width*1.7,
        decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Loginpage.png'),
                fit: BoxFit.fitWidth,
              ),
                  borderRadius:BorderRadius.only(
            bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10)
        )
            ),
      ),
         Expanded(child:
         SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 3, bottom: 20,left: 10),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'poppins',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(left: 25),
                margin: const EdgeInsets.only(left: 10, right: 25),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.mail_outline_outlined,
                      color: Colors.black38,
                    ),
                    hintText: 'Phone/Email id',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                 borderRadius: BorderRadius.all(Radius.circular(10))
                ),
              ),
              const SizedBox(height: 21),

              Container(
                padding: const EdgeInsets.only(left: 25),
                margin: const EdgeInsets.only(left: 10, right: 25),
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.phonelink_lock_outlined,
                      color: Colors.black38,
                    ),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                  ),

                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  enableSuggestions: true,
                  autocorrect: false,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              const SizedBox(height: 21),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 25),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Resetpass(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 13, 86, 146),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 21),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  margin: const EdgeInsets.only(left: 25, right: 25),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 13, 253),
                    ),

                    // onPressed: () async {
                    //   await getuser(_emailController.text.trim(),
                    //       _passwordController.text.trim());

                    /* try {
                          await signIN();
                          // No need to manually navigate, Checklog will update automatically
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message ?? 'Sign in failed')),
                          );
                        } 
                        dei if you are working with database these above commented code will help you 
                        */
                    onPressed: () async {
                      bool ok = await getuser(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      if (ok) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainApp(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        print("login failed");
                      }
                    },
                    // },
                    child: const Text(
                      ' Sign In ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 13),
                    child: const Text(
                      '---------- Or Sign In With ----------',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.facebook_outlined,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {},
                    iconSize: 40,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.apple_outlined,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    onPressed: () {},
                    iconSize: 40,
                  ),
                  IconButton(
                    icon: Image(
                      image: AssetImage('assets/images/google.png'),
                      width: 40,
                      height: 40,
                    ),
                    onPressed: google_auth_backend().handleSignIn,
                    iconSize: 40,
                  ),
                ],
              ),
              const SizedBox(height: 21),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New to GetYourGuide?',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: const Text(
                      ' Sign Up ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 13, 86, 146),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
         )
    ],
    )
      );
  }
}
