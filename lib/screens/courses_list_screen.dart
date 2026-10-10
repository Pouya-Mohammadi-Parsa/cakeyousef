import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../screens/course_detail_screen.dart';
import '../state/courses_repository.dart';
import '../theme/app_colors.dart';
import '../utils/network_image.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final _repo = CoursesRepository.instance;
  String _category = 'همه';

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
    if (!mounted) return;
    setState(() {
      if (!_repo.categories.contains(_category)) {
        _category = 'همه';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _repo.filteredItems(_category);
    final categories = _repo.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دوره‌های آموزشی',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark900,
                      ),
                    ),
                    Text(
                      'از آکادمی کیک یوسف',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: AppColors.warm400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} دوره',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final selected = cat == _category;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.goldGradient : null,
                    color: selected ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Text(
                    cat,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.dark700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _repo.error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark700,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _repo.load(force: true),
                child: Text(
                  'تلاش مجدد',
                  style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'دوره‌ای در این دسته نیست',
          style: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.w600,
            color: AppColors.warm400,
          ),
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
          final categoryLabel =
              c.tags.isNotEmpty ? c.tags.first.label : '';
          return Material(
            color: AppColors.card,
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
                        width: 84,
                        height: 84,
                        child: c.imageUrl != null
                            ? AppNetworkImage(
                                url: c.imageUrl!,
                                width: 84,
                                height: 84,
                                errorWidget: ColoredBox(
                                  color: c.gradientColors.first,
                                  child: Center(
                                    child: Text(
                                      c.emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                              )
                            : ColoredBox(
                                color: c.gradientColors.first,
                                child: Center(
                                  child: Text(
                                    c.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (categoryLabel.isNotEmpty) ...[
                            Text(
                              categoryLabel,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold700,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
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
                          if (c.description != null &&
                              c.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              c.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 11,
                                height: 1.45,
                                color: AppColors.dark700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.instructor,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 11,
                                    color: AppColors.warm400,
                                  ),
                                ),
                              ),
                              Text(
                                c.isFree ? c.price : '${c.price} تومان',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.gold700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_left_rounded, color: AppColors.warm400),
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
