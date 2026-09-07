import 'package:flutter/material.dart';

import '../core/constants/brand.dart';
import '../core/theme/ledger_motion.dart';
import '../core/theme/ledger_theme.dart';
import '../data/datasources/onboarding_store.dart';
import '../data/datasources/settings_store.dart';
import '../data/repositories/memory_item_repository.dart';
import '../domain/repositories/item_repository.dart';
import '../presentation/splash/splash_page.dart';
import 'launch_flow.dart';
import 'settings_controller.dart';
import 'theme_controller.dart';
import 'vault_scope.dart';

class DueKeepApp extends StatefulWidget {
  const DueKeepApp({
    super.key,
    this.themeController,
    this.settingsController,
    this.onboardingStore,
    this.itemRepository,
    this.showSplash = true,
    this.splashDuration = SplashPage.displayDuration,
  });

  /// Injected in tests. The app owns one if omitted.
  final ThemeController? themeController;

  /// Injected in tests. The app owns a prefs-backed controller if omitted.
  final SettingsController? settingsController;

  /// Injected in tests. The app owns a prefs-backed store if omitted.
  final OnboardingStore? onboardingStore;

  /// Injected from [main] (SQLite) or tests (memory).
  final ItemRepository? itemRepository;

  /// When false, skip the timed splash and route immediately (tests).
  final bool showSplash;

  final Duration splashDuration;

  @override
  State<DueKeepApp> createState() => _DueKeepAppState();
}

class _DueKeepAppState extends State<DueKeepApp> {
  late final ThemeController _controller;
  late final SettingsController _settings;
  late final OnboardingStore _onboardingStore;
  late final ItemRepository _items;
  late final bool _ownsTheme;
  late final bool _ownsSettings;

  @override
  void initState() {
    super.initState();
    _ownsTheme = widget.themeController == null;
    _ownsSettings = widget.settingsController == null;
    _controller = widget.themeController ?? ThemeController();
    _settings = widget.settingsController ??
        SettingsController(store: PrefsSettingsStore());
    _onboardingStore = widget.onboardingStore ?? PrefsOnboardingStore();
    _items = widget.itemRepository ?? MemoryItemRepository();
  }

  @override
  void dispose() {
    if (_ownsTheme) {
      _controller.dispose();
    }
    if (_ownsSettings) {
      _settings.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return VaultScope(
          items: _items,
          child: MaterialApp(
            title: Brand.name,
            debugShowCheckedModeBanner: false,
            theme: LedgerTheme.light(),
            darkTheme: LedgerTheme.dark(),
            themeMode: _controller.mode,
            themeAnimationDuration: LedgerMotion.duration,
            themeAnimationCurve: LedgerMotion.curve,
            home: LaunchFlow(
              themeController: _controller,
              settingsController: _settings,
              onboardingStore: _onboardingStore,
              showSplash: widget.showSplash,
              splashDuration: widget.splashDuration,
            ),
          ),
        );
      },
    );
  }
}
