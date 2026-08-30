import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

/// A stylized stand-in for the live map (google_maps_flutter is deferred until
/// a Maps API key is configured). Draws a route between the restaurant and the
/// delivery pin and moves the driver marker along it by [progress] (0..1).
class MockMap extends StatelessWidget {
  const MockMap({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final start = Offset(size.width * 0.22, size.height * 0.30);
        final end = Offset(size.width * 0.78, size.height * 0.72);
        final driver = Offset.lerp(start, end, progress)!;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.surfaceHigh, context.colors.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Subtle grid to read as a map.
              CustomPaint(
                size: size,
                painter: _GridPainter(color: context.colors.line),
              ),
              // Route line.
              CustomPaint(
                size: size,
                painter: _RoutePainter(
                  start: start,
                  end: end,
                  color: context.colors.ember,
                ),
              ),
              _pin(context, start, Icons.storefront_rounded,
                  context.colors.inkSoft),
              _pin(context, end, Icons.home_rounded, context.colors.ember),
              _driverPin(context, driver),
            ],
          ),
        );
      },
    );
  }

  Widget _pin(BuildContext context, Offset at, IconData icon, Color color) =>
      Positioned(
        left: at.dx - 16,
        top: at.dy - 16,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.colors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      );

  Widget _driverPin(BuildContext context, Offset at) => Positioned(
        left: at.dx - 20,
        top: at.dy - 20,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.ember,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.colors.ember.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(Icons.delivery_dining_rounded,
              color: context.colors.onEmber, size: 22),
        ),
      );
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    const gap = 36.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // Repaints when the theme flips — the grid colour comes from the palette.
  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.start, required this.end, required this.color});

  final Offset start;
  final Offset end;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // A gently curved route via a control point for a less robotic line.
    final control = Offset(
      (start.dx + end.dx) / 2 + 40,
      (start.dy + end.dy) / 2 - 40,
    );
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    // Dashed effect.
    final dashed = _dash(path, 10, 8);
    canvas.drawPath(dashed, paint);
  }

  Path _dash(Path source, double dashLen, double gapLen) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = min(distance + dashLen, metric.length);
        dest.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + gapLen;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.start != start || oldDelegate.end != end;
}
