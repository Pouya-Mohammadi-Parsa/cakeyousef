import 'package:flutter/material.dart';

import '../api/api_config.dart';
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
  final int? originalPriceValue;
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
    this.originalPriceValue,
    this.imageUrls = const [],
  });

  factory ShopProductDto.fromJson(Map<String, dynamic> json) {
    final id = '${json['id'] ?? json['legacyId'] ?? ''}';
    final title = json['title']?.toString().trim() ?? '';
    final description = json['description']?.toString().trim() ?? '';
    final longDescription = json['longDescription']?.toString();
    final image = ApiConfig.mediaUrl(
      json['image']?.toString() ?? json['imageUrl']?.toString(),
    );
    final imagesRaw = json['images'] ?? json['imageUrls'];
    final images = <String>[];
    if (imagesRaw is List) {
      for (final item in imagesRaw) {
        final url = ApiConfig.mediaUrl(item?.toString());
        if (url.isNotEmpty && !images.contains(url)) images.add(url);
      }
    }
    if (image.isNotEmpty && !images.contains(image)) {
      images.insert(0, image);
    }

    final price = _asInt(json['price'] ?? json['priceValue']);
    final original = json['originalPrice'] ?? json['originalPriceValue'];
    final originalPrice = original == null ? null : _asInt(original);

    return ShopProductDto(
      id: id,
      title: title,
      description: description,
      longDescription: longDescription,
      priceValue: price,
      originalPriceValue:
          originalPrice != null && originalPrice > 0 ? originalPrice : null,
      category: json['category']?.toString().trim() ?? '',
      imageUrl: images.isNotEmpty ? images.first : image,
      imageUrls: images,
      inStock: json['inStock'] != false,
    );
  }

  String get priceLabel => formatPriceFa(priceValue);

  String? get oldPriceLabel => originalPriceValue == null ||
          originalPriceValue! <= 0 ||
          originalPriceValue == priceValue
      ? null
      : formatPriceFa(originalPriceValue!);

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

  bool get hasDiscount =>
      originalPriceValue != null &&
      originalPriceValue! > priceValue &&
      priceValue > 0;

  String? get discountLabel {
    if (!hasDiscount) return null;
    final pct =
        (((originalPriceValue! - priceValue) / originalPriceValue!) * 100)
            .round();
    return toFaDigits('$pct٪');
  }
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
  final List<CourseLesson> lessonItems;
  final int students;
  final double rating;
  final String category;
  final List<String> tags;
  final List<String> whatYouWillLearn;
  final List<String> requirements;
  final List<String> features;
  final bool? hasPurchased;
  final String courseType;
  final bool featured;
  final bool onlineSupport;
  final bool finalExam;

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
    required this.lessonItems,
    required this.students,
    required this.rating,
    required this.category,
    required this.tags,
    required this.whatYouWillLearn,
    required this.requirements,
    this.features = const [],
    this.longDescription,
    this.originalPriceValue,
    this.hasPurchased,
    this.courseType = '',
    this.featured = false,
    this.onlineSupport = false,
    this.finalExam = false,
  });

  List<String> get lessons =>
      lessonItems.map((e) => e.title).toList(growable: false);

  factory CourseDto.fromJson(Map<String, dynamic> json) {
    final id = '${json['id'] ?? json['legacyId'] ?? ''}';
    final slug = json['slug']?.toString().trim() ?? '';
    final title = json['title']?.toString().trim() ?? '';
    final subtitle = json['subtitle']?.toString().trim() ?? '';
    final description = json['description']?.toString().trim() ?? '';
    final longDescription = json['longDescription']?.toString();
    final image = ApiConfig.mediaUrl(
      json['image']?.toString() ?? json['imageUrl']?.toString(),
    );
    final price = _asInt(json['price'] ?? json['priceValue']);
    final original = json['originalPrice'] ?? json['originalPriceValue'];
    final originalPrice = original == null ? null : _asInt(original);

    return CourseDto(
      id: id.isEmpty ? slug : id,
      slug: slug.isEmpty ? id : slug,
      title: title,
      subtitle: subtitle,
      description: description,
      longDescription: longDescription,
      imageUrl: image,
      priceValue: price,
      originalPriceValue:
          originalPrice != null && originalPrice > 0 ? originalPrice : null,
      instructor: json['instructor']?.toString().trim() ?? '',
      instructorAvatar: ApiConfig.mediaUrl(
        json['instructorAvatar']?.toString() ?? json['avatar']?.toString(),
      ),
      instructorBio: json['instructorBio']?.toString().trim() ?? '',
      level: json['level']?.toString().trim() ?? '',
      duration: json['duration']?.toString().trim() ?? '',
      lessonItems: _lessonItems(json['lessons']),
      students: _asInt(json['students']),
      rating: _asDouble(json['rating']),
      category: json['category']?.toString().trim() ?? '',
      tags: _stringList(json['tags']),
      whatYouWillLearn: _stringList(json['whatYouWillLearn']),
      requirements: _stringList(json['requirements']),
      features: _stringList(json['features']),
      hasPurchased: json['hasPurchased'] is bool
          ? json['hasPurchased'] as bool
          : null,
      courseType: json['courseType']?.toString().trim() ?? '',
      featured: json['featured'] == true,
      onlineSupport: json['onlineSupport'] == true,
      finalExam: json['finalExam'] == true,
    );
  }

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
      lessonItems.isNotEmpty ||
      whatYouWillLearn.isNotEmpty;

  bool get hasPlayableLessons =>
      lessonItems.any((l) => l.hasVideo);

  CourseItem toCourseItem({bool forDetail = false}) {
    final discount = (originalPriceValue != null &&
            originalPriceValue! > priceValue &&
            originalPriceValue! > 0)
        ? '${(((originalPriceValue! - priceValue) / originalPriceValue!) * 100).round()}٪'
        : null;

    final blurb = forDetail ? plainDescription : listBlurb;
    final lessonCountLabel = lessonItems.isEmpty
        ? null
        : '${toFaDigits('${lessonItems.length}')} درس';

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
      lessons: duration.isNotEmpty ? duration : lessonCountLabel,
      id: id,
      slug: slug,
      studentsLabel: toFaDigits('$students'),
      chapterTitles: lessons.isNotEmpty ? lessons : whatYouWillLearn,
      videoLessons: lessonItems,
      siteUrl: siteUrl,
      learnPoints: whatYouWillLearn,
      requirements: requirements,
      featureLabels: features,
      level: level,
      durationLabel: duration,
      hasPurchased: hasPurchased,
      instructorAvatar: instructorAvatar.isEmpty ? null : instructorAvatar,
      instructorBio: instructorBio.isEmpty ? null : instructorBio,
      courseType: courseType.isEmpty ? null : courseType,
      onlineSupport: onlineSupport,
      finalExam: finalExam,
      category: category.isEmpty ? null : category,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((e) => e?.toString().trim() ?? '')
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
}

List<CourseLesson> _lessonItems(dynamic raw) {
  if (raw is! List) return const [];
  final out = <CourseLesson>[];
  for (var i = 0; i < raw.length; i++) {
    final item = raw[i];
    if (item is String) {
      final t = item.trim();
      if (t.isEmpty) continue;
      out.add(CourseLesson(
        id: '$i',
        title: t,
        duration: '',
        isFree: false,
        videoUrl: '',
      ));
    } else if (item is Map) {
      out.add(
        CourseLesson.fromJson(Map<String, dynamic>.from(item), index: i),
      );
    }
  }
  return out;
}
