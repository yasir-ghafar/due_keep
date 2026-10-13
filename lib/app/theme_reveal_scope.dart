import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../core/theme/circular_theme_reveal.dart';
import 'theme_controller.dart';

/// Captures the screen and runs a circular reveal when brightness changes.
class ThemeRevealScope extends StatefulWidget {
  const ThemeRevealScope({
    super.key,
    required this.themeController,
    required this.child,
  });

  final ThemeController themeController;
  final Widget child;

  static ThemeRevealScopeState of(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<_ThemeRevealInherited>();
    assert(scope != null, 'ThemeRevealScope not found in context');
    return scope!.state;
  }

  static ThemeRevealScopeState? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<_ThemeRevealInherited>()
        ?.state;
  }

  @override
  State<ThemeRevealScope> createState() => ThemeRevealScopeState();
}

class ThemeRevealScopeState extends State<ThemeRevealScope> {
  final GlobalKey _boundaryKey = GlobalKey();
  ui.Image? _snapshot;
  Offset? _origin;
  bool _busy = false;

  /// Switches [ThemeMode], circular-revealing from [origin] when brightness
  /// actually changes.
  Future<void> setMode(ThemeMode mode, {required Offset origin}) async {
    final controller = widget.themeController;
    if (controller.mode == mode || _busy) return;

    final platform = MediaQuery.platformBrightnessOf(context);
    final from = _resolve(controller.mode, platform);
    final to = _resolve(mode, platform);
    if (from == to) {
      controller.setMode(mode);
      return;
    }

    _busy = true;
    final snapshot = await _capture();
    if (!mounted) {
      snapshot?.dispose();
      _busy = false;
      return;
    }

    if (snapshot == null) {
      controller.setMode(mode);
      _busy = false;
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    final localOrigin =
        box != null && box.hasSize ? box.globalToLocal(origin) : origin;

    setState(() {
      _snapshot = snapshot;
      _origin = localOrigin;
    });
    controller.setMode(mode);
  }

  void _onRevealFinished() {
    _busy = false;
    if (!mounted) {
      _snapshot?.dispose();
      _snapshot = null;
      _origin = null;
      return;
    }
    setState(() {
      _snapshot?.dispose();
      _snapshot = null;
      _origin = null;
    });
  }

  Future<ui.Image?> _capture() async {
    final boundary = _boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null || !boundary.hasSize) return null;

    final ratio = MediaQuery.devicePixelRatioOf(context);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return null;

    try {
      return await boundary.toImage(pixelRatio: ratio);
    } catch (_) {
      return null;
    }
  }

  static Brightness _resolve(ThemeMode mode, Brightness platform) {
    return switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platform,
    };
  }

  @override
  void dispose() {
    _snapshot?.dispose();
    _snapshot = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final origin = _origin;

    return _ThemeRevealInherited(
      state: this,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            key: _boundaryKey,
            child: widget.child,
          ),
          if (snapshot != null && origin != null)
            Positioned.fill(
              child: CircularThemeRevealOverlay(
                snapshot: snapshot,
                origin: origin,
                onFinished: _onRevealFinished,
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeRevealInherited extends InheritedWidget {
  const _ThemeRevealInherited({
    required this.state,
    required super.child,
  });

  final ThemeRevealScopeState state;

  @override
  bool updateShouldNotify(covariant _ThemeRevealInherited oldWidget) => false;
}
