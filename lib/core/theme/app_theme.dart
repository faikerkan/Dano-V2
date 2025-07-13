import 'package:flutter/material.dart';

class DanoTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      primaryColor: const Color(0xFF4F8FFF),
      scaffoldBackgroundColor: const Color(0xFF181A20),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4F8FFF),
        secondary: Color(0xFFFFD600),
        background: Color(0xFF181A20),
        surface: Color(0xFF23262F),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF181A20),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F8FFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4F8FFF),
          side: const BorderSide(color: Color(0xFF4F8FFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      textTheme: const TextTheme(
        headline1: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        bodyText1: TextStyle(fontSize: 16, color: Colors.white70),
        bodyText2: TextStyle(fontSize: 14, color: Colors.white60),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF23262F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.white38),
      ),
    );
  }
} 