import 'package:flutter/material.dart';

/// Simple folded-corner rectangle used next to the wordmark.
/// Geometry, not a mascot.
class VaultMark extends StatelessWidget {
  const VaultMark({
    super.key,
    this.size = 22,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _VaultMarkPainter(
        color: color ?? IconTheme.of(context).color ?? Colors.black,
      ),
    );
  }
}

class _VaultMarkPainter extends CustomPainter {
  const _VaultMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fold = size.width * 0.32;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeJoin = StrokeJoin.miter;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - fold, 0)
      ..lineTo(size.width, fold)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, stroke);

    canvas.drawLine(
      Offset(size.width - fold, 0),
      Offset(size.width - fold, fold),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width - fold, fold),
      Offset(size.width, fold),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_VaultMarkPainter oldDelegate) => oldDelegate.color != color;
}
