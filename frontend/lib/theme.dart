import 'package:flutter/material.dart';

class AppThemes {
  // 🎨 Common Color Sets
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grayBackground = Color(0xFFF9FAFB);
  static const Color grayText = Color(0xFF6B7280);
  static const Color darkText = Color(0xFF111827);

  // 🅰️ Common Font
  static const String fontFamily = "Poppins";

  // 🔹 1. Classic Theme (Default TummyTap)
  static final ThemeData classic = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: grayBackground,
    primaryColor: const Color(0xFFFF6B35),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF6B35),
      primary: const Color(0xFFFF6B35),
      secondary: const Color(0xFF27AE60),
      background: grayBackground,
      error: const Color(0xFFE63946),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: darkText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
  );

  // 🔹 2. Dark Theme
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: const Color(0xFFFF6B35),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFFF6B35),
      secondary: const Color(0xFF2D9CDB),
      background: const Color(0xFF121212),
      error: const Color(0xFFE63946),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
      ),
    ),
  );

  // 🔹 3. Fresh Theme (Green Vibes)
  static final ThemeData fresh = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: white,
    primaryColor: const Color(0xFF27AE60),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF27AE60),
      primary: const Color(0xFF27AE60),
      secondary: const Color(0xFF2D9CDB),
      background: white,
      error: const Color(0xFFE63946),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: darkText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF27AE60),
        foregroundColor: white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
      ),
    ),
  );

  // 🔹 4. Royal Theme (Premium Feel)
  static final ThemeData royal = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: white,
    primaryColor: const Color(0xFF6C63FF),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      primary: const Color(0xFF6C63FF),
      secondary: const Color(0xFFFFC300),
      background: white,
      error: const Color(0xFFE63946),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: darkText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
      ),
    ),
  );

  // 🔹 5. Minimal Theme (Clean & Simple)
  static final ThemeData minimal = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: white,
    primaryColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black,
      primary: Colors.black,
      secondary: Colors.grey,
      background: white,
      error: const Color(0xFFE63946),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
      ),
    ),
  );

  // 🍔 6. Spicy Theme (Zomato vibes - bold red)
  static final ThemeData spicy = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: white,
    primaryColor: const Color(0xFFE23744),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE23744),
      primary: const Color(0xFFE23744),
      secondary: const Color(0xFFFFA41B),
      background: white,
      error: const Color(0xFFE63946),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE23744),
        foregroundColor: white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
      ),
    ),
  );

  // 🥗 7. Veggie Theme (Uber Eats vibes - green & black)
  static final ThemeData veggie = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: const Color(0xFFF4F4F4),
    primaryColor: const Color(0xFF06C167),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF06C167),
      primary: const Color(0xFF06C167),
      secondary: Colors.black,
      background: const Color(0xFFF4F4F4),
      error: const Color(0xFFE63946),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF06C167),
        foregroundColor: white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
    ),
  );

  // 🌞 8. Sunny Theme (Swiggy vibes - orange + warm)
  static final ThemeData sunny = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: white,
    primaryColor: const Color(0xFFFF6F00),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF6F00),
      primary: const Color(0xFFFF6F00),
      secondary: const Color(0xFFFFC107),
      background: white,
      error: const Color(0xFFE63946),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6F00),
        foregroundColor: white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 5,
      ),
    ),
  );
}
