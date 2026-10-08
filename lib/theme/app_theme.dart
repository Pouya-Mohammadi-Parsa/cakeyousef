import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  static ThemeData get light {
    final baseText = AppFonts.textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.family,
      scaffoldBackgroundColor: AppColors.cream,
      primaryColor: AppColors.gold500,
      colorScheme: ColorScheme.light(
        primary: AppColors.gold500,
        secondary: AppColors.gold300,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: AppColors.dark900,
      ),
      textTheme: baseText.apply(
        bodyColor: AppColors.dark900,
        displayColor: AppColors.dark900,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppFonts.vazirmatn(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.dark900,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppFonts.vazirmatn(
          color: AppColors.warm400,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
