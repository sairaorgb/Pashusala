// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class registerpage extends StatefulWidget {
  registerpage({super.key});

  @override
  State<registerpage> createState() => _registerpageState();
}

class _registerpageState extends State<registerpage> {
  @override
  Widget build(BuildContext context) {
    bool switchValue = ModalRoute.of(context)?.settings.arguments as bool;
    print(switchValue);
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: LowerRightCurveClipper(),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Image.asset(
                    switchValue
                        ? 'assets/images/doc_and_pet.jpeg'
                        : 'assets/images/boy_and_pet.jpeg',
                  )),
            ),
          ),
          Positioned(
            top: 300,
            left: 20,
            right: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    switchValue ? "Welcome, Doctor" : "Welcome, User",
                    style: TextStyle(
                        color: switchValue ? Colors.green : Colors.blue,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Create your new account",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(
                    height: 38,
                  ),
                  switchValue
                      ? Column(children: [
                          Container(
                              height: 48,
                              width: 350,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Color.fromRGBO(198, 244, 209, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 12.0),
                                child: TextField(
                                    decoration: InputDecoration(
                                        icon: Icon(
                                          Icons.person,
                                          color: Colors.green[900],
                                        ),
                                        hintText: "Full Name",
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.green[900]),
                                        enabledBorder: InputBorder.none)),
                              )),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                              height: 48,
                              width: 350,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Color.fromRGBO(198, 244, 209, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 12.0),
                                child: TextField(
                                    decoration: InputDecoration(
                                        icon: Icon(
                                          Icons.password,
                                          color: Colors.green[900],
                                        ),
                                        hintText: "KSVC Number",
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.green[900]),
                                        enabledBorder: InputBorder.none)),
                              )),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                              height: 48,
                              width: 350,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Color.fromRGBO(198, 244, 209, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 12.0),
                                child: TextField(
                                    decoration: InputDecoration(
                                        icon: Icon(
                                          Icons.email,
                                          color: Colors.green[900],
                                        ),
                                        hintText: "Email ID",
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.green[900]),
                                        enabledBorder: InputBorder.none)),
                              )),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                              height: 48,
                              width: 350,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Color.fromRGBO(198, 244, 209, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 12.0),
                                child: TextField(
                                    decoration: InputDecoration(
                                        icon: Icon(
                                          Icons.phone,
                                          color: Colors.green[900],
                                        ),
                                        hintText: "Phone Number",
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.green[900]),
                                        enabledBorder: InputBorder.none)),
                              )),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                              height: 48,
                              width: 350,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Color.fromRGBO(198, 244, 209, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 12.0),
                                child: TextField(
                                    decoration: InputDecoration(
                                        icon: Icon(
                                          Icons.lock,
                                          color: Colors.green[900],
                                        ),
                                        hintText: "Set Password",
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.green[900]),
                                        enabledBorder: InputBorder.none)),
                              )),
                          SizedBox(
                            height: 30,
                          )
                        ])
                      : Column(
                          children: [
                            Container(
                                height: 48,
                                width: 350,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  // color: Color.fromRGBO(198, 244, 209, 1),
                                  color: Colors.blue[100],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 12.0),
                                  child: TextField(
                                      decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.person,
                                            color: Colors.blue[900],
                                          ),
                                          hintText: "User Name",
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.blue[900]),
                                          enabledBorder: InputBorder.none)),
                                )),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                                height: 48,
                                width: 350,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  // color: Color.fromRGBO(198, 244, 209, 1),
                                  color: Colors.blue[100],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 12.0),
                                  child: TextField(
                                      decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.email,
                                            color: Colors.blue[900],
                                          ),
                                          hintText: "Email ID",
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.blue[900]),
                                          enabledBorder: InputBorder.none)),
                                )),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                                height: 48,
                                width: 350,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  // color: Color.fromRGBO(198, 244, 209, 1),
                                  color: Colors.blue[100],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 12.0),
                                  child: TextField(
                                      decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.phone,
                                            color: Colors.blue[900],
                                          ),
                                          hintText: "Phone number",
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.blue[900]),
                                          enabledBorder: InputBorder.none)),
                                )),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                                height: 48,
                                width: 350,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  // color: Color.fromRGBO(198, 244, 209, 1),
                                  color: Colors.blue[100],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 12.0),
                                  child: TextField(
                                      decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.lock,
                                            color: Colors.blue[900],
                                          ),
                                          hintText: "Set Password",
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.blue[900]),
                                          enabledBorder: InputBorder.none)),
                                )),
                            SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 48,
                    width: 350,
                    decoration: BoxDecoration(
                        color:
                            switchValue ? Colors.green[900] : Colors.blue[900],
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Register",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ",
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 14,
                              color: switchValue ? Colors.green : Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LowerRightCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0); // Top-right corner
    path.lineTo(size.width, size.height); // Bottom-right corner
    path.arcToPoint(
      Offset(0, size.height),
      radius: Radius.circular(size.width / 2), // Curve for the lower-right part
      clockwise: false,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}