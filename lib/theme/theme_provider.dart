// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(AppTheme.lightMode) {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkMode') ?? false
        ? AppTheme.darkMode
        : AppTheme.lightMode;
  }

  void setTheme(ThemeData theme) {
    state = theme;
    _saveTheme();
  }

  void toggleTheme() {
    state =
        state == AppTheme.lightMode ? AppTheme.darkMode : AppTheme.lightMode;
    _saveTheme();
  }

  void _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', state == AppTheme.darkMode);
  }
}
