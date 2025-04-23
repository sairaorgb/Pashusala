// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/pages/loginPage.dart';

class Roleselectpage extends StatelessWidget {
  Database db;
  Roleselectpage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(239, 238, 230, 1),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              "Choose your role below",
              style: GoogleFonts.secularOne(
                  fontSize: 46, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Loginpage(
                            switchbool: false,
                            db: db,
                          ))),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 180,
                    color: Colors.transparent,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.indigo[800],
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, left: 200),
                        child: Text(
                          "Pet Owner",
                          style: GoogleFonts.secularOne(
                              fontSize: 36, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                        height: 220,
                        child: Image.asset(
                          'assets/images/doggirl.png',
                          fit: BoxFit.cover,
                        )),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Loginpage(
                            switchbool: true,
                            db: db,
                          ))),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 180,
                    color: Colors.transparent,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          // color: Color.fromRGBO(198, 244, 209, 1),
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          "Vet Doctor",
                          style: GoogleFonts.secularOne(
                              fontSize: 36, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        height: 210,
                        child: Image.asset(
                          'assets/images/doctorPic.png',
                          fit: BoxFit.cover,
                        )),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 180,
                  color: Colors.transparent,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.brown[600],
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 220),
                      child: Text(
                        "Farmer",
                        style: GoogleFonts.secularOne(
                            fontSize: 36, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                      height: 210,
                      child: Image.asset(
                        'assets/images/farmerdog.png',
                        fit: BoxFit.cover,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
