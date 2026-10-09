import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/color_mixer_engine.dart';
import '../theme/app_colors.dart';

class ColorMixerScreen extends StatefulWidget {
  const ColorMixerScreen({super.key});

  @override
  State<ColorMixerScreen> createState() => _ColorMixerScreenState();
}

class _ColorMixerScreenState extends State<ColorMixerScreen> {
  final Map<String, int> _units = {};
  final List<String> _history = [];

  MixResult get _result => ColorMixerEngine.mix(_units);

  void _add(MixPigment pigment) {
    setState(() {
      _units[pigment.id] = (_units[pigment.id] ?? 0) + 1;
      _history.add(pigment.id);
    });
  }

  void _removeOne(String id) {
    final current = _units[id] ?? 0;
    if (current <= 0) return;
    setState(() {
      if (current == 1) {
        _units.remove(id);
      } else {
        _units[id] = current - 1;
      }
      final last = _history.lastIndexOf(id);
      if (last >= 0) _history.removeAt(last);
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    _removeOne(_history.last);
  }

  void _clear() {
    setState(() {
      _units.clear();
      _history.clear();
    });
  }

  Future<void> _copyHex(String hex) async {
    await Clipboard.setData(ClipboardData(text: hex));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'کد رنگ $hex کپی شد',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ترکیب رنگ',
          style: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.w800,
            color: AppColors.dark900,
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.dark800),
        actions: [
          IconButton(
            tooltip: 'حذف آخرین واحد',
            onPressed: _history.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            tooltip: 'پاک کردن ترکیب',
            onPressed: result.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(
            'هر رنگ را لمس کنید تا یک واحد به بوم اضافه شود. ترکیب مانند رنگ خوراکی و رنگدانه واقعی محاسبه می‌شود، نه میانگین ساده پیکسل.',
            style: GoogleFonts.vazirmatn(
              fontSize: 12.5,
              height: 1.8,
              color: AppColors.dark700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _MixCanvas(
            result: result,
            onCopy: result.isEmpty ? null : () => _copyHex(result.hex),
          ),
          if (!result.isEmpty) ...[
            const SizedBox(height: 16),
            _RecipeCard(result: result, onRemove: _removeOne, onAdd: _add),
          ],
          const SizedBox(height: 20),
          Text(
            'رنگ‌های پایه',
            style: GoogleFonts.vazirmatn(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.dark900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'برای شروع، دو یا چند رنگ را پشت‌سرهم لمس کنید.',
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              color: AppColors.warm400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _PigmentGrid(
            units: _units,
            onAdd: _add,
          ),
        ],
      ),
    );
  }
}

class _MixCanvas extends StatelessWidget {
  const _MixCanvas({required this.result, this.onCopy});

  final MixResult result;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final empty = result.isEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.cardShadowLg,
      ),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: empty ? const Color(0xFFF4EEE6) : result.color,
              border: empty
                  ? Border.all(color: AppColors.warm300, width: 1.4)
                  : null,
              boxShadow: empty
                  ? const []
                  : [
                      BoxShadow(
                        color: result.color.withValues(alpha: 0.38),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
            ),
            child: empty
                ? Icon(Icons.palette_outlined, size: 42, color: AppColors.warm400.withValues(alpha: 0.85))
                : const SizedBox.expand(),
          ),
          const SizedBox(height: 16),
          Text(
            empty ? 'بوم ترکیب خالی است' : result.name,
            style: GoogleFonts.vazirmatn(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.dark900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            empty
                ? 'یک رنگ پایه را از پایین انتخاب کنید'
                : '${ColorMixerEngine.toFa(result.totalUnits)} واحد رنگ',
            style: GoogleFonts.vazirmatn(
              fontSize: 12.5,
              color: AppColors.warm400,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!empty) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result.hex,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy_rounded, size: 16, color: AppColors.gold600),
                    const SizedBox(width: 4),
                    Text(
                      'کپی',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.result,
    required this.onRemove,
    required this.onAdd,
  });

  final MixResult result;
  final ValueChanged<String> onRemove;
  final ValueChanged<MixPigment> onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نسبت ترکیب',
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.dark900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.parts
                .map((part) =>
                    '${ColorMixerEngine.toFa(part.units)} واحد ${part.pigment.name}')
                .join('  +  '),
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              height: 1.7,
              color: AppColors.dark700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...result.parts.map(
            (part) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: part.pigment.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.warm300),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      part.pigment.name,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark800,
                      ),
                    ),
                  ),
                  Text(
                    ColorMixerEngine.percentLabel(part, result.totalUnits),
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold600,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onRemove(part.pigment.id),
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                  ),
                  Text(
                    ColorMixerEngine.toFa(part.units),
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark900,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onAdd(part.pigment),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PigmentGrid extends StatelessWidget {
  const _PigmentGrid({required this.units, required this.onAdd});

  final Map<String, int> units;
  final ValueChanged<MixPigment> onAdd;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ColorMixerEngine.pigments.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final pigment = ColorMixerEngine.pigments[index];
        final count = units[pigment.id] ?? 0;
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => onAdd(pigment),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: pigment.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: count > 0 ? AppColors.gold500 : AppColors.warm300,
                            width: count > 0 ? 2.2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: pigment.color.withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      if (count > 0)
                        Positioned(
                          top: -6,
                          left: -6,
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.gold500,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              ColorMixerEngine.toFa(count),
                              style: GoogleFonts.vazirmatn(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pigment.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
