// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/pages/pagenav.dart';
import 'package:veterinary_app/utils/usertextfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Registerpage extends StatefulWidget {
  Database db;
  Registerpage({super.key, required this.db});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  TextEditingController userName = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPhone = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  TextEditingController doctorName = TextEditingController();
  TextEditingController doctorkvsc = TextEditingController();
  TextEditingController doctorEmail = TextEditingController();
  TextEditingController doctorPhone = TextEditingController();
  TextEditingController doctorPassword = TextEditingController();

  Future<String> authenticateDoctor(String doctorname, String doctoremail,
      String doctorkvsc, String doctorphone, String doctorpassword) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: doctoremail, password: doctorpassword);
      if (credential.user != null) {
        var user = credential.user!;
        await FirebaseFirestore.instance
            .collection('doctors_data')
            .doc(user.uid)
            .set({
          'doctorName': doctorname,
          'doctorEmail': doctoremail,
          'doctorPhone': doctorphone,
          'doctorKVSC': doctorkvsc,
        });
        // Create time_slots subcollection for the next 7 days
        final timeSlots = {
          "10:00 AM": true,
          "10:30 AM": true,
          "11:00 AM": true,
          "11:30 AM": true,
          "12:00 PM": true,
          "01:00 PM": true,
          "03:00 PM": true,
          "03:30 PM": true,
          "04:00 PM": true
        };
        final now = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final date = now.add(Duration(days: i));
          final dateString =
              "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          await FirebaseFirestore.instance
              .collection('doctors_data')
              .doc(user.uid)
              .collection('time_slots')
              .doc(dateString)
              .set(Map<String, bool>.from(timeSlots));
        }
        await FirebaseFirestore.instance
            .collection("chatUsers")
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'name': doctorname,
          'email': doctoremail,
          'role': "doctor"
        });
        widget.db.updateDatabase("userEmail", doctoremail);
        widget.db.updateDatabase("password", doctorpassword);
        widget.db.updateDatabase("role", "doctor");
        widget.db.updateDatabase("userName", doctorname);
        return (user.uid);
      } else {
        return ("failure");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email.');
      } else {
        return ('$e');
      }
    }
  }

  Future<String> authenticateUser(String username, String useremail,
      String userphone, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: useremail, password: password);
      if (credential.user != null) {
        var user = credential.user!;
        await FirebaseFirestore.instance
            .collection('users_data')
            .doc(user.uid)
            .set({
          'userName': username,
          'userEmail': useremail,
          'userPhone': userphone
        });
        await FirebaseFirestore.instance
            .collection("chatUsers")
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'name': username,
          'email': useremail,
          'role': "customer"
        });
        widget.db.switchValue = false;
        widget.db.updateDatabase("userEmail", useremail);
        widget.db.updateDatabase("password", userPassword);
        widget.db.updateDatabase("role", "user");
        widget.db.updateDatabase("userName", username);
        return (user.uid);
      } else {
        return ("failure");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email.');
      } else {
        return ('$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool switchValue = ModalRoute.of(context)?.settings.arguments as bool;
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
                          userTextfield(
                              fieldName: "Full Name",
                              myController: doctorName,
                              fieldIcon: Icons.person,
                              fieldColor: Colors.green[900],
                              containerColor: Color.fromRGBO(198, 244, 209, 1)),
                          SizedBox(
                            height: 12,
                          ),
                          userTextfield(
                              fieldName: "KSVC Number",
                              myController: doctorkvsc,
                              fieldIcon: Icons.password,
                              fieldColor: Colors.green[900],
                              containerColor: Color.fromRGBO(198, 244, 209, 1)),
                          SizedBox(
                            height: 12,
                          ),
                          userTextfield(
                              fieldName: "Email ID",
                              myController: doctorEmail,
                              fieldIcon: Icons.email,
                              fieldColor: Colors.green[900],
                              containerColor: Color.fromRGBO(198, 244, 209, 1)),
                          SizedBox(
                            height: 12,
                          ),
                          userTextfield(
                              fieldName: "Phone Number",
                              myController: doctorPhone,
                              fieldIcon: Icons.phone,
                              fieldColor: Colors.green[900],
                              containerColor: Color.fromRGBO(198, 244, 209, 1)),
                          SizedBox(
                            height: 12,
                          ),
                          userTextfield(
                              fieldName: "Set Password",
                              myController: doctorPassword,
                              fieldIcon: Icons.lock,
                              fieldColor: Colors.green[900],
                              containerColor: Color.fromRGBO(198, 244, 209, 1)),
                          SizedBox(
                            height: 12,
                          ),
                        ])
                      : Column(
                          children: [
                            userTextfield(
                                fieldName: "User Name",
                                myController: userName,
                                fieldIcon: Icons.person,
                                fieldColor: Colors.blue[900],
                                containerColor: Colors.blue[100]),
                            SizedBox(
                              height: 12,
                            ),
                            userTextfield(
                                fieldName: "Email ID",
                                myController: userEmail,
                                fieldIcon: Icons.email,
                                fieldColor: Colors.blue[900],
                                containerColor: Colors.blue[100]),
                            SizedBox(
                              height: 12,
                            ),
                            userTextfield(
                                fieldName: "Phone Number",
                                myController: userPhone,
                                fieldIcon: Icons.phone,
                                fieldColor: Colors.blue[900],
                                containerColor: Colors.blue[100]),
                            SizedBox(
                              height: 12,
                            ),
                            userTextfield(
                                fieldName: "Set Password",
                                myController: userPassword,
                                fieldIcon: Icons.lock,
                                fieldColor: Colors.blue[900],
                                containerColor: Colors.blue[100]),
                            SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (switchValue) {
                        if (doctorName.text == '' ||
                            doctorEmail.text == '' ||
                            doctorkvsc.text == '' ||
                            doctorPhone.text == '' ||
                            doctorPassword.text == '') {
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
                          var futresult = authenticateDoctor(
                              doctorName.text,
                              doctorEmail.text,
                              doctorkvsc.text,
                              doctorPhone.text,
                              doctorPassword.text);
                          var result = await futresult;
                          if (result != "failure") {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Fill the Details completely !!',
                                style: TextStyle(color: Colors.black),
                              ),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.white,
                            ));
                          }
                          if (result != "failure") {
                            doctorName.clear();
                            doctorEmail.clear();
                            doctorPhone.clear();
                            doctorPassword.clear();
                            doctorkvsc.clear();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PageNav(
                                  CurrentPageIndex: 1,
                                  db: widget.db,
                                  SwitchValue: switchValue,
                                  CurrentUserId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result,
                                  style: TextStyle(color: Colors.black),
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.white,
                              ),
                            );
                          }
                        }
                      } else {
                        if (userName.text == '' ||
                            userEmail.text == '' ||
                            userPhone.text == '' ||
                            userPassword.text == '') {
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
                          var futuserresult = authenticateUser(
                              userName.text,
                              userEmail.text,
                              userPhone.text,
                              userPassword.text);
                          var result = await futuserresult;

                          if (result != "failure") {
                            userName.clear();
                            userEmail.clear();
                            userPhone.clear();
                            userPassword.clear();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PageNav(
                                  CurrentPageIndex: 1,
                                  db: widget.db,
                                  SwitchValue: switchValue,
                                  CurrentUserId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result,
                                  style: TextStyle(color: Colors.black),
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.white,
                              ),
                            );
                          }
                        }
                      }
                      ;
                    },
                    child: Container(
                      height: 48,
                      width: 350,
                      decoration: BoxDecoration(
                          color: switchValue
                              ? Colors.green[900]
                              : Colors.blue[900],
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
