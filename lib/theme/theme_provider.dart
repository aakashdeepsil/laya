import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeData theme;
  final bool isDarkMode;

  ThemeState({
    required this.theme,
    required this.isDarkMode,
  });
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  developer.log('Initializing theme provider');
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(
          ThemeState(theme: AppTheme.lightMode, isDarkMode: false),
        ) {
    developer.log('ThemeNotifier initialized with default light theme');
    _loadTheme();
  }

  void _loadTheme() async {
    developer.log('Loading theme preference from SharedPreferences');
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      developer.log('Theme preference loaded: isDarkMode = $isDarkMode');

      state = ThemeState(
        theme: isDarkMode ? AppTheme.darkMode : AppTheme.lightMode,
        isDarkMode: isDarkMode,
      );
      developer.log('Theme state updated based on loaded preference');
    } catch (e) {
      developer.log('Failed to load theme preference: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }

  void toggleTheme() {
    developer
        .log('Toggle theme requested. Current isDarkMode: ${state.isDarkMode}');
    final isDarkMode = !state.isDarkMode;
    developer.log('Switching to ${isDarkMode ? "dark" : "light"} theme');

    state = ThemeState(
      theme: isDarkMode ? AppTheme.darkMode : AppTheme.lightMode,
      isDarkMode: isDarkMode,
    );
    developer.log('Theme state updated successfully');
    _saveTheme();
  }

  void _saveTheme() async {
    developer.log('Saving theme preference: isDarkMode = ${state.isDarkMode}');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', state.isDarkMode);
      developer.log('Theme preference saved successfully');
    } catch (e) {
      developer.log('Failed to save theme preference: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }
}
