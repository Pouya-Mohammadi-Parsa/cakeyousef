import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../state/courses_repository.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import '../utils/network_image.dart';
import '../utils/payment_helper.dart';
import '../widgets/course_video_player.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseItem course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late CourseItem course;
  bool _loadingDetail = false;
  CourseLesson? _activeLesson;
  bool _showPlayer = false;

  @override
  void initState() {
    super.initState();
    course = widget.course;
    _activeLesson = course.firstPlayableLesson;
    _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    final key = course.slug?.isNotEmpty == true ? course.slug! : course.id;
    if (key == null || key.isEmpty) return;

    setState(() => _loadingDetail = true);
    try {
      final dto =
          await CoursesRepository.instance.fetchDetail(key, forceRemote: true);
      if (!mounted) return;
      final next = dto.toCourseItem(forDetail: true);
      setState(() {
        course = next;
        _activeLesson ??= next.firstPlayableLesson;
      });
    } catch (_) {
      // Keep list payload.
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  bool _canPlay(CourseLesson lesson) {
    if (!lesson.hasVideo) return false;
    return course.canAccessAllVideos || lesson.isFree;
  }

  void _selectLesson(CourseLesson lesson) {
    if (!_canPlay(lesson)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'این درس پس از خرید دوره در دسترس است',
            style: GoogleFonts.vazirmatn(),
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'خرید',
            textColor: AppColors.gold300,
            onPressed: _buy,
          ),
        ),
      );
      return;
    }
    setState(() {
      _activeLesson = lesson;
      _showPlayer = true;
    });
  }

  void _playNext() {
    final lessons = course.videoLessons;
    final current = _activeLesson;
    if (current == null || lessons.isEmpty) return;
    final idx = lessons.indexWhere((l) => l.id == current.id);
    for (var i = idx + 1; i < lessons.length; i++) {
      if (_canPlay(lessons[i])) {
        setState(() {
          _activeLesson = lessons[i];
          _showPlayer = true;
        });
        return;
      }
    }
  }

  Future<void> _openSite() async {
    final raw = course.siteUrl ?? '';
    if (raw.isEmpty) return;
    final uri = Uri.parse(Uri.encodeFull(raw));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
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
      fallbackUrl: course.siteUrl,
    );
  }

  List<_FeatureSpec> get _features {
    final items = <_FeatureSpec>[
      if (course.onlineSupport)
        const _FeatureSpec(Icons.support_agent_rounded, 'پشتیبانی آنلاین'),
      if (course.finalExam)
        const _FeatureSpec(Icons.quiz_outlined, 'آزمون پایانی'),
      if (course.courseType != null && course.courseType!.isNotEmpty)
        _FeatureSpec(Icons.school_rounded, course.courseType!),
      if (course.durationLabel != null && course.durationLabel!.isNotEmpty)
        _FeatureSpec(Icons.schedule_rounded, course.durationLabel!),
      const _FeatureSpec(Icons.all_inclusive_rounded, 'دسترسی مادام‌العمر'),
      const _FeatureSpec(Icons.phone_android_rounded, 'مشاهده در موبایل'),
      const _FeatureSpec(Icons.hd_rounded, 'کیفیت HD'),
    ];
    for (final f in course.featureLabels) {
      items.add(_FeatureSpec(Icons.check_circle_outline_rounded, f));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final lessons = course.videoLessons;
    final students = toFaDigits(course.studentsLabel ?? '۰');
    final freeCount = lessons.where((l) => l.isFree && l.hasVideo).length;
    final active = _activeLesson;
    final canPlayActive = active != null && _canPlay(active);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (_loadingDetail)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    color: AppColors.gold600,
                    backgroundColor: Colors.transparent,
                    minHeight: 2,
                  ),
                ),

              // Top bar
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: Row(
                      children: [
                        _RoundIconButton(
                          icon: Icons.arrow_forward_ios_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                          dark: false,
                        ),
                        const Spacer(),
                        _RoundIconButton(
                          icon: Icons.share_rounded,
                          onTap: _openSite,
                          dark: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Player / poster
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: canPlayActive && _showPlayer
                      ? CourseVideoPlayer(
                          key: ValueKey('${active.id}_${active.videoUrl}'),
                          url: active.videoUrl,
                          title: active.title,
                          autoPlay: true,
                          onEnded: _playNext,
                        )
                      : CourseVideoPoster(
                          imageUrl: course.imageUrl,
                          title: active?.title ?? course.title,
                          subtitle: active == null
                              ? 'یک درس را برای پخش انتخاب کنید'
                              : (_canPlay(active)
                                  ? 'برای پخش ضربه بزنید'
                                  : 'برای مشاهده این درس دوره را بخرید'),
                          locked: active != null && !_canPlay(active),
                          onPlay: () {
                            if (active != null) {
                              _selectLesson(active);
                            } else if (course.firstPlayableLesson != null) {
                              _selectLesson(course.firstPlayableLesson!);
                            }
                          },
                        ),
                ),
              ),

              // Title + meta
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...course.tags.map(
                            (t) => _SoftChip(label: t.label),
                          ),
                          if (course.badge != null)
                            _SoftChip(
                              label: course.badge!,
                              filled: true,
                            ),
                          if (course.discount != null)
                            _SoftChip(
                              label: 'تخفیف ${course.discount}',
                              filled: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        course.title,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.dark900,
                          height: 1.35,
                        ),
                      ),
                      if (course.description != null &&
                          course.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          course.description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13,
                            height: 1.7,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dark700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppColors.cardShadowLg,
                    ),
                    child: Row(
                      children: [
                        _Stat(
                          icon: Icons.star_rounded,
                          value: course.rating,
                          label: 'امتیاز',
                          color: AppColors.gold500,
                        ),
                        _VDivider(),
                        _Stat(
                          icon: Icons.play_lesson_rounded,
                          value: lessons.isEmpty
                              ? (course.lessons ?? '—')
                              : toFaDigits('${lessons.length}'),
                          label: 'درس',
                          color: const Color(0xFF3B82F6),
                        ),
                        _VDivider(),
                        _Stat(
                          icon: Icons.people_alt_rounded,
                          value: students,
                          label: 'هنرجو',
                          color: const Color(0xFF22C55E),
                        ),
                        if (freeCount > 0) ...[
                          _VDivider(),
                          _Stat(
                            icon: Icons.lock_open_rounded,
                            value: toFaDigits('$freeCount'),
                            label: 'رایگان',
                            color: const Color(0xFFA855F7),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructor
                      _SectionTitle(
                        title: 'مدرس',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: course.instructorAvatar != null
                                    ? AppNetworkImage(
                                        url: course.instructorAvatar!,
                                        width: 56,
                                        height: 56,
                                        errorWidget: _InstructorFallback(
                                          name: course.instructor,
                                        ),
                                      )
                                    : _InstructorFallback(
                                        name: course.instructor,
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
                                  const SizedBox(height: 4),
                                  Text(
                                    course.instructorBio?.trim().isNotEmpty ==
                                            true
                                        ? course.instructorBio!
                                        : 'مدرس رسمی آکادمی کیک یوسف',
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 12,
                                      height: 1.65,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.dark700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // About
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'درباره دوره',
                        icon: Icons.info_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Text(
                          course.description ??
                              'توضیحات این دوره به‌زودی تکمیل می‌شود.',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.9,
                            color: AppColors.dark700,
                          ),
                        ),
                      ),

                      // What you'll learn
                      if (course.learnPoints.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _SectionTitle(
                          title: 'آنچه یاد می‌گیرید',
                          icon: Icons.lightbulb_outline_rounded,
                        ),
                        const SizedBox(height: 10),
                        ...course.learnPoints.map(
                          (p) => _BulletRow(
                            icon: Icons.check_circle_rounded,
                            iconColor: const Color(0xFF16A34A),
                            text: p,
                          ),
                        ),
                      ],

                      // Requirements
                      if (course.requirements.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _SectionTitle(
                          title: 'پیش‌نیازها',
                          icon: Icons.rule_rounded,
                        ),
                        const SizedBox(height: 10),
                        ...course.requirements.map(
                          (p) => _BulletRow(
                            icon: Icons.arrow_circle_left_outlined,
                            iconColor: AppColors.gold600,
                            text: p,
                          ),
                        ),
                      ],

                      // Features
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'ویژگی‌های دوره',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _features
                            .map(
                              (f) => _FeatureCard(icon: f.icon, title: f.title),
                            )
                            .toList(),
                      ),

                      // Lessons / videos
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'ویدیوهای دوره',
                        icon: Icons.playlist_play_rounded,
                        trailing: lessons.isEmpty
                            ? null
                            : '${toFaDigits('${lessons.length}')} درس',
                      ),
                      const SizedBox(height: 10),
                      if (lessons.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.warm200.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            'سرفصل ویدیویی این دوره هنوز اضافه نشده است.',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 13,
                              color: AppColors.dark700,
                            ),
                          ),
                        )
                      else
                        ...List.generate(lessons.length, (i) {
                          final lesson = lessons[i];
                          final unlocked = _canPlay(lesson);
                          final selected = active?.id == lesson.id;
                          return _LessonTile(
                            index: i + 1,
                            lesson: lesson,
                            selected: selected,
                            unlocked: unlocked,
                            onTap: () => _selectLesson(lesson),
                          );
                        }),

                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'منبع رسمی',
                        icon: Icons.public_rounded,
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: _openSite,
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
                                  child: const Icon(
                                    Icons.open_in_new_rounded,
                                    color: AppColors.gold600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                Icon(
                                  Icons.chevron_left_rounded,
                                  color: AppColors.warm400,
                                ),
                              ],
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
                color: AppColors.card.withValues(alpha: 0.97),
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
                          course.hasPurchased == true
                              ? 'وضعیت خرید'
                              : 'شهریه دوره',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warm400,
                          ),
                        ),
                        if (course.hasPurchased == true)
                          Text(
                            'خریداری‌شده',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF16A34A),
                            ),
                          )
                        else ...[
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: course.hasPurchased == true
                          ? () {
                              final first = course.firstPlayableLesson;
                              if (first != null) _selectLesson(first);
                            }
                          : _buy,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.goldGlow,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          course.hasPurchased == true
                              ? 'تماشای دوره'
                              : (course.isFree
                                  ? 'شروع رایگان'
                                  : 'ثبت‌نام در دوره'),
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

class _FeatureSpec {
  final IconData icon;
  final String title;
  const _FeatureSpec(this.icon, this.title);
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.dark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: dark ? 0 : 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: dark ? Colors.white : AppColors.dark800,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  final String label;
  final bool filled;

  const _SoftChip({required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? AppColors.gold600 : AppColors.gold50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.vazirmatn(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : AppColors.gold700,
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
          color: AppColors.card,
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

class _BulletRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _BulletRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                height: 1.7,
                fontWeight: FontWeight.w600,
                color: AppColors.dark700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructorFallback extends StatelessWidget {
  final String name;
  const _InstructorFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? 'م'
        : String.fromCharCodes(name.trim().runes.take(1));
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.goldGradient),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.vazirmatn(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final int index;
  final CourseLesson lesson;
  final bool selected;
  final bool unlocked;
  final VoidCallback onTap;

  const _LessonTile({
    required this.index,
    required this.lesson,
    required this.selected,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final faIndex = toFaDigits('$index');
    final duration = lesson.durationLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.gold50 : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.gold400 : Colors.transparent,
                width: 1.2,
              ),
              boxShadow: selected ? null : AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: unlocked ? AppColors.goldGradient : null,
                    color: unlocked ? null : AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: unlocked
                      ? Icon(
                          selected
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        )
                      : Text(
                          faIndex,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold700,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark800,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'درس $faIndex',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warm400,
                            ),
                          ),
                          if (duration.isNotEmpty) ...[
                            Text(
                              '  ·  ',
                              style: GoogleFonts.vazirmatn(
                                color: AppColors.warm300,
                              ),
                            ),
                            Text(
                              duration,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warm400,
                              ),
                            ),
                          ],
                          if (lesson.isFree) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'رایگان',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  unlocked
                      ? (selected
                          ? Icons.graphic_eq_rounded
                          : Icons.play_circle_outline_rounded)
                      : Icons.lock_outline_rounded,
                  size: 22,
                  color: unlocked ? AppColors.gold600 : AppColors.warm300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
