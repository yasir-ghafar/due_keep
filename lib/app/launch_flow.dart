import 'package:flutter/material.dart';

import '../core/theme/ledger_motion.dart';
import '../data/datasources/onboarding_store.dart';
import '../presentation/onboarding/onboarding_page.dart';
import '../presentation/shell/theme_shell_page.dart';
import '../presentation/splash/splash_page.dart';
import 'theme_controller.dart';

enum LaunchPhase { splash, onboarding, shell }

/// Splash, then first-launch onboarding or the app shell.
class LaunchFlow extends StatefulWidget {
  const LaunchFlow({
    super.key,
    required this.themeController,
    required this.onboardingStore,
    this.showSplash = true,
    this.splashDuration = SplashPage.displayDuration,
  });

  final ThemeController themeController;
  final OnboardingStore onboardingStore;
  final bool showSplash;
  final Duration splashDuration;

  @override
  State<LaunchFlow> createState() => _LaunchFlowState();
}

class _LaunchFlowState extends State<LaunchFlow> {
  late LaunchPhase _phase;

  @override
  void initState() {
    super.initState();
    _phase = widget.showSplash ? LaunchPhase.splash : LaunchPhase.shell;
    _route();
  }

  Future<void> _route() async {
    final wait = widget.showSplash
        ? Future<void>.delayed(widget.splashDuration)
        : Future<void>.value();
    final results = await Future.wait<Object?>([
      wait,
      widget.onboardingStore.isComplete(),
    ]);
    if (!mounted) return;
    final complete = results[1] as bool;
    setState(() {
      _phase = complete ? LaunchPhase.shell : LaunchPhase.onboarding;
    });
  }

  void _onOnboardingFinished() {
    setState(() => _phase = LaunchPhase.shell);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: LedgerMotion.duration,
      switchInCurve: LedgerMotion.curve,
      switchOutCurve: LedgerMotion.curve,
      child: KeyedSubtree(
        key: ValueKey(_phase),
        child: switch (_phase) {
          LaunchPhase.splash => const SplashPage(),
          LaunchPhase.onboarding => OnboardingPage(
              store: widget.onboardingStore,
              onFinished: _onOnboardingFinished,
            ),
          LaunchPhase.shell => ThemeShellPage(
              controller: widget.themeController,
            ),
        },
      ),
    );
  }
}
