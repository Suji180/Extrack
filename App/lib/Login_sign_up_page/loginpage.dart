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
      body: Container(
        /*decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover,
              )
            ),*/
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 150, bottom: 20),
                child: const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(150, 0, 0, 0),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Container(
                padding: const EdgeInsets.only(left: 25),
                margin: const EdgeInsets.only(left: 25, right: 25),
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
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(height: 21),

              Container(
                padding: const EdgeInsets.only(left: 25),
                margin: const EdgeInsets.only(left: 25, right: 25),
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
                  borderRadius: BorderRadius.circular(30),
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
                            MaterialPageRoute(builder: (context) => const Resetpass())
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
                      backgroundColor: const Color.fromARGB(255, 57, 116, 219),
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
                      await getuser(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainApp()),
                          (Route<dynamic> route)=>false,
                        );
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
              const SizedBox(height: 41),
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
              const SizedBox(height: 41),
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
      ),
    );
  }
}
