import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          // Force LTR so left/right icons stay physically correct
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              height: 92,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: notification bell
                  _IconButton(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.dark700,
                          size: 22,
                        ),
                        Positioned(
                          top: -4,
                          left: -4,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '۳',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center: logo + name
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 58,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'آکادمی کیک یوسف',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: hamburger menu
                  _IconButton(
                    onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.dark700,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.warm400, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.right,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark800,
                    ),
                    decoration: InputDecoration(
                      hintText: 'دنبال چه آموزشی هستی؟',
                      hintStyle: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warm400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppColors.warm400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _IconButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
