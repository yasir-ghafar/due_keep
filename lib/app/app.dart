import 'package:flutter/material.dart';

import '../core/constants/brand.dart';
import '../core/theme/ledger_motion.dart';
import '../core/theme/ledger_theme.dart';
import '../data/datasources/onboarding_store.dart';
import '../presentation/splash/splash_page.dart';
import 'launch_flow.dart';
import 'theme_controller.dart';

class DueKeepApp extends StatefulWidget {
  const DueKeepApp({
    super.key,
    this.themeController,
    this.onboardingStore,
    this.showSplash = true,
    this.splashDuration = SplashPage.displayDuration,
  });

  /// Injected in tests. The app owns one if omitted.
  final ThemeController? themeController;

  /// Injected in tests. The app owns a prefs-backed store if omitted.
  final OnboardingStore? onboardingStore;

  /// When false, skip the timed splash and route immediately (tests).
  final bool showSplash;

  final Duration splashDuration;

  @override
  State<DueKeepApp> createState() => _DueKeepAppState();
}

class _DueKeepAppState extends State<DueKeepApp> {
  late final ThemeController _controller;
  late final OnboardingStore _onboardingStore;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.themeController == null;
    _controller = widget.themeController ?? ThemeController();
    _onboardingStore = widget.onboardingStore ?? PrefsOnboardingStore();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: Brand.name,
          debugShowCheckedModeBanner: false,
          theme: LedgerTheme.light(),
          darkTheme: LedgerTheme.dark(),
          themeMode: _controller.mode,
          themeAnimationDuration: LedgerMotion.duration,
          themeAnimationCurve: LedgerMotion.curve,
          home: LaunchFlow(
            themeController: _controller,
            onboardingStore: _onboardingStore,
            showSplash: widget.showSplash,
            splashDuration: widget.splashDuration,
          ),
        );
      },
    );
  }
}
