import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF1D4ED8);      // Deep Clinical Blue
  static const primaryDark = Color(0xFF1E3A8A);
  static const primaryLight = Color(0xFFDBEafe);
  static const bgLight = Color(0xFFFAFAFA);
  static const bgDark = Color(0xFF0F172A);
  static const cardDark = Color(0xFF1E293B);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF12181B);
  static const textGray = Color(0xFF6B7680);
  static const borderGray = Color(0xFFE5E9EA);

  // Severity colors from prompt
  static const normal = Color(0xFF22C55E);     // Emerald Green
  static const mild = Color(0xFFF59E0B);       // Amber
  static const moderate = Color(0xFFF97316);   // Vibrant Orange
  static const severe = Color(0xFFEF4444);     // Crimson Red

  // Light tints for backgrounds/badges
  static final normalBg = const Color(0xFF22C55E).withValues(alpha: 0.1);
  static final mildBg = const Color(0xFFF59E0B).withValues(alpha: 0.1);
  static final moderateBg = const Color(0xFFF97316).withValues(alpha: 0.1);
  static final severeBg = const Color(0xFFEF4444).withValues(alpha: 0.1);

  // Dark Mode specific
  static const darkPrimary = Color(0xFF60A5FA);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryDark,
        surface: AppColors.cardWhite,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderGray),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimary,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: Colors.black,
        surface: AppColors.cardDark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white10),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
