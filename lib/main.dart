import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/splash_screen.dart';
import 'state/theme_controller.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep runtime fetch as fallback; theme already uses bundled Vazirmatn.
  GoogleFonts.config.allowRuntimeFetching = true;
  await ThemeController.instance.restore();
  _applySystemUi(ThemeController.instance.isDark);
  runApp(const CakeAcademyApp());
}

void _applySystemUi(bool dark) {
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

class CakeAcademyApp extends StatefulWidget {
  const CakeAcademyApp({super.key});

  @override
  State<CakeAcademyApp> createState() => _CakeAcademyAppState();
}

class _CakeAcademyAppState extends State<CakeAcademyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ThemeController.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onThemeChanged() {
    _applySystemUi(ThemeController.instance.isDark);
    setState(() {});
  }

  @override
  void didChangePlatformBrightness() {
    ThemeController.instance.syncWithPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;
    return MaterialApp(
      title: 'آکادمی کیک یوسف',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.mode,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return ListenableBuilder(
          listenable: ThemeController.instance,
          builder: (context, _) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AnimatedTheme(
                data: ThemeController.instance.isDark
                    ? AppTheme.dark
                    : AppTheme.light,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
      home: const SplashScreen(),
      color: AppColors.cream,
    );
  }
}
