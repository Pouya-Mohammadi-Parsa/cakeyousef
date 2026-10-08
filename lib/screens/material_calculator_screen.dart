import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/material_calculator.dart';
import '../theme/app_colors.dart';

class MaterialCalculatorScreen extends StatefulWidget {
  const MaterialCalculatorScreen({super.key});

  @override
  State<MaterialCalculatorScreen> createState() =>
      _MaterialCalculatorScreenState();
}

class _MaterialCalculatorScreenState extends State<MaterialCalculatorScreen> {
  CakeExpertStore? _store;
  int _step = 0;
  int? _tiers;
  String? _shape;
  String? _height;
  String? _filling;
  CakeExpertCase? _selected;

  @override
  void initState() {
    super.initState();
    CakeExpertStore.load().then((store) {
      if (mounted) setState(() => _store = store);
    });
  }

  List<CakeExpertCase> get _filtered => _store == null
      ? const []
      : _store!.filter(
          tiers: _tiers,
          shape: _shape,
          height: _height,
          filling: _filling,
        );

  void _reset() {
    setState(() {
      _step = 0;
      _tiers = null;
      _shape = null;
      _height = null;
      _filling = null;
      _selected = null;
    });
  }

  String _previewImage() {
    final items = _filtered;
    if (items.isEmpty) return '';
    return items.first.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'محاسبه مواد',
          style: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.w800,
            color: AppColors.dark900,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.dark800),
        actions: [
          if (_step > 0)
            TextButton(
              onPressed: _reset,
              child: Text(
                'از نو',
                style: GoogleFonts.vazirmatn(
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold600,
                ),
              ),
            ),
        ],
      ),
      body: _store == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold500))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _StepBar(step: _step),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: switch (_step) {
                      0 => _ChoiceStep(
                          key: const ValueKey('tiers'),
                          title: 'کیک چند طبقه است؟',
                          items: _store!.tiers
                              .map((t) => _Choice(id: '$t', title: '$t طبقه'))
                              .toList(),
                          onSelect: (id) => setState(() {
                            _tiers = int.parse(id);
                            _step = 1;
                          }),
                        ),
                      1 => _ChoiceStep(
                          key: const ValueKey('shape'),
                          title: 'نوع قالب چیست؟',
                          items: _store!
                              .unique(_filtered, (c) => c.shape)
                              .map((s) => _Choice(id: s, title: s))
                              .toList(),
                          onBack: () => setState(() {
                            _step = 0;
                            _tiers = null;
                          }),
                          onSelect: (id) => setState(() {
                            _shape = id;
                            _step = 2;
                          }),
                        ),
                      2 => _ChoiceStep(
                          key: const ValueKey('height'),
                          title: 'ارتفاع کیک چطور باشد؟',
                          image: _previewImage(),
                          items: _store!
                              .unique(_filtered, (c) => c.height)
                              .map((s) => _Choice(id: s, title: s))
                              .toList(),
                          onBack: () => setState(() {
                            _step = 1;
                            _shape = null;
                          }),
                          onSelect: (id) => setState(() {
                            _height = id;
                            _step = 3;
                          }),
                        ),
                      3 => _ChoiceStep(
                          key: const ValueKey('filling'),
                          title: 'لایه فیلینگ کدام است؟',
                          image: _previewImage(),
                          items: _store!
                              .unique(_filtered, (c) => c.filling)
                              .map((s) => _Choice(id: s, title: s))
                              .toList(),
                          onBack: () => setState(() {
                            _step = 2;
                            _height = null;
                          }),
                          onSelect: (id) => setState(() {
                            _filling = id;
                            _step = 4;
                          }),
                        ),
                      4 => _ChoiceStep(
                          key: const ValueKey('weight'),
                          title: 'وزن کیک را انتخاب کنید',
                          image: _previewImage(),
                          items: _filtered
                              .map((c) => _Choice(id: c.weight, title: c.weight))
                              .toList(),
                          onBack: () => setState(() {
                            _step = 3;
                            _filling = null;
                          }),
                          onSelect: (id) => setState(() {
                            _selected = _filtered.firstWhere((c) => c.weight == id);
                            _step = 5;
                          }),
                        ),
                      _ => _ResultStep(
                          key: const ValueKey('result'),
                          item: _selected!,
                          onBack: () => setState(() {
                            _step = 4;
                            _selected = null;
                          }),
                          onReset: _reset,
                        ),
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _Choice {
  const _Choice({required this.id, required this.title});
  final String id;
  final String title;
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['طبقه', 'قالب', 'ارتفاع', 'فیلینگ', 'وزن', 'نتیجه'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Container(
                width: 18,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: step >= i ? AppColors.gold500 : AppColors.warm300,
              ),
            Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: step >= i ? AppColors.gold500 : AppColors.warm200,
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: step >= i ? Colors.white : AppColors.warm400,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: GoogleFonts.vazirmatn(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: step >= i ? AppColors.dark900 : AppColors.warm400,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceStep extends StatelessWidget {
  const _ChoiceStep({
    super.key,
    required this.title,
    required this.items,
    required this.onSelect,
    this.subtitle,
    this.image,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final String? image;
  final List<_Choice> items;
  final ValueChanged<String> onSelect;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          title,
          style: GoogleFonts.vazirmatn(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.dark900,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: GoogleFonts.vazirmatn(
              fontSize: 12.5,
              height: 1.8,
              color: AppColors.dark700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (image != null && image!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _CakeImage(path: image!),
        ],
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => onSelect(item.id),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark900,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_left_rounded, color: AppColors.warm400),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (onBack != null) ...[
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.dark800,
              side: const BorderSide(color: AppColors.warm300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('بازگشت', style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800)),
          ),
        ],
      ],
    );
  }
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({
    super.key,
    required this.item,
    required this.onBack,
    required this.onReset,
  });

  final CakeExpertCase item;
  final VoidCallback onBack;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final lines = item.parsedResult();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _CakeImage(path: item.image, tall: true),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.tiers} طبقه · ${item.shape} · ${item.height}',
                style: GoogleFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.filling} · ${item.weight}',
                style: GoogleFonts.vazirmatn(
                  fontSize: 12.5,
                  color: AppColors.dark700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...lines.map(
          (line) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    line.label,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark800,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    line.value,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: AppColors.dark800,
                  side: const BorderSide(color: AppColors.warm300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('وزن دیگر', style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: onReset,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.gold500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('محاسبه جدید', style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CakeImage extends StatelessWidget {
  const _CakeImage({required this.path, this.tall = false});

  final String path;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tall ? 280 : 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.cake_outlined, color: AppColors.warm400, size: 42),
        ),
      ),
    );
  }
}
