import 'package:flutter/material.dart';

// Define common colors
const primaryColor = Color.fromRGBO(67, 176, 42, 1);
const secondaryColor = Color.fromRGBO(206, 159, 81, 1);
const lightSurfaceColor = Colors.white;
const darkSurfaceColor = Color.fromRGBO(15, 15, 15, 1);

// Define input decoration theme
const inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderSide: BorderSide(
      color: primaryColor,
    ),
  ),
);

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: lightSurfaceColor,
    primary: primaryColor,
    secondary: secondaryColor,
  ),
  inputDecorationTheme: inputDecorationTheme.copyWith(
    border: const OutlineInputBorder(
      borderSide: BorderSide(
        color: primaryColor,
      ),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: darkSurfaceColor,
    primary: secondaryColor,
    secondary: primaryColor,
  ),
  inputDecorationTheme: inputDecorationTheme.copyWith(
    border: const OutlineInputBorder(
      borderSide: BorderSide(
        color: secondaryColor,
      ),
    ),
  ),
);