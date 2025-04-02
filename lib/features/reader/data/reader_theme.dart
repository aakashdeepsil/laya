import 'package:flutter/material.dart';

class ReaderTheme {
  final Color background;
  final Color text;
  final Color accent;
  final Color surfaceColor;
  final Color borderColor;

  const ReaderTheme({
    required this.background,
    required this.text,
    required this.accent,
    required this.surfaceColor,
    required this.borderColor,
  });

  ReaderTheme copyWith({
    Color? background,
    Color? text,
    Color? accent,
    Color? surfaceColor,
    Color? borderColor,
  }) {
    return ReaderTheme(
      background: background ?? this.background,
      text: text ?? this.text,
      accent: accent ?? this.accent,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}

class ReaderThemes {
  static const dark = ReaderTheme(
    background: Color(0xFF09090B),
    text: Colors.white,
    accent: Color(0xFF818CF8),
    surfaceColor: Color(0xFF1C1C1F),
    borderColor: Color(0xFF2E2E33),
  );

  static const light = ReaderTheme(
    background: Colors.white,
    text: Color(0xFF09090B),
    accent: Color(0xFF818CF8),
    surfaceColor: Color(0xFFF7F7F8),
    borderColor: Color(0xFFE5E5E8),
  );

  static const sepia = ReaderTheme(
    background: Color(0xFFF8F4E9),
    text: Color(0xFF5C4B37),
    accent: Color(0xFF8B7355),
    surfaceColor: Color(0xFFF2EDE0),
    borderColor: Color(0xFFE6DCC6),
  );

  static const nightBlue = ReaderTheme(
    background: Color(0xFF0F172A),
    text: Color(0xFFE2E8F0),
    accent: Color(0xFF60A5FA),
    surfaceColor: Color(0xFF1E293B),
    borderColor: Color(0xFF334155),
  );
}
