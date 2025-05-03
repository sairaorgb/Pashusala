// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/cartStoreProvider.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/homePetsProvider.dart';
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
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  await Geolocator.requestPermission();

  await Hive.initFlutter();
  await Hive.openBox('myBox');
  Database db = Database();
  var authResponse = await db.validateUser();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomepetsProvider()),
      ChangeNotifierProvider(create: (_) => CartStoreProvider())
    ],
    child: myApp(
      db: db,
      authResponse: authResponse,
    ),
  ));
}

class myApp extends StatelessWidget {
  Database db;
  String authResponse;
  myApp({super.key, required this.authResponse, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: (authResponse == "success")
          ? PageNav(
              db: db,
              CurrentPageIndex: 1,
              CurrentUserId: db.user!.uid,
              SwitchValue: db.switchValue)
          : WelcomePage(db: db),
      routes: {
        '/loginpage': (context) => Loginpage(
              switchbool: false,
              db: db,
            ),
        '/pagenavpage': (context) => PageNav(
              CurrentPageIndex: 1,
              CurrentUserId: "",
              SwitchValue: false,
              db: db,
            ),
        '/registerpage': (context) => Registerpage(
              db: Database(),
            ),
        '/homepage': (context) => HomePage(
              switchValue: '',
              currentUserId: '',
              db: db,
            )
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
    );
  }
}
