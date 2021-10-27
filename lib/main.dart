import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber/AllScreens/loginScreen.dart';
import 'package:uber/AllScreens/mainscreen.dart';
import 'package:uber/AllScreens/registerationScreen.dart';
import 'package:uber/DataHandler/appData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersRef =
    FirebaseDatabase.instance.reference().child("users");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Taxi Rider',
        theme: ThemeData(
         
          primarySwatch: Colors.blue,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScrenn.idScreen :  MainScreen.idScreen,
        routes: {
          RegisterationScrenn.idScreen: (context) => RegisterationScrenn(),
          LoginScrenn.idScreen: (context) => LoginScrenn(),
          MainScreen.idScreen: (context) => MainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
