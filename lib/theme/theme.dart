import "package:flutter/material.dart";

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    brightness: Brightness.light,
    primary: Color.fromRGBO(67, 176, 42, 1),
    secondary: Color.fromRGBO(206, 159, 81, 1),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromRGBO(67, 176, 42, 1),
      ),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Color.fromRGBO(15, 15, 15, 1),
    brightness: Brightness.dark,
    primary: Color.fromRGBO(206, 159, 81, 1),
    secondary: Color.fromRGBO(67, 176, 42, 1),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromRGBO(206, 159, 81, 1),
      ),
    ),
  ),
);
