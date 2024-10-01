import 'package:flutter/material.dart';
import 'package:pashusala/pages/loginPage.dart';
import 'package:pashusala/pages/registerPage.dart';

void main() {
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
