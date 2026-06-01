import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:intl/intl.dart';

import 'pf_chart_empty.dart';
import 'pf_chart_palette.dart';

/// One point in a [PfLineSeries].
class PfLinePoint {
  /// Default constructor.
  const PfLinePoint({required this.x, required this.y, this.label});

  /// X coordinate (often day index).
  final double x;

  /// Y value.
  final double y;

  /// Optional label, used for the X-axis when present.
  final String? label;
}

/// One line in [PfLineChart].
class PfLineSeries {
  /// Default constructor.
  const PfLineSeries({
    required this.name,
    required this.points,
    this.color,
    this.dashed = false,
  });

  /// Series name (legend / tooltip).
  final String name;

  /// Data points, sorted by [PfLinePoint.x].
  final List<PfLinePoint> points;

  /// Optional explicit color.
  final Color? color;

  /// Dashed (e.g. average / trend) instead of solid.
  final bool dashed;
}

/// Smoothed line chart with optional gradient fill, per design-system
/// §10.25.
class PfLineChart extends StatelessWidget {
  /// Default constructor.
  const PfLineChart({
    super.key,
    required this.series,
    required this.semanticDescription,
    this.height = 220,
    this.numberFormat,
    this.showArea = true,
  });

  /// One or more series to render.
  final List<PfLineSeries> series;

  /// Human-readable screen-reader description of the chart's data. Exposed
  /// via [Semantics.value] so the chart is meaningful to assistive tech.
  final String semanticDescription;

  /// Reserved height.
  final double height;

  /// Number format for axis labels.
  final NumberFormat? numberFormat;

  /// Draw a gradient area under the first (primary) series.
  final bool showArea;

  @override
  Widget build(BuildContext context) {
    final bool hasData = series.any((PfLineSeries s) => s.points.isNotEmpty);
    if (!hasData) {
      return PfChartEmpty(height: height);
    }
    final ThemeData theme = Theme.of(context);
    final NumberFormat fmt = numberFormat ??
        NumberFormat.compact(
          locale: Localizations.maybeLocaleOf(context)?.toLanguageTag(),
        );
    final double minX = _minX();
    final double maxX = _maxX();
    final double maxY = _maxY();

    return Semantics(
      label: 'Line chart',
      value: semanticDescription,
      child: SizedBox(
        height: height,
        child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: 0,
            maxY: maxY == 0 ? 1 : maxY * 1.1,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY == 0 ? 1 : maxY) / 4,
              getDrawingHorizontalLine: (double _) => FlLine(
                color: theme.dividerColor.withValues(alpha: 0.4),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (double v, TitleMeta meta) => Padding(
                    padding: const EdgeInsets.only(right: PfTokens.space1),
                    child: Text(
                      fmt.format(v),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  getTitlesWidget: (double v, TitleMeta meta) {
                    final String? label = _labelForX(v);
                    if (label == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: PfTokens.space1),
                      child: Text(label, style: theme.textTheme.labelSmall),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (LineBarSpot _) =>
                    theme.colorScheme.inverseSurface,
                getTooltipItems: (List<LineBarSpot> spots) {
                  return spots.map((LineBarSpot s) {
                    return LineTooltipItem(
                      fmt.format(s.y),
                      theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.w600,
                          ) ??
                          const TextStyle(),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: <LineChartBarData>[
              for (int i = 0; i < series.length; i++) _buildBar(i, series[i]),
            ],
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildBar(int i, PfLineSeries s) {
    final Color color = s.color ?? PfChartPalette.at(i);
    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0.25,
      preventCurveOverShooting: true,
      barWidth: 2.5,
      color: color,
      isStrokeCapRound: true,
      dashArray: s.dashed ? <int>[6, 4] : null,
      dotData: FlDotData(
        show: true,
        getDotPainter:
            (FlSpot spot, double xPercent, LineChartBarData bar, int idx) {
          return FlDotCirclePainter(
            radius: 2,
            color: color,
            strokeWidth: 0,
          );
        },
      ),
      belowBarData: (showArea && i == 0)
          ? BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0),
                ],
              ),
            )
          : BarAreaData(show: false),
      spots: <FlSpot>[
        for (final PfLinePoint p in s.points) FlSpot(p.x, p.y),
      ],
    );
  }

  double _minX() {
    double v = double.infinity;
    for (final PfLineSeries s in series) {
      for (final PfLinePoint p in s.points) {
        if (p.x < v) v = p.x;
      }
    }
    return v.isFinite ? v : 0;
  }

  double _maxX() {
    double v = double.negativeInfinity;
    for (final PfLineSeries s in series) {
      for (final PfLinePoint p in s.points) {
        if (p.x > v) v = p.x;
      }
    }
    return v.isFinite ? v : 1;
  }

  double _maxY() {
    double v = 0;
    for (final PfLineSeries s in series) {
      for (final PfLinePoint p in s.points) {
        if (p.y > v) v = p.y;
      }
    }
    return v;
  }

  String? _labelForX(double x) {
    for (final PfLineSeries s in series) {
      for (final PfLinePoint p in s.points) {
        if ((p.x - x).abs() < 0.001 && p.label != null) return p.label;
      }
    }
    return null;
  }
}
