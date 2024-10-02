// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class userTextfield extends StatefulWidget {
  String fieldName;
  TextEditingController myController;
  IconData fieldIcon;
  Color? fieldColor;
  bool obscureText;
  Color? containerColor;
  userTextfield(
      {super.key,
      required this.fieldName,
      required this.myController,
      required this.fieldIcon,
      required this.fieldColor,
      required this.containerColor,
      this.obscureText = false});

  @override
  State<userTextfield> createState() => _userTextfieldState();
}

class _userTextfieldState extends State<userTextfield> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: widget.containerColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: TextField(
            obscureText: widget.obscureText,
            controller: widget.myController,
            decoration: InputDecoration(
                icon: Icon(
                  widget.fieldIcon,
                  color: widget.fieldColor,
                ),
                hintText: widget.fieldName,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w400, color: widget.fieldColor),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none)),
      ),
    );
  }
}
