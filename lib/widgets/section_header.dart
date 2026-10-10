import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 22,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.vazirmatn(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.dark900,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (onSeeAll != null)
            Material(
              color: AppColors.gold50,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onSeeAll,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        'مشاهده همه',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: AppColors.gold700,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
