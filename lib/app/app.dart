import 'package:flutter/material.dart';

import '../core/constants/brand.dart';
import '../core/theme/ledger_motion.dart';
import '../core/theme/ledger_theme.dart';
import '../presentation/shell/theme_shell_page.dart';
import 'theme_controller.dart';

class DueKeepApp extends StatefulWidget {
  const DueKeepApp({super.key, this.themeController});

  /// Injected in tests. The app owns one if omitted.
  final ThemeController? themeController;

  @override
  State<DueKeepApp> createState() => _DueKeepAppState();
}

class _DueKeepAppState extends State<DueKeepApp> {
  late final ThemeController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.themeController == null;
    _controller = widget.themeController ?? ThemeController();
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
          home: ThemeShellPage(controller: _controller),
        );
      },
    );
  }
}
