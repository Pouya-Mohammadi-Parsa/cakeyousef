import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/content_api.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

class StoriesRepository extends ChangeNotifier {
  StoriesRepository._();
  static final StoriesRepository instance = StoriesRepository._();

  final ContentApi _api = ContentApi();

  List<StoryItem> stories = List<StoryItem>.of(_demoStories);
  bool loading = false;
  String? error;
  bool _fromApi = false;

  bool get hasData => stories.isNotEmpty;

  Future<void> load({bool force = false}) async {
    if (loading) return;
    if (_fromApi && hasData && !force) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final remote = await _api.fetchStories();
      if (remote.isNotEmpty) {
        stories = remote;
        _fromApi = true;
        error = null;
      } else if (!_fromApi) {
        stories = List<StoryItem>.of(_demoStories);
      }
    } on ApiException catch (e) {
      error = e.message;
      if (!_fromApi) {
        stories = List<StoryItem>.of(_demoStories);
      }
    } catch (e) {
      debugPrint('Stories load failed: $e');
      error = 'بارگذاری استوری‌ها ناموفق بود';
      if (!_fromApi) {
        stories = List<StoryItem>.of(_demoStories);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void markSeen(String storyId) {
    final index = stories.indexWhere((s) => s.id == storyId);
    if (index < 0 || stories[index].seen) return;
    final next = List<StoryItem>.of(stories);
    next[index] = stories[index].copyWith(seen: true);
    stories = next;
    notifyListeners();
  }

  static const List<StoryItem> _demoStories = [
    StoryItem(
      id: 'demo-1',
      username: 'کیک‌اکادمی',
      emoji: 'ک',
      avatarGradient: [AppColors.gold300, AppColors.gold600],
      coverAsset: 'assets/images/calculator/image1.jpeg',
      pages: [
        StoryPage(
          emoji: 'ک',
          caption: 'نمونه استوری کیک‌اکادمی',
          gradientColors: [Color(0xFF1A1A2E), Color(0xFF3D3D56)],
          imageAsset: 'assets/images/calculator/image1.jpeg',
        ),
      ],
    ),
    StoryItem(
      id: 'demo-2',
      username: 'آموزش کیک',
      emoji: 'آ',
      avatarGradient: [Color(0xFFF58529), Color(0xFFDD2A7B)],
      coverAsset: 'assets/images/calculator/image12.jpg',
      pages: [
        StoryPage(
          emoji: 'آ',
          caption: 'آموزش تزیین کیک',
          gradientColors: [Color(0xFF1A1A2E), Color(0xFF3D3D56)],
          imageAsset: 'assets/images/calculator/image12.jpg',
        ),
      ],
    ),
    StoryItem(
      id: 'demo-3',
      username: 'شیرینی',
      emoji: 'ش',
      avatarGradient: [Color(0xFFFFE599), Color(0xFFB8912E)],
      coverAsset: 'assets/images/calculator/image16.jpeg',
      pages: [
        StoryPage(
          emoji: 'ش',
          caption: 'شیرینی خانگی',
          gradientColors: [Color(0xFF1A1A2E), Color(0xFF3D3D56)],
          imageAsset: 'assets/images/calculator/image16.jpeg',
        ),
      ],
    ),
    StoryItem(
      id: 'demo-4',
      username: 'کرم‌کیک',
      emoji: 'ک',
      avatarGradient: [Color(0xFF8134AF), Color(0xFF515BD4)],
      coverAsset: 'assets/images/calculator/image20.jpeg',
      pages: [
        StoryPage(
          emoji: 'ک',
          caption: 'کرم و فیلینگ',
          gradientColors: [Color(0xFF1A1A2E), Color(0xFF3D3D56)],
          imageAsset: 'assets/images/calculator/image20.jpeg',
        ),
      ],
    ),
    StoryItem(
      id: 'demo-5',
      username: 'دسر',
      emoji: 'د',
      avatarGradient: [Color(0xFFFEDA77), Color(0xFFF58529)],
      coverAsset: 'assets/images/calculator/image25.jpeg',
      pages: [
        StoryPage(
          emoji: 'د',
          caption: 'دسرهای خاص',
          gradientColors: [Color(0xFF1A1A2E), Color(0xFF3D3D56)],
          imageAsset: 'assets/images/calculator/image25.jpeg',
        ),
      ],
    ),
  ];
}
