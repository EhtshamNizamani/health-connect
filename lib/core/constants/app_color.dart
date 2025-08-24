import 'package:flutter/material.dart';

class AppColors {
  // === Primary & Accent (Same names, diff values in themes) ===
  static const Color primaryLight = Color.fromARGB(255, 0, 134, 118); // Teal Green (calm, medical)
  static const Color accentLight = Color(0xFF26A69A);  // Lighter teal highlight
  static const Color primaryDark = Color.fromARGB(255, 1, 115, 96);  // Deep teal for dark mode
  
  static const Color primary = primaryLight; // alias (easy swap if needed)
  static const Color accent = accentLight;

  // === Neutral & Backgrounds ===
  static const Color backgroundLight = Color(0xFFF5F7FA); // Almost white, light bluish grey
  static const Color backgroundDark = Color(0xFF121212);  // Material dark base
  
  static const Color surfaceLight = Color(0xFFFFFFFF); // white cards
  static const Color surfaceDark = Color(0xFF1E1E1E);  // dark grey cards

  // === Text Colors ===
  static const Color textLight = Color(0xFF212121); // Dark grey for light mode
  static const Color textDark = Color(0xFFE0E0E0);  // Light grey for dark mode
  static const Color linkLight = Color(0xFF26A69A); // Teal accent for light theme
  static const Color linkDark = Color(0xFF4DD0E1);  // Teal accent for dark theme
  // === Semantic (keep same for both) ===
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
