import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatTextField extends StatelessWidget {
  final String role;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final double padding;

  const ChatTextField({
    super.key,
    required this.role,
    required this.controller,
    required this.obscureText,
    required this.hintText,
    this.focusNode,
    this.padding = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: TextField(
        cursorColor: Colors.white,
        obscureText: obscureText,
        controller: controller,
        focusNode: focusNode,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color:
                (role == "doctor") ? Colors.green.shade50 : Colors.blue.shade50,
          ),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: (role == "doctor")
                  ? Colors.green.shade900
                  : Colors.blue.shade900,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              width: 2,
              color: (role == "doctor")
                  ? Colors.green.shade900
                  : Colors.blue.shade900,
            ),
          ),
          fillColor: (role == "doctor")
              ? Colors.green.shade900
              : const Color.fromARGB(255, 12, 27, 104),
          // fillColor: Colors.black,
          filled: true,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: (role == "doctor")
                  ? Colors.green.shade50
                  : Colors.blue.shade50,
            ),
          ),
        ),
      ),
    );
  }
}
