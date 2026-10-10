import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../screens/color_mixer_screen.dart';
import '../screens/courses_list_screen.dart';
import '../screens/material_calculator_screen.dart';
import '../screens/messenger_screen.dart';
import '../screens/shop_screen.dart';
import '../theme/app_colors.dart';

/// App navigation shortcuts (not catalog mock data).
const _quickAccess = <QuickAccessItem>[
  QuickAccessItem(
    title: 'فروشگاه',
    icon: Icons.shopping_bag_rounded,
    iconColor: Color(0xFF7C3AED),
    bgColor: Color(0xFFF3E8FF),
    artwork: 'assets/images/quick/shop.png',
  ),
  QuickAccessItem(
    title: 'دوره‌های من',
    icon: Icons.menu_book_rounded,
    iconColor: Color(0xFF2563EB),
    bgColor: Color(0xFFDBEAFE),
    artwork: 'assets/images/quick/courses.png',
  ),
  QuickAccessItem(
    title: 'پشتیبانی',
    icon: Icons.headset_mic_rounded,
    iconColor: Color(0xFFD97706),
    bgColor: Color(0xFFFEF3C7),
    artwork: 'assets/images/quick/support.png',
  ),
  QuickAccessItem(
    title: 'محاسبه مواد',
    icon: Icons.calculate_rounded,
    iconColor: Color(0xFFEA580C),
    bgColor: Color(0xFFFFEDD5),
    artwork: 'assets/images/quick/calculator.png',
  ),
  QuickAccessItem(
    title: 'ترکیب رنگ',
    icon: Icons.palette_rounded,
    iconColor: Color(0xFFDB2777),
    bgColor: Color(0xFFFCE7F3),
    artwork: 'assets/images/quick/color.png',
  ),
];

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  void _open(BuildContext context, QuickAccessItem item) {
    if (item.title == 'ترکیب رنگ') {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ColorMixerScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
      return;
    }

    if (item.title == 'محاسبه مواد') {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MaterialCalculatorScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
      return;
    }

    final Widget body = switch (item.title) {
      'فروشگاه' => const ShopScreen(),
      'دوره‌های من' => const CoursesListScreen(),
      'پشتیبانی' => const MessengerScreen(),
      _ => _SectionPlaceholder(title: item.title, icon: item.icon),
    };

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.card,
            elevation: 0,
            title: Text(
              item.title,
              style: GoogleFonts.vazirmatn(
                fontWeight: FontWeight.w800,
                color: AppColors.dark900,
                fontSize: 16,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.dark800),
          ),
          body: body,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _quickAccess.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final item = _quickAccess[index];
          return _AccessCard(
            item: item,
            onTap: () => _open(context, item),
          );
        },
      ),
    );
  }
}

class _AccessCard extends StatefulWidget {
  const _AccessCard({required this.item, required this.onTap});

  final QuickAccessItem item;
  final VoidCallback onTap;

  @override
  State<_AccessCard> createState() => _AccessCardState();
}

class _AccessCardState extends State<_AccessCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.warm200.withValues(alpha: 0.55),
            ),
            boxShadow: AppColors.cardShadow,
          ),
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.isDark
                        ? AppColors.creamDark
                        : widget.item.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.item.artwork != null
                      ? Image.asset(
                          widget.item.artwork!,
                          fit: BoxFit.contain,
                          cacheWidth: 160,
                          errorBuilder: (_, __, ___) => Icon(
                            widget.item.icon,
                            color: widget.item.iconColor,
                            size: 28,
                          ),
                        )
                      : Icon(
                          widget.item.icon,
                          color: widget.item.iconColor,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.title,
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
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.warm400),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.vazirmatn(
              fontWeight: FontWeight.w800,
              color: AppColors.dark800,
            ),
          ),
        ],
      ),
    );
  }
}
