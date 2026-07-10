// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Professional, high-contrast deep indigo/slate color seed
  static const Color seedColor = Color(0xFF1E3A8A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50 for clean background
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A), // Slate 900
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        bodyLarge: TextStyle(fontSize: 18, color: Color(0xFF334155), height: 1.5), // Slate 700
        bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF475569), height: 1.5), // Slate 600
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFDBEAFE), // Light blue highlight
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B), // Slate 800
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 18, color: Color(0xFFE2E8F0), height: 1.5), // Slate 200
        bodyMedium: TextStyle(fontSize: 16, color: Color(0xFFCBD5E1), height: 1.5), // Slate 300
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: Color(0xFF1E293B), // Slate 800
        indicatorColor: Color(0xFF1E40AF), // Dark blue highlight
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF3B82F6), // Brighter blue for dark theme contrast
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  // Private constructor to prevent instantiation
  AppTheme._();
}
