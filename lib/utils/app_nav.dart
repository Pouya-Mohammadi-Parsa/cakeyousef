import 'package:flutter/material.dart';

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
