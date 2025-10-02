
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
import 'package:extrack/server_logic.dart/server.dart';


class google_auth_backend
{
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "485207706280-fhngt4kc2gokku7c50uqc79ucpvl0h29.apps.googleusercontent.com",
    scopes: [
      'email',
      'profile'
    ],
    forceCodeForRefreshToken: true, 
 );

Future<void> handleSignIn() async {
 try   {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
if (account!= null ) {       
       // CRITICAL: Get the serverAuthCode, not the tokens
       final String? authCode = account.serverAuthCode; 
       
       if (authCode != null) {
            print('Server Auth Code: "$authCode"');
            
            // Send the one-time authcode to your backend
            final response = await google_auth(authCode); 
            print(response);
            

       } else {
            print("Error: Server Auth Code not received.");
       }
}else 
{
  print("Sign in Aborted by user");
}  
 }
 catch(e)
 {
     print(e.hashCode);
     print("The Google sign is failed");
 }
}
}

