// lib/core/themes/dark_theme.dart
import 'package:flutter/material.dart';
import 'package:health_connect/core/constants/app_color.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.accent, // Using the vibrant accent color
  scaffoldBackgroundColor: AppColors.text, // The dark maroon is our background

  colorScheme: const ColorScheme.dark(
    primary: AppColors.accent,            // Use the bright magenta as primary in dark mode
    onPrimary: AppColors.white,           // Text on the bright accent color
    secondary: AppColors.primary,         // The main pink can be a secondary color
    onSecondary: AppColors.white,
    surface: Color(0xFF5D3A3A),           // A slightly lighter maroon for cards
    onSurface: AppColors.white,           // Main text color in dark mode
    background: AppColors.text,
    onBackground: AppColors.white,
    outline: AppColors.primaryDark,       // Dusky pink for borders
    error: AppColors.error,
    onError: AppColors.white,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF5D3A3A), // Dark card color for app bar
    titleTextStyle: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600),
    iconTheme: const IconThemeData(color: AppColors.white),
  ),
  
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.white),
    bodyMedium: TextStyle(color: AppColors.lightPink), // Lighter pink for secondary text
  ),
);