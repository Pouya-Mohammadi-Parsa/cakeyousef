import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/content_api.dart';
import '../models/catalog_models.dart';
import '../models/models.dart';

/// Courses catalog from `/api/content/courses`.
class CoursesRepository extends ChangeNotifier {
  CoursesRepository._();
  static final CoursesRepository instance = CoursesRepository._();

  final ContentApi _api = ContentApi();

  List<CourseDto> courses = const [];
  List<CourseItem> _courseItems = const [];
  List<String> categories = const ['همه'];
  bool loading = false;
  String? error;
  bool _fromApi = false;

  bool get hasData => courses.isNotEmpty;

  List<CourseItem> get courseItems => _courseItems;

  static const int homePreviewCount = 6;

  List<CourseItem> get homePreview {
    final featured = _courseItems
        .where((c) => courses.any((d) => d.id == c.id && d.featured))
        .toList();
    final source = featured.isNotEmpty ? featured : _courseItems;
    return source.take(homePreviewCount).toList(growable: false);
  }

  List<CourseDto> filtered(String category) {
    if (category.isEmpty || category == 'همه') return courses;
    return courses.where((c) => c.category == category).toList();
  }

  List<CourseItem> filteredItems(String category) {
    return filtered(category)
        .map((c) => c.toCourseItem())
        .toList(growable: false);
  }

  Future<void> load({bool force = false}) async {
    if (loading) return;
    if (_fromApi && hasData && !force) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final remote = await _api.fetchCourses();
      if (remote.isNotEmpty) {
        courses = remote;
        _courseItems =
            remote.map((c) => c.toCourseItem()).toList(growable: false);
        categories = _buildCategories(remote);
        _fromApi = true;
        error = null;
      } else if (!_fromApi) {
        courses = const [];
        _courseItems = const [];
        categories = const ['همه'];
        error = 'دوره‌ای یافت نشد';
      }
    } on ApiException catch (e) {
      error = e.message;
      if (!_fromApi) {
        courses = const [];
        _courseItems = const [];
        categories = const ['همه'];
      }
    } catch (e) {
      debugPrint('Courses load failed: $e');
      error = 'بارگذاری دوره‌ها ناموفق بود';
      if (!_fromApi) {
        courses = const [];
        _courseItems = const [];
        categories = const ['همه'];
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<CourseDto> fetchDetail(String slugOrId, {bool forceRemote = true}) async {
    final match =
        courses.where((c) => c.slug == slugOrId || c.id == slugOrId);
    final cached = match.isEmpty ? null : match.first;

    // Prefer remote detail so lesson video URLs are fresh.
    if (forceRemote || cached == null || !cached.hasPlayableLessons) {
      try {
        final detail = await _api.fetchCourseDetail(slugOrId);
        _upsert(detail);
        return detail;
      } on ApiException {
        if (cached != null) return cached;
        rethrow;
      } catch (_) {
        if (cached != null) return cached;
        throw StateError('دوره یافت نشد');
      }
    }
    return cached;
  }

  void _upsert(CourseDto detail) {
    final next = List<CourseDto>.of(courses);
    final index = next.indexWhere(
      (c) => c.id == detail.id || c.slug == detail.slug,
    );
    if (index >= 0) {
      next[index] = detail;
    } else {
      next.add(detail);
    }
    courses = next;
    _courseItems = next.map((c) => c.toCourseItem()).toList(growable: false);
    categories = _buildCategories(next);
    notifyListeners();
  }

  static List<String> _buildCategories(List<CourseDto> items) {
    final seen = <String>{};
    final cats = <String>['همه'];
    for (final c in items) {
      final cat = c.category.trim();
      if (cat.isEmpty || seen.contains(cat)) continue;
      seen.add(cat);
      cats.add(cat);
    }
    return cats;
  }
}
