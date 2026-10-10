import 'package:flutter/material.dart';

import '../utils/format_utils.dart';

class CourseLesson {
  final String id;
  final String title;
  final String duration;
  final bool isFree;
  final String videoUrl;

  const CourseLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.isFree,
    required this.videoUrl,
  });

  bool get hasVideo => videoUrl.trim().isNotEmpty;

  String get durationLabel {
    final d = duration.trim();
    if (d.isEmpty || d == '00:00' || d == '0:00') return '';
    return toFaDigits(d);
  }

  factory CourseLesson.fromJson(Map<String, dynamic> json, {int index = 0}) {
    final id = '${json['id'] ?? index}';
    return CourseLesson(
      id: id.isEmpty ? '$index' : id,
      title: json['title']?.toString().trim() ?? 'درس ${index + 1}',
      duration: json['duration']?.toString().trim() ?? '',
      isFree: json['isFree'] == true,
      videoUrl: json['videoUrl']?.toString().trim() ??
          json['url']?.toString().trim() ??
          '',
    );
  }
}

class QuickAccessItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String? artwork;

  const QuickAccessItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.artwork,
  });
}

class CourseItem {
  final String emoji;
  final String title;
  final String instructor;
  final String price;
  final String? oldPrice;
  final String rating;
  final String reviews;
  final List<CourseTag> tags;
  final String? discount;
  final String? badge;
  final Color badgeColor;
  final List<Color> gradientColors;
  final bool isFree;
  final String? imageUrl;
  final String? description;
  final String? lessons;
  final String? id;
  final String? slug;
  final String? studentsLabel;
  final List<String> chapterTitles;
  final List<CourseLesson> videoLessons;
  final String? siteUrl;
  final List<String> learnPoints;
  final List<String> requirements;
  final List<String> featureLabels;
  final String? level;
  final String? durationLabel;
  final bool? hasPurchased;
  final String? instructorAvatar;
  final String? instructorBio;
  final String? courseType;
  final bool onlineSupport;
  final bool finalExam;
  final String? category;

  const CourseItem({
    required this.emoji,
    required this.title,
    required this.instructor,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.tags,
    required this.gradientColors,
    this.oldPrice,
    this.discount,
    this.badge,
    this.badgeColor = Colors.red,
    this.isFree = false,
    this.imageUrl,
    this.description,
    this.lessons,
    this.id,
    this.slug,
    this.studentsLabel,
    this.chapterTitles = const [],
    this.videoLessons = const [],
    this.siteUrl,
    this.learnPoints = const [],
    this.requirements = const [],
    this.featureLabels = const [],
    this.level,
    this.durationLabel,
    this.hasPurchased,
    this.instructorAvatar,
    this.instructorBio,
    this.courseType,
    this.onlineSupport = false,
    this.finalExam = false,
    this.category,
  });

  bool get canAccessAllVideos => isFree || hasPurchased == true;

  CourseLesson? get firstPlayableLesson {
    for (final l in videoLessons) {
      if (!l.hasVideo) continue;
      if (canAccessAllVideos || l.isFree) return l;
    }
    return null;
  }
}

class CourseTag {
  final String label;
  final Color bg;
  final Color fg;

  const CourseTag({required this.label, required this.bg, required this.fg});
}

class StoryItem {
  final String id;
  final String username;
  final String emoji;
  final List<Color> avatarGradient;
  final List<StoryPage> pages;
  final bool isMine;
  final bool seen;
  final String? coverAsset;

  const StoryItem({
    required this.id,
    required this.username,
    required this.emoji,
    required this.avatarGradient,
    required this.pages,
    this.isMine = false,
    this.seen = false,
    this.coverAsset,
  });

  StoryItem copyWith({bool? seen}) {
    return StoryItem(
      id: id,
      username: username,
      emoji: emoji,
      avatarGradient: avatarGradient,
      pages: pages,
      isMine: isMine,
      seen: seen ?? this.seen,
      coverAsset: coverAsset,
    );
  }
}

class StoryPage {
  final String emoji;
  final String caption;
  final List<Color> gradientColors;
  final String timeAgo;
  final String? imageAsset;

  const StoryPage({
    required this.emoji,
    required this.caption,
    required this.gradientColors,
    this.timeAgo = '۲س',
    this.imageAsset,
  });
}

enum ChatKind { support, channel, direct }

class ChatMessage {
  final String id;
  final String text;
  final bool isMine;
  final String time;
  final bool isSystem;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    this.isMine = false,
    this.isSystem = false,
  });
}

class ChatConversation {
  final String id;
  final String title;
  final String subtitle;
  final String lastMessage;
  final String time;
  final int unread;
  final ChatKind kind;
  final bool pinned;
  final bool verified;
  final bool online;
  final String? avatarAsset;
  final IconData? avatarIcon;
  final List<Color> avatarGradient;
  final String? externalUrl;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lastMessage,
    required this.time,
    required this.kind,
    required this.avatarGradient,
    required this.messages,
    this.unread = 0,
    this.pinned = false,
    this.verified = false,
    this.online = false,
    this.avatarAsset,
    this.avatarIcon,
    this.externalUrl,
  });
}
