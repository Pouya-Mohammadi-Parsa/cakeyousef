import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/course_detail_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/network_image.dart';

class CourseCard extends StatelessWidget {
  final CourseItem course;

  const CourseCard({super.key, required this.course});

  void _open(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CourseDetailScreen(course: course),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadowLg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 144,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: course.gradientColors,
                    ),
                  ),
                  child: Center(
                    child: Text(course.emoji, style: const TextStyle(fontSize: 48)),
                  ),
                ),
                if (course.imageUrl != null)
                  AppNetworkImage(
                    url: course.imageUrl!,
                    width: 260,
                    height: 144,
                    errorWidget: const SizedBox.shrink(),
                  ),
                if (course.discount != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course.discount!,
                        style: AppFonts.vazirmatn(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold600,
                        ),
                      ),
                    ),
                  ),
                if (course.badge != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: course.badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course.badge!,
                        style: AppFonts.vazirmatn(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: course.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tag.bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag.label,
                            style: AppFonts.vazirmatn(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: tag.fg,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark900,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  course.instructor,
                  style: AppFonts.vazirmatn(
                    fontSize: 12,
                    color: AppColors.warm400,
                  ),
                ),
                if (course.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    course.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.vazirmatn(
                      fontSize: 11,
                      color: AppColors.dark700.withValues(alpha: 0.75),
                      height: 1.6,
                    ),
                  ),
                ],
                if (course.lessons != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline,
                          size: 14, color: AppColors.gold600),
                      const SizedBox(width: 4),
                      Text(
                        course.lessons!,
                        style: AppFonts.vazirmatn(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.gold400),
                    const SizedBox(width: 2),
                    Text(
                      course.rating,
                      style: AppFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.reviews,
                      style: AppFonts.vazirmatn(
                        fontSize: 12,
                        color: AppColors.warm400,
                      ),
                    ),
                    const Spacer(),
                    if (course.isFree)
                      Text(
                        'رایگان',
                        style: AppFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF16A34A),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (course.oldPrice != null)
                            Text(
                              '${course.oldPrice} تومان',
                              style: AppFonts.vazirmatn(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.warm400,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.warm400,
                              ),
                            ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: course.price,
                                  style: AppFonts.vazirmatn(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.dark900,
                                  ),
                                ),
                                TextSpan(
                                  text: ' تومان',
                                  style: AppFonts.vazirmatn(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.warm400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
