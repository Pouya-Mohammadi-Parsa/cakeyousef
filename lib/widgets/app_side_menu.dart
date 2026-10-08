import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/version_checker.dart';
import '../state/auth_session.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';

typedef MenuNavigate = void Function(int tabIndex);

class AppSideMenu extends StatelessWidget {
  final MenuNavigate onNavigate;
  final VoidCallback? onOpenCourses;
  final VoidCallback? onOpenDownloads;
  final VoidCallback? onOpenNotifications;

  const AppSideMenu({
    super.key,
    required this.onNavigate,
    this.onOpenCourses,
    this.onOpenDownloads,
    this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthSession.instance,
      builder: (context, _) {
        final s = AuthSession.instance;
        return Drawer(
          backgroundColor: AppColors.cream,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppColors.goldGlow,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withValues(alpha: 0.28),
                        child: s.isLoggedIn
                            ? Text(
                                s.name.isNotEmpty
                                    ? String.fromCharCode(s.name.runes.first)
                                    : 'ک',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s.displayName,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.isLoggedIn ? s.phone : 'برای امکانات کامل وارد شوید',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _Item(
                        icon: Icons.person_outline_rounded,
                        title: 'اطلاعات شخصی',
                        onTap: () {
                          Navigator.pop(context);
                          onNavigate(4);
                        },
                      ),
                      _Item(
                        icon: Icons.menu_book_outlined,
                        title: 'دوره‌های آموزشی',
                        onTap: () {
                          Navigator.pop(context);
                          onNavigate(1);
                          onOpenCourses?.call();
                        },
                      ),
                      _Item(
                        icon: Icons.shopping_bag_outlined,
                        title: 'محصولات فیزیکی',
                        onTap: () {
                          Navigator.pop(context);
                          onNavigate(3);
                        },
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                        child: Text(
                          'تنظیمات و فایل‌ها',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.warm400,
                          ),
                        ),
                      ),
                      _Item(
                        icon: Icons.download_rounded,
                        title: 'دانلودهای من',
                        onTap: () {
                          Navigator.pop(context);
                          onOpenDownloads?.call();
                        },
                      ),
                      _Item(
                        icon: Icons.notifications_active_outlined,
                        title: 'تنظیمات پوش نوتیفیکیشن',
                        onTap: () {
                          Navigator.pop(context);
                          onOpenNotifications?.call();
                        },
                      ),
                    ],
                  ),
                ),
                const _VersionFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VersionFooter extends StatefulWidget {
  const _VersionFooter();

  @override
  State<_VersionFooter> createState() => _VersionFooterState();
}

class _VersionFooterState extends State<_VersionFooter> {
  UpdateCheckResult? _result;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await VersionChecker().check();
    if (!mounted) return;
    setState(() => _result = result);
  }

  Future<void> _installUpdate() async {
    final url = _result?.remote?.downloadUrl.trim() ?? '';
    if (url.isEmpty || _opening) return;
    setState(() => _opening = true);
    try {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final current = result == null
        ? '...'
        : toFaDigits(result.currentVersion);
    final hasUpdate = result?.needsUpdate == true && result?.remote != null;
    final latest = hasUpdate
        ? toFaDigits(result!.remote!.latestVersion)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'آکادمی کیک یوسف',
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
              fontSize: 11,
              color: AppColors.warm400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // RTL: first child sits on the right — new version + update action.
              if (hasUpdate) ...[
                Flexible(
                  child: Material(
                    color: AppColors.gold500,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _opening ? null : _installUpdate,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_opening)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(
                                Icons.system_update_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'جدید $latest',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  'نسخه فعلی $current',
                  textAlign: hasUpdate ? TextAlign.start : TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 11.5,
                    color: AppColors.dark700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _Item({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.gold50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.gold600, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: AppColors.dark900,
          ),
        ),
        trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.warm400),
      ),
    );
  }
}
