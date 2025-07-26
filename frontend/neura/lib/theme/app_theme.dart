import 'package:flutter/material.dart';

final darkAppTheme = ThemeData(
  brightness: Brightness.dark, // ✅ Matches colorScheme
  scaffoldBackgroundColor: const Color(0xFF0D1B2A),
  colorScheme: const ColorScheme.dark(
    primary: Colors.blueAccent,
    secondary: Colors.lightBlueAccent,
    background: Color(0xFF0D1B2A),
    surface: Color(0xFF1B263B),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white70),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1B263B),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
