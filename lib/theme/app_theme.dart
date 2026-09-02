import 'package:flutter/material.dart';

/// Central place for all colors, gradients and text styles used across
/// the app so every screen looks consistent with the design mockups.
class AppColors {
  static const primary = Color(0xFF6C63FF); // main purple
  static const primaryDark = Color(0xFF4F46E5);
  static const gradientStart = Color(0xFF6C63FF);
  static const gradientEnd = Color(0xFF8B7CF6);

  static const background = Color(0xFFF5F6FA);
  static const cardBackground = Colors.white;

  static const textDark = Color(0xFF1E1E2D);
  static const textGrey = Color(0xFF9A9AB0);

  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF5A623);
  static const danger = Color(0xFFE74C3C);

  static const subjectProgramming = Color(0xFF6C63FF);
  static const subjectWebDev = Color(0xFF8B7CF6);
  static const subjectDatabase = Color(0xFF2ECC9A);
  static const subjectNetworking = Color(0xFFF5A623);
  static const subjectITFundamentals = Color(0xFFE7609E);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
