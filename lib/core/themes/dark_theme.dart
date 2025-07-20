
import 'package:flutter/material.dart';
import 'package:health_connect/core/constants/app_color.dart';
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.black,
    titleTextStyle: TextStyle(color: AppColors.white, fontSize: 18),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.white),
    bodyMedium: TextStyle(color: AppColors.grey),
  ),
);
