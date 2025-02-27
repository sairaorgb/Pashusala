// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/pages/loginPage.dart';

class welcomePage extends StatefulWidget {
  const welcomePage({super.key});

  @override
  State<welcomePage> createState() => _welcomePageState();
}

class _welcomePageState extends State<welcomePage> {
  @override
  Widget build(BuildContext context) {
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
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Pashushala',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 64,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 250.0,
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText('Quick Veterinary Service'),
                        FadeAnimatedText('Pet Shop'),
                        FadeAnimatedText('Pharmacy Support'),
                        FadeAnimatedText('Real time Chat with feature')
                      ],
                    ),
                  ),
                )),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Text(
                  "  Select User Type  ",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Expanded(
                    child: Divider(
                  thickness: 2,
                ))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     GestureDetector(
            //       onTap: () => Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => loginpage(switchbool: false))),
            //       child: Container(
            //         height: 36,
            //         width: 140,
            //         decoration: BoxDecoration(
            //             // color: Color.fromRGBO(39, 157, 157, 1),
            //             color: Color.fromRGBO(8, 164, 167, 1),
            //             // color: Colors.blue[400],
            //             borderRadius: BorderRadius.circular(12)),
            //         child: Center(
            //           child: Text(
            //             "Customer",
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 20,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //       ),
            //     ),
            //     SizedBox(
            //       width: 100,
            //     ),
            //     GestureDetector(
            //       onTap: () => Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => loginpage(switchbool: true),
            //           )),
            //       child: Container(
            //         height: 36,
            //         width: 100,
            //         decoration: BoxDecoration(
            //             // color: Colors.green,
            //             color: Color.fromRGBO(8, 164, 167, 1),
            //             borderRadius: BorderRadius.circular(12)),
            //         child: Center(
            //           child: Text(
            //             "Doctor",
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 20,
            //                 fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //       ),
            //     )
            //   ],
            // )
          ],
        ),
      ),
    ]));
  }
}
