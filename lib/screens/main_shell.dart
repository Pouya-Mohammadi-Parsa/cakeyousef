import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/app_nav.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_side_menu.dart';
import 'courses_list_screen.dart';
import 'home_screen.dart';
import 'messenger_screen.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 2;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget?> _tabs = List<Widget?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    // Home only on cold start — other tabs lazy-built (big-app pattern).
    _ensureTab(2);
  }

  Widget _ensureTab(int i) {
    return _tabs[i] ??= switch (i) {
      0 => const MessengerScreen(),
      1 => const CoursesListScreen(),
      2 => const HomeScreen(),
      3 => const ShopScreen(),
      _ => const ProfileScreen(),
    };
  }

  void _openSimplePage(String title, String body) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              title,
              style: AppFonts.vazirmatn(
                fontWeight: FontWeight.w800,
                color: AppColors.dark900,
                fontSize: 16,
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.dark800),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(
                  fontSize: 14,
                  height: 1.8,
                  color: AppColors.dark700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goTab(int i) {
    setState(() {
      _ensureTab(i);
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainTabScope(
      goToTab: _goTab,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.cream,
        drawer: AppSideMenu(
          onNavigate: _goTab,
          onOpenDownloads: () => _openSimplePage(
            'دانلودهای من',
            'فایل‌ها و ویدیوهای دانلودشده دوره‌ها اینجا نمایش داده می‌شوند.',
          ),
          onOpenNotifications: () => _openSimplePage(
            'تنظیمات پوش نوتیفیکیشن',
            'از این بخش می‌توانید اعلان‌های دوره، لایو و سفارش را مدیریت کنید.',
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            children: List.generate(
              5,
              (i) => _tabs[i] ?? const SizedBox.shrink(),
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _index,
          onTap: _goTab,
        ),
      ),
    );
  }
}
