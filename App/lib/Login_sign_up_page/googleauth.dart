
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class googleauth 
{
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "738833372764-jfaom84ockovbjc6fhbfkfcid8gfabdr.apps.googleusercontent.com",
    scopes: [
      'email',
      'profile'
    ]
 );

Future<void> handleSignIn() async {
 try   {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account!= null )
{
       final auth = await account.authentication;
       print('Access Token : " ${auth.accessToken}"');
       print('ID Token : " ${auth.idToken} "');

}
else 
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
