// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/pages/homepage.dart';
import 'package:veterinary_app/pages/loginPage.dart';
import 'package:veterinary_app/pages/pagenav.dart';
import 'package:veterinary_app/pages/registerPage.dart';
import 'package:flutter/services.dart';
import 'package:veterinary_app/pages/welcomepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));
  await Firebase.initializeApp();

  runApp(myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: welcomePage(),
      routes: {
        '/loginpage': (context) => loginpage(switchbool: false),
        '/pagenavpage': (context) => pageNav(
              CurrentPageIndex: 1,
              CurrentUserId: "",
              SwitchValue: false,
            ),
        '/registerpage': (context) => registerpage(),
        '/homepage': (context) => homePage(
              switchValue: '',
              currentUserId: '',
            )
      },
    );
  }
}
