import 'package:flutter/material.dart';

/// Bundled Vazirmatn — no runtime Google Fonts download on first paint.
class AppFonts {
  static const family = 'Vazirmatn';

  static TextStyle vazirmatn({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme([TextTheme? base]) {
    final b = base ?? ThemeData.light().textTheme;
    return b.apply(fontFamily: family);
  }
}
