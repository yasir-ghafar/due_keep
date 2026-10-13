import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ledger_motion.dart';

/// Expands a circular hole through [snapshot], revealing the new theme beneath.
class CircularThemeRevealOverlay extends StatefulWidget {
  const CircularThemeRevealOverlay({
    super.key,
    required this.snapshot,
    required this.origin,
    required this.onFinished,
  });

  final ui.Image snapshot;
  final Offset origin;
  final VoidCallback onFinished;

  @override
  State<CircularThemeRevealOverlay> createState() =>
      _CircularThemeRevealOverlayState();
}

class _CircularThemeRevealOverlayState extends State<CircularThemeRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _radius;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LedgerMotion.themeDuration,
    );
    _radius = CurvedAnimation(parent: _controller, curve: LedgerMotion.curve);
    _controller.forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double maxRadius(Size size, Offset origin) {
    final corners = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    return corners
        .map((corner) => (corner - origin).distance)
        .reduce(math.max);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final endRadius = maxRadius(size, widget.origin);

    return AbsorbPointer(
      child: AnimatedBuilder(
        animation: _radius,
        builder: (context, _) {
          return ClipPath(
            clipper: _CircleHoleClipper(
              origin: widget.origin,
              radius: endRadius * _radius.value,
            ),
            child: RawImage(
              image: widget.snapshot,
              width: size.width,
              height: size.height,
              fit: BoxFit.fill,
            ),
          );
        },
      ),
    );
  }
}

class _CircleHoleClipper extends CustomClipper<Path> {
  _CircleHoleClipper({required this.origin, required this.radius});

  final Offset origin;
  final double radius;

  @override
  Path getClip(Size size) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: origin, radius: radius));
  }

  @override
  bool shouldReclip(covariant _CircleHoleClipper oldClipper) {
    return oldClipper.origin != origin || oldClipper.radius != radius;
  }
}
