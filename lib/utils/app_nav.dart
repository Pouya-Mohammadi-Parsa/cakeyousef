import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Shared fade page route used across the app.
Route<T> fadeRoute<T extends Object?>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Standard white AppBar matching existing screen styles.
PreferredSizeWidget appPageAppBar(String title) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Text(
      title,
      style: GoogleFonts.vazirmatn(
        fontWeight: FontWeight.w800,
        color: AppColors.dark900,
        fontSize: 16,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.dark800),
  );
}

/// Provides MainShell tab navigation to descendants (home quick access, etc.).
class MainTabScope extends InheritedWidget {
  const MainTabScope({
    super.key,
    required this.goToTab,
    required super.child,
  });

  /// Tab indices: 0 messenger, 1 courses, 2 home, 3 shop, 4 profile.
  final ValueChanged<int> goToTab;

  static MainTabScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainTabScope>();
  }

  static void go(BuildContext context, int index) {
    maybeOf(context)?.goToTab(index);
  }

  @override
  bool updateShouldNotify(MainTabScope oldWidget) =>
      goToTab != oldWidget.goToTab;
}
