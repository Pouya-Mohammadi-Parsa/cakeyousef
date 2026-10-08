import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/content_api.dart';
import '../models/models.dart';

class StoriesRepository extends ChangeNotifier {
  StoriesRepository._();
  static final StoriesRepository instance = StoriesRepository._();

  final ContentApi _api = ContentApi();

  List<StoryItem> stories = const [];
  bool loading = false;
  String? error;

  bool get hasData => stories.isNotEmpty;

  Future<void> load({bool force = false}) async {
    if (loading) return;
    if (hasData && !force) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      stories = await _api.fetchStories();
    } on ApiException catch (e) {
      error = e.message;
      if (!hasData) stories = const [];
    } catch (e) {
      debugPrint('Stories load failed: $e');
      error = 'بارگذاری استوری‌ها ناموفق بود';
      if (!hasData) stories = const [];
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
}
