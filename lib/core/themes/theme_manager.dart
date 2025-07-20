// lib/core/themes/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

class ThemeState {
  final ThemeData themeData;
  final bool isDark;

  ThemeState({required this.themeData, required this.isDark});
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(
          ThemeState(themeData: lightTheme, isDark: false),
        );

  void toggleTheme() {
    final newIsDark = !state.isDark;
    emit(
      ThemeState(
        themeData: newIsDark ? darkTheme : lightTheme,
        isDark: newIsDark,
      ),
    );
  }
}
