import 'package:flutter/foundation.dart';

import '../models/catalog_models.dart';
import '../models/models.dart';

/// Courses catalog — empty until API is wired.
class CoursesRepository extends ChangeNotifier {
  CoursesRepository._();
  static final CoursesRepository instance = CoursesRepository._();

  List<CourseDto> courses = const [];
  List<CourseItem> _courseItems = const [];
  bool loading = false;
  String? error;

  bool get hasData => courses.isNotEmpty;

  List<CourseItem> get courseItems => _courseItems;

  static const int homePreviewCount = 6;

  List<CourseItem> get homePreview =>
      _courseItems.take(homePreviewCount).toList(growable: false);

  Future<void> load({bool force = false}) async {
    if (loading) return;
    if (hasData && !force) return;

    loading = true;
    error = null;
    notifyListeners();

    // No mock / no API yet — intentionally empty.
    courses = const [];
    _courseItems = const [];
    loading = false;
    notifyListeners();
  }

  Future<CourseDto> fetchDetail(String slugOrId) async {
    final match =
        courses.where((c) => c.slug == slugOrId || c.id == slugOrId);
    if (match.isEmpty) {
      throw StateError('دوره یافت نشد — API هنوز متصل نیست');
    }
    return match.first;
  }
}
