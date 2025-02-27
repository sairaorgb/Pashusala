import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme = enumThemes.brightuser;
  Map<String, ThemeData> themeMap = {
    'brightuser': enumThemes.brightuser,
    'brightdoctor': enumThemes.brightdoctor,
    'darkuser': enumThemes.darkuser,
    'darkdoctor': enumThemes.darkdoctor
  };
  ThemeData get selectedTheme => _selectedTheme;
  void getTheme(String themeSpec) {
    _selectedTheme = themeMap[themeSpec] ?? enumThemes.brightdoctor;
    notifyListeners();
  }
}

class enumThemes {
  static final ThemeData brightuser = ThemeData(
      primaryColor: Colors.blue[900], scaffoldBackgroundColor: Colors.white);
  static final ThemeData brightdoctor = ThemeData();
  static final ThemeData darkuser = ThemeData(
      primaryColor: Colors.blue[900], scaffoldBackgroundColor: Colors.black);
  static final ThemeData darkdoctor = ThemeData();
}
