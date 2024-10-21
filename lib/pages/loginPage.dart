// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/utils/usertextfield.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<String> authenticate(
      String role, String useremail, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: useremail, password: password);
      var userDoc;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (role == "doctor") {
        userDoc = await FirebaseFirestore.instance
            .collection('doctor')
            .doc(currentUser!.uid)
            .get();
      } else {
        userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser!.uid)
            .get();
      }

      if (userDoc.exists) {
        final Data = userDoc.data();
      }
      return ('success');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        return ('Wrong password provided for that user.');
      } else {
        return ('incorrect credentials');
      }
    } catch (e) {
      return ('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool switchValue = ModalRoute.of(context)?.settings.arguments as bool;
    var _switchValue = switchValue;
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
                    _switchValue
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
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Switch(
                          value: _switchValue,
                          onChanged: (value) {
                            setState(() {
                              _switchValue = value;
                              print(_switchValue);
                            });
                          },
                          activeColor: Colors.green,
                          activeTrackColor: Colors.lightGreen,
                          inactiveThumbColor: Colors.blue,
                          inactiveTrackColor: Colors.blue[200],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _switchValue ? "Welcome, Doctor" : "Welcome, User",
                    style: TextStyle(
                        color: _switchValue ? Colors.green : Colors.blue,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Login to your account",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(
                    height: 38,
                  ),
                  userTextfield(
                    fieldName: "User Email",
                    myController: userName,
                    fieldIcon: Icons.person,
                    fieldColor: Colors.blue[900],
                    containerColor: _switchValue
                        ? Color.fromRGBO(198, 244, 209, 1)
                        : Colors.blue[100],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  userTextfield(
                    fieldName: "Password",
                    myController: password,
                    fieldIcon: Icons.lock,
                    fieldColor: Colors.blue[900],
                    containerColor: _switchValue
                        ? Color.fromRGBO(198, 244, 209, 1)
                        : Colors.blue[100],
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?   ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_switchValue) {
                        if (userName.text == '' || password.text == '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Fill the Details completely !!',
                                style: TextStyle(color: Colors.black),
                              ),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.white,
                            ),
                          );
                        } else {
                          var result = await authenticate(
                              "doctor", userName.text, password.text);
                          if (result == 'success') {
                            userName.clear();
                            password.clear();
                            Navigator.pushNamed(context, '/homepage',
                                arguments: _switchValue);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result!,
                                  style: TextStyle(color: Colors.black),
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.white,
                              ),
                            );
                          }
                        }
                      } else {
                        if (userName.text == '' || password.text == '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Fill the Details completely !!',
                                style: TextStyle(color: Colors.black),
                              ),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.white,
                            ),
                          );
                        } else {
                          var result = await authenticate(
                              "user", userName.text, password.text);
                          if (result == 'success') {
                            userName.clear();
                            password.clear();
                            Navigator.pushNamed(context, '/homepage',
                                arguments: _switchValue);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result!,
                                  style: TextStyle(color: Colors.black),
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.white,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Container(
                      height: 48,
                      width: 350,
                      decoration: BoxDecoration(
                          color: _switchValue
                              ? Colors.green[900]
                              : Colors.blue[900],
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/registerpage',
                        arguments: _switchValue),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Didn't have an account? ",
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 14,
                              color: _switchValue ? Colors.green : Colors.blue,
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
