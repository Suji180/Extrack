import 'package:extrack/Login_sign_up_page/SignUP%20page.dart';
import 'package:extrack/Login_sign_up_page/loginpage.dart';
import 'package:flutter/material.dart';




class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SecondPage(),));
                },
                child: Container(
                  
                  padding: const EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height*0.1,
                  width: MediaQuery.of(context).size.width*0.5,
                  
                  child: Center(
                    child: const Text('Login'
                    ,style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 26, 95, 135)
                    ),
                    ),
                  ),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: const Color.fromARGB(255, 202, 203, 203)),
                  margin: const EdgeInsets.all(20),
                  
                ),
              ),
            ),

             Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=> SignUpPage()));
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height*0.1,
                  width: MediaQuery.of(context).size.width*0.5,
                  child: Center(
                    child: const Text('Sign Up'
                    ,style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 26, 95, 135)
                    ),
                    ),
                  ),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: const Color.fromARGB(255, 202, 203, 203)),
                  margin: const EdgeInsets.all(20),
                  
                ),
              ),
            )
                
          ],
        )

        
      )
    );
  }
}
