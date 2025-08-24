// lib/core/themes/light_theme.dart
import 'package:flutter/material.dart';
import 'package:health_connect/core/constants/app_color.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.backgroundLight,

  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,           // Teal green
    onPrimary: AppColors.white,           // Text/icons on primary
    secondary: AppColors.accent,          // Accent teal highlight
    onSecondary: AppColors.white,
    surface: AppColors.surfaceLight,      // White cards
    onSurface: AppColors.textLight,       // Dark text
    background: AppColors.backgroundLight,
    onBackground: AppColors.textLight,
    outline: AppColors.accent,            // Light border color
    error: AppColors.error,
    onError: AppColors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    titleTextStyle: TextStyle(
      color: AppColors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: AppColors.white),
  ),
  
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textLight),
    bodyMedium: TextStyle(color: AppColors.primaryDark), // Subtle contrast text
  ),
);
