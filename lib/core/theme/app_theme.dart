// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightPrimarySurface = Color(0xFFFFFFFF);
  static const Color lightSecondarySurface = Color(0xFFE5E5EA);
  static const Color lightGroupedBackground = Color(0xFFF7F7F9);
  static const Color lightCardBorder = Color(0xFFD1D1D6);
  static const Color lightPrimaryText = Color(0xFF000000);
  static const Color lightSecondaryText = Color(0xFF6D6D72);
  static const Color lightDivider = Color(0xFFC7C7CC);
  static const Color lightPrimaryAccent = Color(0xFF007AFF);
  static const Color lightSuccess = Color(0xFF34C759);
  static const Color lightWarning = Color(0xFFFF9F0A);
  static const Color lightDelete = Color(0xFFFF3B30);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkPrimarySurface = Color(0xFF1C1C1E);
  static const Color darkSecondarySurface = Color(0xFF2C2C2E);
  static const Color darkGroupedBackground = Color(0xFF111111);
  static const Color darkCardBorder = Color(0xFF3A3A3C);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFAEAEB2);
  static const Color darkDivider = Color(0xFF3A3A3C);
  static const Color darkPrimaryAccent = Color(0xFF0A84FF);
  static const Color darkSuccess = Color(0xFF30D158);
  static const Color darkWarning = Color(0xFFFF9F0A);
  static const Color darkDelete = Color(0xFFFF453A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimaryAccent,
        surface: lightPrimarySurface,
        onSurface: lightPrimaryText,
        onSurfaceVariant: lightSecondaryText,
        error: lightDelete,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightPrimaryAccent),
        titleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: lightPrimaryText,
          letterSpacing: -1.0,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: lightPrimaryText, letterSpacing: -1.0),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lightPrimaryText, letterSpacing: -0.5),
        bodyLarge: TextStyle(fontSize: 17, color: lightPrimaryText, height: 1.4),
        bodyMedium: TextStyle(fontSize: 15, color: lightSecondaryText, height: 1.4),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: lightPrimaryAccent),
        labelSmall: TextStyle(fontSize: 13, color: lightSecondaryText),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: lightGroupedBackground,
        indicatorColor: Color(0x1F007AFF), // 12% Opacity Primary Accent
        indicatorSize: Size.infinite,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightPrimaryAccent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: lightDivider,
        thickness: 1.0,
        space: 1.0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightPrimarySurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: lightPrimarySurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryAccent,
        surface: darkPrimarySurface,
        onSurface: darkPrimaryText,
        onSurfaceVariant: darkSecondaryText,
        error: darkDelete,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkPrimaryAccent),
        titleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: darkPrimaryText,
          letterSpacing: -1.0,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: darkPrimaryText, letterSpacing: -1.0),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkPrimaryText, letterSpacing: -0.5),
        bodyLarge: TextStyle(fontSize: 17, color: darkPrimaryText, height: 1.4),
        bodyMedium: TextStyle(fontSize: 15, color: darkSecondaryText, height: 1.4),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkPrimaryAccent),
        labelSmall: TextStyle(fontSize: 13, color: darkSecondaryText),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: darkGroupedBackground,
        indicatorColor: Color(0x1F0A84FF), // 12% Opacity Primary Accent
        indicatorSize: Size.infinite,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimaryAccent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1.0,
        space: 1.0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkPrimarySurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: darkPrimarySurface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
    );
  }

  // Private constructor to prevent instantiation
  AppTheme._();
}
