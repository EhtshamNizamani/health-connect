// lib/core/themes/dark_theme.dart
import 'package:flutter/material.dart';
import 'package:health_connect/core/constants/app_color.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryDark,       // Deep teal for dark mode
    onPrimary: AppColors.white,           // Text/icons on primary
    secondary: AppColors.accent,          // Accent teal
    onSecondary: AppColors.white,
    surface: AppColors.surfaceDark,       // Dark grey for cards
    onSurface: AppColors.textDark,        // Light text on dark
    background: AppColors.backgroundDark,
    onBackground: AppColors.textDark,
    outline: AppColors.primaryDark,       // Borders subtle in dark
    error: AppColors.error,
    onError: AppColors.white,
    secondaryContainer: AppColors.linkDark,

  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    titleTextStyle: TextStyle(
      color: AppColors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: AppColors.white),
  ),
  
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark),
    bodyMedium: TextStyle(color: AppColors.accent), // Secondary highlight text
  ),
);
