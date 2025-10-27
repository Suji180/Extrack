
import 'package:extrack/Login_sign_up_page/googleauth.dart';
import 'package:extrack/Login_sign_up_page/loginpage.dart';
import 'package:extrack/home.dart';
import 'package:flutter/material.dart';
import 'package:extrack/server_logic.dart/server.dart';
import 'package:extrack/Login_sign_up_page/Secondpage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  bool agree = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool confirmPass() {
    return _confirmPasswordController.text.trim() ==
        _passwordController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          //  image: DecorationImage(
          //    image: AssetImage('assets/bg.jpg'),
          //    fit: BoxFit.cover,
          // ),
         ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 90, bottom: 20),
                  padding: const EdgeInsets.only(left: 80, right: 90),
                  child: const Text(
                    textAlign: TextAlign.center,
                    'Join for better \nSavings Experience',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Email field
              Container(
                padding: const EdgeInsets.only(left: 25),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.mail_outline_outlined, color: Colors.black38),
                    hintText: 'Phone/Email id',
                    hintStyle: TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 21),

              // Password field
              Container(
                padding: const EdgeInsets.only(left: 25),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.lock_outline, color: Colors.black38),
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 21),

              // Confirm password field
              Container(
                padding: const EdgeInsets.only(left: 25),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.person_4_outlined, color: Colors.black38),
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Agreement checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: agree,
                    onChanged: (bool? value) {
                      setState(() {
                        agree = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'I Have read and agree To',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      ' User Agreement Privacy Policy',
                      style: TextStyle(
                        color: Color.fromARGB(255, 13, 86, 146),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 21),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 57, 116, 219),
                    ),
                    onPressed: () async {
                      print("button clicked");
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all fields")),
                        );
                        return;
                      }

                      if (!confirmPass()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Passwords do not match")),
                        );
                        return;
                      }

                      try {
                        await adduser(
                          _emailController.text.trim()
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SecondPage(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          )),

                        );
                        print("navigati on sent");
                      } catch (e) {
                        print("Error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Signup failed")),
                        );
                      }
                    },
                    child: const Text('Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 21),

              // Divider
              const Text(
                '---------- Or Sign Up With ----------',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 21),

              // Social buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook_outlined, color: Colors.blueAccent),
                    onPressed: () {},
                    iconSize: 40,
                  ),
                  IconButton(
                    icon: const Icon(Icons.apple_outlined, color: Colors.black),
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

              // Sign in row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
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
                        MaterialPageRoute(builder: (context) => const SecondPage(
                          email: '',
                          password: '',
                        )),
                      );
                    },
                    child: const Text(
                      ' Sign In ',
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
