import 'package:flutter/material.dart';

class TummyTheme {
  static const Color primary = Color(0xFFFF6A00); // warm orange
  static const Color secondary = Color(0xFFFFC107); // amber
  static const Color dark = Color(0xFF222222);
  static const Color light = Color(0xFFF7F7F7);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: dark,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
   cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1.5,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
    ),
    margin: const EdgeInsets.all(8),
  ),

  );
}