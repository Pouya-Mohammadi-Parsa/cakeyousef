import 'package:flutter/material.dart';

class AppColors {
  static Brightness _brightness = Brightness.light;

  static bool get isDark => _brightness == Brightness.dark;

  static void applyBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  // Light palette
  static const Color _lCream = Color(0xFFFFF8F0);
  static const Color _lCreamDark = Color(0xFFF5EDE3);
  static const Color _lWarm50 = Color(0xFFFEFCF9);
  static const Color _lWarm100 = Color(0xFFFDF7EE);
  static const Color _lWarm200 = Color(0xFFF5EDE3);
  static const Color _lWarm300 = Color(0xFFE8D5C4);
  static const Color _lWarm400 = Color(0xFFC4A882);
  static const Color _lGold50 = Color(0xFFFFF9E6);
  static const Color _lGold100 = Color(0xFFFFF0BF);
  static const Color _lGold200 = Color(0xFFFFE599);
  static const Color _lDark900 = Color(0xFF1A1A2E);
  static const Color _lDark800 = Color(0xFF2D2D44);
  static const Color _lDark700 = Color(0xFF3D3D56);

  // Dark palette
  static const Color _dCream = Color(0xFF12121A);
  static const Color _dCreamDark = Color(0xFF1A1A26);
  static const Color _dWarm50 = Color(0xFF1A1A26);
  static const Color _dWarm100 = Color(0xFF22222F);
  static const Color _dWarm200 = Color(0xFF2C2C3A);
  static const Color _dWarm300 = Color(0xFF4A4458);
  static const Color _dWarm400 = Color(0xFFB8A48A);
  static const Color _dGold50 = Color(0xFF2A2418);
  static const Color _dGold100 = Color(0xFF3A301C);
  static const Color _dGold200 = Color(0xFF4A3E22);
  static const Color _dDark900 = Color(0xFFF5F0E8);
  static const Color _dDark800 = Color(0xFFE4DDD2);
  static const Color _dDark700 = Color(0xFFC9C0B4);
  static const Color _dCard = Color(0xFF1E1E2C);

  static Color get cream => isDark ? _dCream : _lCream;
  static Color get creamDark => isDark ? _dCreamDark : _lCreamDark;
  static Color get warm50 => isDark ? _dWarm50 : _lWarm50;
  static Color get warm100 => isDark ? _dWarm100 : _lWarm100;
  static Color get warm200 => isDark ? _dWarm200 : _lWarm200;
  static Color get warm300 => isDark ? _dWarm300 : _lWarm300;
  static Color get warm400 => isDark ? _dWarm400 : _lWarm400;

  static Color get gold50 => isDark ? _dGold50 : _lGold50;
  static Color get gold100 => isDark ? _dGold100 : _lGold100;
  static Color get gold200 => isDark ? _dGold200 : _lGold200;
  static const Color gold300 = Color(0xFFFFD966);
  static const Color gold400 = Color(0xFFFFCC33);
  static const Color gold500 = Color(0xFFD4A843);
  static const Color gold600 = Color(0xFFB8912E);
  static const Color gold700 = Color(0xFF8B6914);

  static Color get dark900 => isDark ? _dDark900 : _lDark900;
  static Color get dark800 => isDark ? _dDark800 : _lDark800;
  static Color get dark700 => isDark ? _dDark700 : _lDark700;

  /// Card / sheet surface (white in light, elevated dark in dark).
  static Color get card => isDark ? _dCard : Colors.white;

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD966), Color(0xFFD4A843), Color(0xFFB8912E)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A843), Color(0xFFFFD966), Color(0xFFE8C564)],
  );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.35)
              : const Color(0xFFB49664).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadowLg => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : const Color(0xFFB49664).withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: gold500.withValues(alpha: isDark ? 0.35 : 0.25),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}
