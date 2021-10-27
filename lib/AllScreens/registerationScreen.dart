import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber/AllScreens/loginScreen.dart';
import 'package:uber/AllScreens/mainscreen.dart';
import 'package:uber/AllWidgets/progressDialog.dart';
import 'package:uber/main.dart';

class RegisterationScrenn extends StatefulWidget {
  static const String idScreen = "register";

  @override
  _RegisterationScrennState createState() => _RegisterationScrennState();
}

class _RegisterationScrennState extends State<RegisterationScrenn> {
  TextEditingController nameTextEditingController = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

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
                height: 20.0,
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
                "Register as a rider",
                style: TextStyle(fontSize: 24.0, fontFamily: " bolt-regular"),
                textAlign: TextAlign.center,
              ),

              // creation formulaire
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    //username
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    //email input
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

                    // phone number

                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
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
                            "Create Account",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "bolt-regular"),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: () {
                        if (nameTextEditingController.text.length < 4) {
                          displayToastMessage(
                              "Name must be atleast 3characters", context);
                        } else if (!emailTextEditingController.text
                            .contains("@")) {
                          displayToastMessage(
                              "Email address is not vvalid", context);
                        } else if (phoneTextEditingController.text.isEmpty) {
                          displayToastMessage(
                              "Phone number is not mandatory", context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          displayToastMessage(
                              "password must be atleast 6 charaters", context);
                        } else {
                          registerNewUser(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScrenn.idScreen, (route) => false);
                },
                child: Text("Already have an Account? Login here"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {
    //pop up dialog
   showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Registering, please wait.....",
          );
        });

    final User? firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((errMsg) {
               Navigator.pop(context);
      displayToastMessage("Error :" + errMsg.toString(), context);
    })).user;

    if (firebaseUser != null) // user create
    {
      // save user in to the database
      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      usersRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMessage(
          "Congratulations , you account has been created.", context);

      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
       Navigator.pop(context);
      //error occured- display error msg
      displayToastMessage("New user account has not been created.", context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
