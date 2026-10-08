import 'dart:math' as math;

import 'package:flutter/painting.dart';

class MixPigment {
  const MixPigment({
    required this.id,
    required this.name,
    required this.color,
    this.strength = 1,
    this.scatter = 0.28,
  });

  final String id;
  final String name;
  final Color color;
  final double strength;
  final double scatter;
}

class MixPart {
  const MixPart({required this.pigment, required this.units});

  final MixPigment pigment;
  final int units;

  double get weight => units * pigment.strength;
}

class MixResult {
  const MixResult({
    required this.color,
    required this.name,
    required this.hex,
    required this.parts,
    required this.totalUnits,
  });

  final Color color;
  final String name;
  final String hex;
  final List<MixPart> parts;
  final int totalUnits;

  bool get isEmpty => totalUnits == 0;
}

class ColorMixerEngine {
  static const pigments = [
    MixPigment(
      id: 'white',
      name: 'سفید',
      color: Color(0xFFF7F4EE),
      strength: 0.85,
      scatter: 1,
    ),
    MixPigment(
      id: 'ivory',
      name: 'عاجی',
      color: Color(0xFFF3E6C9),
      strength: 0.8,
      scatter: 0.9,
    ),
    MixPigment(
      id: 'yellow',
      name: 'زرد',
      color: Color(0xFFF5C400),
      strength: 0.95,
      scatter: 0.48,
    ),
    MixPigment(
      id: 'gold',
      name: 'طلایی',
      color: Color(0xFFC9A227),
      strength: 1,
      scatter: 0.42,
    ),
    MixPigment(
      id: 'orange',
      name: 'نارنجی',
      color: Color(0xFFF08A18),
      strength: 1.05,
      scatter: 0.32,
    ),
    MixPigment(
      id: 'red',
      name: 'قرمز',
      color: Color(0xFFC41E3A),
      strength: 1.2,
      scatter: 0.22,
    ),
    MixPigment(
      id: 'pink',
      name: 'صورتی',
      color: Color(0xFFE85A8C),
      strength: 1,
      scatter: 0.3,
    ),
    MixPigment(
      id: 'purple',
      name: 'بنفش',
      color: Color(0xFF6B3FA0),
      strength: 1.1,
      scatter: 0.2,
    ),
    MixPigment(
      id: 'blue',
      name: 'آبی',
      color: Color(0xFF2B62B3),
      strength: 1.15,
      scatter: 0.22,
    ),
    MixPigment(
      id: 'teal',
      name: 'فیروزه‌ای',
      color: Color(0xFF2A9D8F),
      strength: 1,
      scatter: 0.28,
    ),
    MixPigment(
      id: 'green',
      name: 'سبز',
      color: Color(0xFF2F8F4E),
      strength: 1.05,
      scatter: 0.26,
    ),
    MixPigment(
      id: 'brown',
      name: 'قهوه‌ای',
      color: Color(0xFF6B3E26),
      strength: 1.15,
      scatter: 0.18,
    ),
    MixPigment(
      id: 'black',
      name: 'مشکی',
      color: Color(0xFF1A1A1A),
      strength: 1.45,
      scatter: 0.07,
    ),
  ];

  static MixResult mix(Map<String, int> unitsById) {
    final parts = <MixPart>[];
    for (final pigment in pigments) {
      final units = unitsById[pigment.id] ?? 0;
      if (units > 0) {
        parts.add(MixPart(pigment: pigment, units: units));
      }
    }

    final totalUnits = parts.fold<int>(0, (sum, part) => sum + part.units);
    if (parts.isEmpty) {
      return const MixResult(
        color: Color(0xFFF7F4EE),
        name: 'بوم خالی',
        hex: '',
        parts: [],
        totalUnits: 0,
      );
    }

    if (parts.length == 1) {
      final only = parts.first.pigment;
      return MixResult(
        color: only.color,
        name: only.name,
        hex: _hex(only.color),
        parts: parts,
        totalUnits: totalUnits,
      );
    }

    var kR = 0.0, kG = 0.0, kB = 0.0, s = 0.0;
    for (final part in parts) {
      final w = part.weight;
      final linear = _linearRgb(part.pigment.color);
      final scatter = part.pigment.scatter;
      kR += w * _ks(linear.$1) * scatter;
      kG += w * _ks(linear.$2) * scatter;
      kB += w * _ks(linear.$3) * scatter;
      s += w * scatter;
    }

    final mixed = Color.fromARGB(
      255,
      _toByte(_gamma(_reflectance(kR / s))),
      _toByte(_gamma(_reflectance(kG / s))),
      _toByte(_gamma(_reflectance(kB / s))),
    );

    return MixResult(
      color: mixed,
      name: nameFor(mixed, parts),
      hex: _hex(mixed),
      parts: parts,
      totalUnits: totalUnits,
    );
  }

  static String nameFor(Color color, List<MixPart> parts) {
    final hsl = HSLColor.fromColor(color);
    final hue = hsl.hue;
    final sat = hsl.saturation;
    final light = hsl.lightness;

    if (sat < 0.07) {
      if (light > 0.93) return 'سفید';
      if (light > 0.8) return 'سفید شیری';
      if (light > 0.62) return 'خاکستری روشن';
      if (light > 0.38) return 'خاکستری';
      if (light > 0.16) return 'خاکستری تیره';
      return 'مشکی';
    }

    final base = _hueName(hue, sat, light);
    if (light > 0.82 && sat < 0.45) return '$base خیلی روشن';
    if (light > 0.72) return '$base روشن';
    if (light < 0.22) return '$base خیلی تیره';
    if (light < 0.34) return '$base تیره';
    if (sat < 0.28) return '$base ملایم';
    return base;
  }

  static String _hueName(double hue, double sat, double light) {
    if (hue < 12 || hue >= 348) return light > 0.62 ? 'صورتی' : 'قرمز';
    if (hue < 28) return light > 0.55 && sat < 0.55 ? 'هلویی' : 'قرمز مایل به نارنجی';
    if (hue < 42) return 'نارنجی';
    if (hue < 52) return light > 0.7 ? 'کرم' : 'کهربایی';
    if (hue < 68) return 'زرد';
    if (hue < 90) return 'سبز مغزپسته‌ای';
    if (hue < 150) return 'سبز';
    if (hue < 175) return 'سبز آبی';
    if (hue < 200) return 'فیروزه‌ای';
    if (hue < 230) return 'آبی';
    if (hue < 255) return 'آبی نیلی';
    if (hue < 285) return 'بنفش';
    if (hue < 320) return 'ارغوانی';
    return 'صورتی';
  }

  static String percentLabel(MixPart part, int totalUnits) {
    if (totalUnits == 0) return '۰٪';
    final value = ((part.units / totalUnits) * 100).round();
    return '${toFa(value)}٪';
  }

  static String toFa(int value) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var text = value.toString();
    for (var i = 0; i < 10; i++) {
      text = text.replaceAll(en[i], fa[i]);
    }
    return text;
  }

  static String _hex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static (double, double, double) _linearRgb(Color color) => (
        _linear(color.r),
        _linear(color.g),
        _linear(color.b),
      );

  static double _linear(double channel) =>
      channel <= 0.04045 ? channel / 12.92 : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  static double _gamma(double channel) =>
      channel <= 0.0031308 ? 12.92 * channel : 1.055 * math.pow(channel, 1 / 2.4) - 0.055;

  static double _ks(double reflectance) {
    final r = reflectance.clamp(0.003, 1.0);
    final t = 1 - r;
    return (t * t) / (2 * r);
  }

  static double _reflectance(double ks) {
    final k = ks.clamp(0.0, 1e6);
    return (1 + k - math.sqrt(k * k + 2 * k)).clamp(0.0, 1.0);
  }

  static int _toByte(double channel) => (channel.clamp(0.0, 1.0) * 255).round();
}
