import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/version_checker.dart';
import '../state/auth_session.dart';
import '../state/courses_repository.dart';
import '../state/products_repository.dart';
import '../state/theme_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/update_dialog.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _applySystemUi();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..forward();
    _boot();
  }

  Future<void> _boot() async {
    final versionFuture = VersionChecker().check();
    await Future.wait([
      AuthSession.instance.restore(),
      ProductsRepository.instance.load(),
      CoursesRepository.instance.load(),
      Future<void>.delayed(const Duration(milliseconds: 450)),
    ]);
    if (!mounted) return;

    final update = await versionFuture;
    if (!mounted) return;
    if (update.needsUpdate) {
      await showUpdateDialog(context, result: update);
      if (!mounted) return;
      // Force update dialog never dismisses; soft continues into the app.
      if (update.kind == UpdateKind.force) return;
    }

    _openApp();
  }

  void _applySystemUi() {
    final dark = ThemeController.instance.isDark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: dark ? AppColors.cream : Colors.white,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  void _openApp() {
    if (!mounted) return;
    _applySystemUi();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.isDark ? AppColors.creamDark : const Color(0xFFFFFCF7),
              AppColors.cream,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _entranceController,
              curve: Curves.easeOut,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: .92, end: 1).animate(
                CurvedAnimation(
                  parent: _entranceController,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold500.withValues(alpha: .16),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      cacheWidth: (112 *
                              math.max(
                                1,
                                MediaQuery.devicePixelRatioOf(context),
                              ))
                          .round(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'آکادمی کیک یوسف',
                    style: AppFonts.vazirmatn(
                      fontSize: 22,
                      color: AppColors.dark900,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'آموزش تخصصی کیک و شیرینی',
                    style: AppFonts.vazirmatn(
                      fontSize: 12,
                      color: AppColors.warm400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
