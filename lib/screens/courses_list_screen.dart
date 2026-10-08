import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/courses_repository.dart';
import '../models/models.dart';
import '../screens/course_detail_screen.dart';
import '../theme/app_colors.dart';
import '../utils/network_image.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final _repo = CoursesRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepo);
    _repo.load();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _repo.courseItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text(
            'دوره‌های آموزشی',
            style: GoogleFonts.vazirmatn(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.dark900,
            ),
          ),
        ),
        Expanded(child: _body(items)),
      ],
    );
  }

  Widget _body(List<CourseItem> items) {
    if (_repo.loading && !_repo.hasData) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold600),
      );
    }
    if (_repo.error != null && !_repo.hasData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_repo.error!, textAlign: TextAlign.center),
            TextButton(
              onPressed: () => _repo.load(force: true),
              child: Text('تلاش مجدد',
                  style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold600,
      onRefresh: () => _repo.load(force: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final c = items[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CourseDetailScreen(course: c),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: c.imageUrl != null
                            ? AppNetworkImage(
                                url: c.imageUrl!,
                                width: 72,
                                height: 72,
                                errorWidget: ColoredBox(
                                  color: c.gradientColors.first,
                                  child: Center(
                                      child: Text(c.emoji,
                                          style: const TextStyle(fontSize: 28))),
                                ),
                              )
                            : ColoredBox(
                                color: c.gradientColors.first,
                                child: Center(
                                    child: Text(c.emoji,
                                        style: const TextStyle(fontSize: 28))),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.vazirmatn(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: AppColors.dark900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.instructor,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 11,
                              color: AppColors.warm400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${c.price} تومان',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded,
                        color: AppColors.warm400),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
