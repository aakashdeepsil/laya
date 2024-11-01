import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laya/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = AppTheme.lightMode;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveTheme(themeData);
    notifyListeners();
  }

  void toggleTheme() {
    _themeData = _themeData == AppTheme.lightMode
        ? AppTheme.darkMode
        : AppTheme.lightMode;
    _saveTheme(_themeData);
    notifyListeners();
  }

  void _saveTheme(ThemeData themeData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', themeData == AppTheme.darkMode);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeData = isDarkMode ? AppTheme.darkMode : AppTheme.lightMode;
    notifyListeners();
  }
}
