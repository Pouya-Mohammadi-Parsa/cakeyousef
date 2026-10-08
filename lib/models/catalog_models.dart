import 'package:flutter/material.dart';

import '../config/site_config.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';

class ShopProductDto {
  final String id;
  final String title;
  final String description;
  final String? longDescription;
  final int priceValue;
  final String category;
  final String imageUrl;
  final List<String> imageUrls;
  final bool inStock;

  const ShopProductDto({
    required this.id,
    required this.title,
    required this.description,
    required this.priceValue,
    required this.category,
    required this.imageUrl,
    required this.inStock,
    this.longDescription,
    this.imageUrls = const [],
  });

  String get priceLabel => formatPriceFa(priceValue);

  String get siteUrl => SiteConfig.productCheckoutUrl(id);

  String get listBlurb {
    if (description.trim().isNotEmpty) return description.trim();
    return '';
  }

  String get plainDescription {
    final html = longDescription;
    if (html != null && html.trim().isNotEmpty) {
      return stripHtml(html);
    }
    return description;
  }

  bool get hasRichDetail =>
      (longDescription != null && longDescription!.trim().isNotEmpty) ||
      imageUrls.length > 1;
}

class CourseDto {
  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String description;
  final String? longDescription;
  final String imageUrl;
  final int priceValue;
  final int? originalPriceValue;
  final String instructor;
  final String instructorAvatar;
  final String instructorBio;
  final String level;
  final String duration;
  final List<String> lessons;
  final int students;
  final double rating;
  final String category;
  final List<String> tags;
  final List<String> whatYouWillLearn;
  final List<String> requirements;
  final bool? hasPurchased;

  const CourseDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.priceValue,
    required this.instructor,
    required this.instructorAvatar,
    required this.instructorBio,
    required this.level,
    required this.duration,
    required this.lessons,
    required this.students,
    required this.rating,
    required this.category,
    required this.tags,
    required this.whatYouWillLearn,
    required this.requirements,
    this.longDescription,
    this.originalPriceValue,
    this.hasPurchased,
  });

  String get priceLabel =>
      priceValue <= 0 ? 'رایگان' : formatPriceFa(priceValue);

  String? get oldPriceLabel => originalPriceValue == null ||
          originalPriceValue! <= 0 ||
          originalPriceValue == priceValue
      ? null
      : formatPriceFa(originalPriceValue!);

  String get listBlurb {
    if (subtitle.trim().isNotEmpty) return subtitle.trim();
    if (description.trim().isNotEmpty) return description.trim();
    return '';
  }

  String get plainDescription {
    final html = longDescription;
    if (html != null && html.trim().isNotEmpty) return stripHtml(html);
    if (description.trim().isNotEmpty) return description;
    return subtitle;
  }

  String get siteUrl => SiteConfig.courseCheckoutUrl(slug);

  bool get hasRichDetail =>
      (longDescription != null && longDescription!.trim().isNotEmpty) ||
      lessons.isNotEmpty ||
      whatYouWillLearn.isNotEmpty;

  CourseItem toCourseItem({bool forDetail = false}) {
    final discount = (originalPriceValue != null &&
            originalPriceValue! > priceValue &&
            originalPriceValue! > 0)
        ? '${(((originalPriceValue! - priceValue) / originalPriceValue!) * 100).round()}٪'
        : null;

    final blurb = forDetail ? plainDescription : listBlurb;

    return CourseItem(
      emoji: '🎂',
      title: title,
      instructor: instructor,
      price: priceLabel,
      oldPrice: oldPriceLabel,
      rating: toFaDigits(rating <= 0 ? '۵.۰' : rating.toStringAsFixed(1)),
      reviews: toFaDigits('$students'),
      tags: [
        if (category.isNotEmpty)
          CourseTag(
            label: category,
            bg: AppColors.gold50,
            fg: AppColors.gold700,
          ),
        ...tags.take(2).map(
              (t) => CourseTag(
                label: t,
                bg: const Color(0xFFFFF7ED),
                fg: AppColors.dark700,
              ),
            ),
      ],
      discount: discount == null ? null : toFaDigits(discount),
      badge: level.isNotEmpty ? level : null,
      badgeColor: AppColors.gold600,
      gradientColors: const [Color(0xFFF59E0B), Color(0xFFB45309)],
      isFree: priceValue <= 0,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      description: blurb.isEmpty ? null : blurb,
      lessons: duration.isNotEmpty
          ? duration
          : (lessons.isEmpty
              ? null
              : '${toFaDigits('${lessons.length}')} درس'),
      id: id,
      slug: slug,
      studentsLabel: toFaDigits('$students'),
      chapterTitles: lessons.isNotEmpty ? lessons : whatYouWillLearn,
      siteUrl: siteUrl,
      learnPoints: whatYouWillLearn,
      level: level,
      durationLabel: duration,
      hasPurchased: hasPurchased,
    );
  }
}
