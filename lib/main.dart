// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pashusala/pages/loginPage.dart';
import 'package:pashusala/pages/registerPage.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));
  runApp(myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loginpage(),
      routes: {
        '/registerpage': (context) => registerpage(),
      },
    );
  }
}
