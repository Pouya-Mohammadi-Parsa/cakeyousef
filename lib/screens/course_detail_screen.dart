import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../state/courses_repository.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import '../utils/network_image.dart';
import '../utils/payment_helper.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseItem course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late CourseItem course;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    course = widget.course;
    _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    final key = course.slug?.isNotEmpty == true ? course.slug! : course.id;
    if (key == null || key.isEmpty) return;
    final existing = CoursesRepository.instance.courses
        .where((c) => c.slug == key || c.id == key)
        .toList();
    if (existing.isNotEmpty && existing.first.hasRichDetail) {
      setState(() => course = existing.first.toCourseItem(forDetail: true));
      return;
    }
    setState(() => _loadingDetail = true);
    try {
      final dto = await CoursesRepository.instance.fetchDetail(key);
      if (!mounted) return;
      setState(() => course = dto.toCourseItem(forDetail: true));
    } catch (_) {
      // Keep list payload.
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  _CourseExtra get _extra {
    return _CourseExtra(
      students: course.studentsLabel ?? '۰',
      chapters: course.chapterTitles,
      siteUrl: course.siteUrl ?? '',
    );
  }

  Future<void> _openSite(BuildContext context) async {
    final raw = _extra.siteUrl;
    if (raw.isEmpty) return;
    final uri = Uri.parse(Uri.encodeFull(raw));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'امکان باز کردن صفحه دوره نیست',
            style: GoogleFonts.vazirmatn(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Future<void> _buy() {
    return checkoutCourseOnWebsite(
      context,
      slug: course.slug,
      fallbackUrl: _extra.siteUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final extra = _extra;
    final chapters = extra.chapters;
    final students = toFaDigits(extra.students);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.dark900,
                leading: _RoundIconButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                actions: [
                  _RoundIconButton(
                    icon: Icons.favorite_border_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 6),
                  _RoundIconButton(
                    icon: Icons.share_rounded,
                    onTap: () => _openSite(context),
                  ),
                  const SizedBox(width: 12),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_loadingDetail)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            color: AppColors.gold600,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: course.gradientColors,
                          ),
                        ),
                        child: Center(
                          child: Text(course.emoji, style: const TextStyle(fontSize: 88)),
                        ),
                      ),
                      if (course.imageUrl != null)
                        AppNetworkImage(
                          url: course.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: const SizedBox.shrink(),
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...course.tags.map((t) => _Chip(label: t.label)),
                                if (course.badge != null)
                                  _Chip(
                                    label: course.badge!,
                                    color: course.badgeColor,
                                    lightText: true,
                                  ),
                                if (course.discount != null)
                                  _Chip(
                                    label: course.discount!,
                                    color: AppColors.gold500,
                                    lightText: true,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              course.title,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppColors.cardShadowLg,
                      ),
                      child: Row(
                        children: [
                          _Stat(
                            icon: Icons.star_rounded,
                            value: course.rating,
                            label: course.reviews.replaceAll('(', '').replaceAll(')', ''),
                            color: AppColors.gold500,
                          ),
                          _VDivider(),
                          _Stat(
                            icon: Icons.play_circle_outline_rounded,
                            value: course.lessons?.replaceAll(' برنامه آموزشی', '') ?? '—',
                            label: 'برنامه آموزشی',
                            color: const Color(0xFF3B82F6),
                          ),
                          _VDivider(),
                          _Stat(
                            icon: Icons.people_alt_rounded,
                            value: students,
                            label: 'هنرجو',
                            color: const Color(0xFF22C55E),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructor
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.goldGradient,
                                boxShadow: AppColors.goldGlow,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                course.instructor.contains('بهمن') ? 'ب' : 'ی',
                                style: GoogleFonts.vazirmatn(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.instructor.replaceFirst('مدرس: ', ''),
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.dark900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'مدرس رسمی آکادمی کیک یوسف',
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.warm400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.gold50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF3B82F6)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'تأیید‌شده',
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gold700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),
                      _SectionTitle(title: 'درباره دوره', icon: Icons.info_outline_rounded),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Text(
                          course.description ?? 'توضیحات این دوره به‌زودی تکمیل می‌شود.',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.9,
                            color: AppColors.dark700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),
                      _SectionTitle(title: 'ویژگی‌های دوره', icon: Icons.auto_awesome_rounded),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          _FeatureCard(icon: Icons.all_inclusive_rounded, title: 'دسترسی مادام‌العمر'),
                          _FeatureCard(icon: Icons.support_agent_rounded, title: 'پشتیبانی آموزشی'),
                          _FeatureCard(icon: Icons.workspace_premium_rounded, title: 'محتوای حرفه‌ای'),
                          _FeatureCard(icon: Icons.update_rounded, title: 'آپدیت رایگان'),
                          _FeatureCard(icon: Icons.phone_android_rounded, title: 'مشاهده در موبایل'),
                          _FeatureCard(icon: Icons.hd_rounded, title: 'کیفیت HD'),
                        ],
                      ),

                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'سرفصل‌های دوره',
                        icon: Icons.menu_book_rounded,
                        trailing: chapters.isEmpty
                            ? null
                            : '${toFaDigits('${chapters.length}')} فصل',
                      ),
                      const SizedBox(height: 10),
                      if (chapters.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            course.lessons != null
                                ? 'این دوره شامل ${course.lessons} است.'
                                : 'سرفصل‌ها به‌زودی اضافه می‌شوند.',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 13,
                              color: AppColors.dark700,
                            ),
                          ),
                        )
                      else
                        ...List.generate(chapters.length, (i) {
                          return _ChapterTile(
                            index: i + 1,
                            title: chapters[i],
                            faIndex: toFaDigits('${i + 1}'),
                          );
                        }),

                      const SizedBox(height: 22),
                      _SectionTitle(title: 'منبع رسمی', icon: Icons.public_rounded),
                      const SizedBox(height: 10),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () => _openSite(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.gold50,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.open_in_new_rounded, color: AppColors.gold600),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'مشاهده در سایت کیک یوسف',
                                        style: GoogleFonts.vazirmatn(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.dark900,
                                        ),
                                      ),
                                      Text(
                                        'cakeyousef.ir',
                                        style: GoogleFonts.vazirmatn(
                                          fontSize: 11,
                                          color: AppColors.warm400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_left_rounded, color: AppColors.warm400),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: top > 0 ? 8 : 8),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.paddingOf(context).bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.97),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'شهریه دوره',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warm400,
                          ),
                        ),
                        if (course.oldPrice != null)
                          Text(
                            '${course.oldPrice} تومان',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 12,
                              color: AppColors.warm400,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: course.isFree ? 'رایگان' : course.price,
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: course.isFree
                                      ? const Color(0xFF16A34A)
                                      : AppColors.dark900,
                                ),
                              ),
                              if (!course.isFree)
                                TextSpan(
                                  text: ' تومان',
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warm400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _buy,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.goldGlow,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          course.isFree ? 'شروع رایگان' : 'ثبت‌نام در دوره',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool lightText;

  const _Chip({required this.label, this.color, this.lightText = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.vazirmatn(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: lightText || color != null ? Colors.white : Colors.white,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.vazirmatn(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.dark900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.vazirmatn(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.warm400,
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.warm200);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailing;

  const _SectionTitle({required this.title, required this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gold600),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.vazirmatn(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.dark900,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold50,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing!,
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.gold700,
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 50) / 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gold50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: AppColors.gold600),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final int index;
  final String faIndex;
  final String title;

  const _ChapterTile({
    required this.index,
    required this.faIndex,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: index <= 3 ? AppColors.goldGradient : null,
              color: index > 3 ? AppColors.cream : null,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              faIndex,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: index <= 3 ? Colors.white : AppColors.gold700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.dark800,
                height: 1.5,
              ),
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: AppColors.warm300,
          ),
        ],
      ),
    );
  }
}

class _CourseExtra {
  final String students;
  final List<String> chapters;
  final String siteUrl;

  const _CourseExtra({
    required this.students,
    required this.chapters,
    this.siteUrl = '',
  });
}
