import 'dart:convert';

import 'package:flutter/services.dart';

class CakeExpertCase {
  const CakeExpertCase({
    required this.tiers,
    required this.shape,
    required this.height,
    required this.filling,
    required this.weight,
    required this.result,
    required this.image,
  });

  final int tiers;
  final String shape;
  final String height;
  final String filling;
  final String weight;
  final String result;
  final String image;

  factory CakeExpertCase.fromJson(Map<String, dynamic> json) {
    return CakeExpertCase(
      tiers: json['tiers'] as int,
      shape: (json['shape'] as String).trim(),
      height: (json['height'] as String).trim(),
      filling: (json['filling'] as String).trim(),
      weight: (json['weight'] as String).trim(),
      result: (json['result'] as String? ?? '').trim(),
      image: json['image'] as String,
    );
  }

  List<CakeResultLine> parsedResult() {
    if (result.isEmpty) {
      return [
        CakeResultLine(label: 'وزن کیک', value: weight),
        CakeResultLine(label: 'قالب', value: shape),
      ];
    }
    final lines = <CakeResultLine>[];
    final mold = RegExp(r'قالب مورد نیاز\s*(.+?)(?=تعداد تخم|خامه|$)').firstMatch(result);
    final eggs = RegExp(r'تخم مرغ\s*([\d/]+)\s*عدد').firstMatch(result);
    final fillingCream = RegExp(r'فیلینگ\s*([\d/]+(?:\s*کیلو)?(?:\s*گرم)?)').firstMatch(result);
    final cover = RegExp(r'(?:کاور|روکش)\s*([\d/]+(?:\s*کیلو)?(?:\s*گرم)?)').firstMatch(result);
    final banana = RegExp(r'([\d/]+(?:\s*کیلو)?(?:\s*گرم)?)\s*موز').firstMatch(result);
    if (mold != null) {
      lines.add(CakeResultLine(label: 'قالب', value: mold.group(1)!.trim()));
    }
    if (eggs != null) {
      lines.add(CakeResultLine(label: 'تخم‌مرغ', value: '${eggs.group(1)} عدد'));
    }
    if (fillingCream != null) {
      lines.add(CakeResultLine(label: 'خامه فیلینگ', value: fillingCream.group(1)!.trim()));
    }
    if (cover != null) {
      lines.add(CakeResultLine(label: 'خامه روکش', value: cover.group(1)!.trim()));
    }
    if (banana != null) {
      lines.add(CakeResultLine(label: 'موز فیلینگ', value: banana.group(1)!.trim()));
    }
    if (lines.isEmpty) {
      lines.add(CakeResultLine(label: 'نتیجه', value: result));
    }
    return lines;
  }
}

class CakeResultLine {
  const CakeResultLine({required this.label, required this.value});
  final String label;
  final String value;
}

class CakeExpertStore {
  CakeExpertStore._(this.cases);
  final List<CakeExpertCase> cases;

  static CakeExpertStore? _instance;

  static Future<CakeExpertStore> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString('assets/data/cake_expert.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _instance = CakeExpertStore._(
      list.map((e) => CakeExpertCase.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return _instance!;
  }

  List<int> get tiers =>
      cases.map((c) => c.tiers).toSet().toList()..sort();

  List<CakeExpertCase> filter({
    int? tiers,
    String? shape,
    String? height,
    String? filling,
  }) {
    return cases.where((c) {
      if (tiers != null && c.tiers != tiers) return false;
      if (shape != null && c.shape != shape) return false;
      if (height != null && c.height != height) return false;
      if (filling != null && c.filling != filling) return false;
      return true;
    }).toList();
  }

  List<String> unique(List<CakeExpertCase> items, String Function(CakeExpertCase) pick) {
    final seen = <String>{};
    final out = <String>[];
    for (final item in items) {
      final value = pick(item);
      if (value.isEmpty || !seen.add(value)) continue;
      out.add(value);
    }
    return out;
  }
}
