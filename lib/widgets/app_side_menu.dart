import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/auth_session.dart';
import '../theme/app_colors.dart';

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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'آکادمی کیک یوسف',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11,
                      color: AppColors.warm400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
