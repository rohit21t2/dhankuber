import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryBrand,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.primaryText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.primaryText,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrand,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: const Color.fromRGBO(0, 0, 0, 0.1),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.neutralLightGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.1),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primaryBrand,
        unselectedItemColor: AppColors.secondaryText,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 24),
      ),
    );
  }
}