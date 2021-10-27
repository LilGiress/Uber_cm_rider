import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber/AllScreens/mainscreen.dart';
import 'package:uber/AllScreens/registerationScreen.dart';
import 'package:uber/AllWidgets/progressDialog.dart';
import 'package:uber/main.dart';

// ignore: must_be_immutable
class LoginScrenn extends StatelessWidget {
  static const String idScreen = "Login";
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 35.0,
              ),
              Image(
                image: AssetImage("images/logo.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 1.0,
              ),
              Text(
                "Login as a rider",
                style: TextStyle(fontSize: 24.0, fontFamily: " bolt-regular"),
                textAlign: TextAlign.center,
              ),

              // creation formulaire
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    //password input
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    //login button
                    SizedBox(
                      height: 10.0,
                    ),
                    RaisedButton(
                      color: Colors.yellow,
                      textColor: Colors.white,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "bolt-regular"),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: () {
                        if (!emailTextEditingController.text.contains("@")) {
                          displayToastMessage(
                              "Email address is not vvalid", context);
                        } else if (passwordTextEditingController.text.isEmpty) {
                          displayToastMessage(
                              "password is not mandatory.", context);
                        } else {
                          LoginAndAuthenticateUser(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RegisterationScrenn.idScreen, (route) => false);
                },
                child: Text("Do not have an Account? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // ignore: non_constant_identifier_names
  void LoginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Authenticating, please wait.....",
          );
        });
    final User? firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Error :" + errMsg.toString(), context);
    })).user;

    if (firebaseUser != null) {
      usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
          displayToastMessage("  you are logged-Im now.", context);
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage(
              " No record exists for this user. please create new account.",
              context);
        }
      });
    } else {
      Navigator.pop(context);
      displayToastMessage("error occured , can not been.", context);
    }
  }
}
