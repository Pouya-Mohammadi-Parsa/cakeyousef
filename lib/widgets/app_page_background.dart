import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Soft atmospheric backdrop used across main surfaces.
class AppPageBackground extends StatelessWidget {
  final Widget child;

  const AppPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.isDark
                  ? [
                      const Color(0xFF16161F),
                      AppColors.cream,
                      const Color(0xFF101018),
                    ]
                  : [
                      const Color(0xFFFFFCF8),
                      AppColors.cream,
                      const Color(0xFFFFF4E8),
                    ],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: IgnorePointer(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold300.withValues(
                      alpha: AppColors.isDark ? 0.12 : 0.22,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: -90,
          child: IgnorePointer(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold500.withValues(
                      alpha: AppColors.isDark ? 0.08 : 0.12,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
