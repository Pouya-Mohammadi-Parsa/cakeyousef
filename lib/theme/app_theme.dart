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
      scaffoldBackgroundColor: const Color(0xFFFFF8F0),
      primaryColor: AppColors.gold500,
      colorScheme: ColorScheme.light(
        primary: AppColors.gold500,
        secondary: AppColors.gold300,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1A1A2E),
      ),
      textTheme: baseText.apply(
        bodyColor: const Color(0xFF1A1A2E),
        displayColor: const Color(0xFF1A1A2E),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppFonts.vazirmatn(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
      ),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE8D5C4),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppFonts.vazirmatn(
          color: const Color(0xFFC4A882),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get dark {
    final baseText = AppFonts.textTheme();
    const scaffold = Color(0xFF12121A);
    const surface = Color(0xFF1E1E2C);
    const onSurface = Color(0xFFF5F0E8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.family,
      scaffoldBackgroundColor: scaffold,
      primaryColor: AppColors.gold500,
      colorScheme: ColorScheme.dark(
        primary: AppColors.gold500,
        secondary: AppColors.gold300,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: onSurface,
      ),
      textTheme: baseText.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppFonts.vazirmatn(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        iconTheme: const IconThemeData(color: onSurface),
      ),
      cardColor: surface,
      dividerColor: const Color(0xFF2C2C3A),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppFonts.vazirmatn(
          color: const Color(0xFFB8A48A),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
