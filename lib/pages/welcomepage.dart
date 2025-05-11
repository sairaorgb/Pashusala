// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/pages/roleSelectPage.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<Database>(context);
    return Scaffold(
        body: Stack(children: [
      Container(
          child: Image.asset(
        'assets/images/entry.jpg',
        fit: BoxFit.cover,
      )),
      Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16.0, top: 90, bottom: 44),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Pashushala',
                style: GoogleFonts.sansita(
                    color: Colors.black,
                    fontSize: 68,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 300.0,
                  child: Center(
                    child: DefaultTextStyle(
                      style: GoogleFonts.sansita(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          FadeAnimatedText('Quick Veterinary Service'),
                          FadeAnimatedText('Pet Shop'),
                          FadeAnimatedText('Pharmacy Support'),
                          FadeAnimatedText('Real time Chat with Doctor')
                        ],
                      ),
                    ),
                  ),
                )),
            Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Roleselectpage(),
                  )),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                        child: Text(
                      "Get Started",
                      style: GoogleFonts.secularOne(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 21),
                    )),
                  )),
            )
          ],
        ),
      ),
    ]));
  }
}
