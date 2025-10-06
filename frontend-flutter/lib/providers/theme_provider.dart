import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = true;

  ThemeProvider() {
    getThemePreference();
  }

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _isDarkTheme);
  }

  void getThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme =  prefs.getBool('isDarkTheme') ?? true;
    notifyListeners();
  }
}