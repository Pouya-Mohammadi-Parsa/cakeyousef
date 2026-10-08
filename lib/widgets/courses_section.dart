import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/courses_repository.dart';
import '../theme/app_colors.dart';
import '../utils/app_nav.dart';
import 'course_card.dart';
import 'section_header.dart';

class PopularCoursesSection extends StatefulWidget {
  const PopularCoursesSection({super.key});

  @override
  State<PopularCoursesSection> createState() => _PopularCoursesSectionState();
}

class _PopularCoursesSectionState extends State<PopularCoursesSection> {
  final _repo = CoursesRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final courses = _repo.homePreview;
        return Column(
          children: [
            SectionHeader(
              title: 'دوره‌های آموزشی ما',
              onSeeAll: () => MainTabScope.go(context, 1),
            ),
            const SizedBox(height: 12),
            if (_repo.loading && !_repo.hasData)
              const SizedBox(
                height: 220,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold600),
                ),
              )
            else if (!_repo.hasData)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'هنوز دوره‌ای متصل نشده — منتظر API دوره‌ها',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warm400,
                  ),
                ),
              )
            else
              SizedBox(
                height: 420,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) =>
                      CourseCard(course: courses[index]),
                ),
              ),
          ],
        );
      },
    );
  }
}
