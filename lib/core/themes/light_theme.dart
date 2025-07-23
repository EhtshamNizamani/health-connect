// lib/core/themes/light_theme.dart
import 'package:flutter/material.dart';
import 'package:health_connect/core/constants/app_color.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.backgroundLight, // Our new light pink background

  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.white,           // Text on primary buttons
    secondary: AppColors.accent,          // Accent color
    onSecondary: AppColors.white,         // Text on accent color
    surface: AppColors.surface,           // Card backgrounds (white)
    onSurface: AppColors.text,            // Main text color (dark maroon)
    background: AppColors.backgroundLight,
    onBackground: AppColors.text,
    outline: AppColors.lightPink,         // For borders
    error: AppColors.error,
    onError: AppColors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    titleTextStyle: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600),
    iconTheme: IconThemeData(color: AppColors.white),
  ),
  
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.text),
    bodyMedium: TextStyle(color: AppColors.primaryDark), // Using the dusky pink for secondary text
  ),
);