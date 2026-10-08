import 'package:flutter/material.dart';

class AppColors {
  static const Color cream = Color(0xFFFFF8F0);
  static const Color creamDark = Color(0xFFF5EDE3);
  static const Color warm50 = Color(0xFFFEFCF9);
  static const Color warm100 = Color(0xFFFDF7EE);
  static const Color warm200 = Color(0xFFF5EDE3);
  static const Color warm300 = Color(0xFFE8D5C4);
  static const Color warm400 = Color(0xFFC4A882);

  static const Color gold50 = Color(0xFFFFF9E6);
  static const Color gold100 = Color(0xFFFFF0BF);
  static const Color gold200 = Color(0xFFFFE599);
  static const Color gold300 = Color(0xFFFFD966);
  static const Color gold400 = Color(0xFFFFCC33);
  static const Color gold500 = Color(0xFFD4A843);
  static const Color gold600 = Color(0xFFB8912E);
  static const Color gold700 = Color(0xFF8B6914);

  static const Color dark900 = Color(0xFF1A1A2E);
  static const Color dark800 = Color(0xFF2D2D44);
  static const Color dark700 = Color(0xFF3D3D56);

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
          color: const Color(0xFFB49664).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadowLg => [
        BoxShadow(
          color: const Color(0xFFB49664).withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: gold500.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}
