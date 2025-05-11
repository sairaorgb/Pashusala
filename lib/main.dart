// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/cartStoreProvider.dart';
import 'package:veterinary_app/clinicLocationProvider.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/homePetsProvider.dart';
import 'package:veterinary_app/pages/loginPage.dart';
import 'package:veterinary_app/pages/pagenav.dart';
import 'package:veterinary_app/pages/registerPage.dart';
import 'package:flutter/services.dart';
import 'package:veterinary_app/pages/welcomepage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Database()),
      ChangeNotifierProvider(create: (_) => HomepetsProvider()),
      ChangeNotifierProvider(create: (_) => CartStoreProvider()),
      ChangeNotifierProvider(create: (_) => Cliniclocationprovider())
    ],
    child: myApp(),
  ));
}

class myApp extends StatefulWidget {
  myApp({super.key});

  @override
  State<myApp> createState() => _myAppState();
}

class _myAppState extends State<myApp> {
  String authResponse = '';
  late Database db;

  Future<void> validatingUser(Database DB) async {
    authResponse = await DB.validateUser();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    db = Provider.of<Database>(context, listen: false);
    validatingUser(db);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: (authResponse.isEmpty)
          ? const _CacheLoadingScreen()
          : (authResponse == "success")
              ? PageNav(
                  CurrentPageIndex: 1,
                  CurrentUserId: db.user!.uid,
                  SwitchValue: db.switchValue)
              : WelcomePage(),
      routes: {
        '/loginpage': (context) => Loginpage(
              switchbool: false,
            ),
        '/pagenavpage': (context) => PageNav(
              CurrentPageIndex: 1,
              CurrentUserId: "",
              SwitchValue: false,
            ),
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
    );
  }
}

class _CacheLoadingScreen extends StatefulWidget {
  const _CacheLoadingScreen({Key? key}) : super(key: key);

  @override
  State<_CacheLoadingScreen> createState() => _CacheLoadingScreenState();
}

class _CacheLoadingScreenState extends State<_CacheLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCube(
              color: Colors.amberAccent,
              size: 70.0,
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Please wait while we retrieve your data...',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
