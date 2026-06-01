import 'package:flutter/material.dart';

import 'pf_chart_palette.dart';

/// Small inline trend chart (60×20 by default) used in dashboard cards.
///
/// Custom-painted to avoid the cost of a full `fl_chart` instance and to
/// be guaranteed-cheap inside list rows.
class PfSparkline extends StatelessWidget {
  /// Default constructor.
  const PfSparkline({
    super.key,
    required this.values,
    this.width = 60,
    this.height = 20,
    this.color,
    this.strokeWidth = 1.5,
    this.overBudget = false,
  });

  /// Y values in chronological order.
  final List<double> values;

  /// Render width.
  final double width;

  /// Render height.
  final double height;

  /// Explicit stroke color. Defaults to mint (success) or rose
  /// (over-budget) per design-system §10.25.
  final Color? color;

  /// Stroke width.
  final double strokeWidth;

  /// If true, falls back to the over-budget color.
  final bool overBudget;

  @override
  Widget build(BuildContext context) {
    final Color resolved = color ??
        (overBudget ? PfChartPalette.rose : PfChartPalette.mint);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparkPainter(
          values: values,
          color: resolved,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    double minV = values.first;
    double maxV = values.first;
    for (final double v in values) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    final double range = (maxV - minV).abs() < 1e-9 ? 1 : (maxV - minV);
    final double dx = size.width / (values.length - 1);
    final Path path = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = i * dx;
      final double normalized = (values[i] - minV) / range;
      final double y = size.height - normalized * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
