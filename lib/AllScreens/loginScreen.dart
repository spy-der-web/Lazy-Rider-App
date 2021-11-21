import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lazy_rider/AllScreens/registerationScreen.dart';
import 'package:lazy_rider/AllWidgets/progressDialog.dart';
import 'package:lazy_rider/main.dart';

import 'mainscreen.dart';


class LoginScreen extends StatelessWidget {

  static const String idScreen = "login";
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 65.0,),
              const Image(
                  image: AssetImage("images/logo.png"),
              width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),

              const SizedBox(height: 1.0,),
              const Text(
                  "Login as a Rider",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),

              Padding(
                  padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [

                SizedBox(height: 1.0,),
                TextField(
                  controller: emailTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      fontSize: 14.0,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                  style: TextStyle(fontSize: 14.0),
                ),

                  SizedBox(height: 1.0,),
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),

                SizedBox(height: 20.0,),

                ElevatedButton.icon(

                  icon: Icon(Icons.login_sharp,),
                  label: Text("Login",
                    style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.yellow,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27.0),
                      side: BorderSide(width: 2.0,),
                    ),
                    padding: EdgeInsets.all(14),
                  ),
                  onPressed: ()
                  {
                    if(!emailTextEditingController.text.contains("@"))
                    {
                      displayToastMessage("Email address is not Valid.", context);
                    }
                    else if(passwordTextEditingController.text.isEmpty)
                    {
                      displayToastMessage("Password is mandatory.", context);
                    }
                    else
                    {
                      loginAuthenticateUser(context);
                    }
                  },
                ),

                ],
            ),



              ),

              TextButton(
                onPressed: ()
                {
                  Navigator.pushNamedAndRemoveUntil(context, RegisterationScreen.idScreen, (route) => false);
                },
                  child: Text(
                    "Do not have an Account? Register Here."
                  ),
              ),

            ],
          ),
        ),
      ),
    );
  }


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void loginAuthenticateUser(BuildContext context) async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Authenticating, Please wait...",);
        }
    );
    final User firebaseUser = (await _firebaseAuth
        .signInWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text
    ).catchError((errMsg){
      Navigator.pop(context);
      displayToastMessage("Error: " + errMsg.toString(), context);
    })).user;

    if(firebaseUser != null) //user created
        {

     usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if(snap.value !=null)
        {
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          displayToastMessage("You are logged in now.", context);
        }
        else
        {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage("No record exists for this user. Please create new account.", context);
        }
      });
    }
    else
    {
      Navigator.pop(context);
      displayToastMessage("Error Occurred, can not sign-in.", context);
    }
  }
}
