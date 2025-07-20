import 'package:flutter/material.dart';
import 'package:health_connect/core/constants/app_color.dart';
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    titleTextStyle: TextStyle(color: AppColors.white, fontSize: 18),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.text),
    bodyMedium: TextStyle(color: AppColors.text),
  ),
);
