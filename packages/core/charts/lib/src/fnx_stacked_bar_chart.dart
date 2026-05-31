import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fnx_core_tokens/fnx_core_tokens.dart';
import 'package:intl/intl.dart';

import 'fnx_chart_empty.dart';
import 'fnx_chart_legend.dart';
import 'fnx_chart_palette.dart';

/// A stacked bar: one X-axis bucket with `n` stacked category values.
class FnxStackedBarPoint {
  /// Default constructor.
  const FnxStackedBarPoint({required this.label, required this.values});

  /// X-axis label (e.g. day).
  final String label;

  /// Values keyed by category name. Categories not present are treated
  /// as 0.
  final Map<String, double> values;
}

/// Stacked bar chart used in Analytics → "Categories per day".
///
/// Up to 6 categories are rendered; the rest collapse to "Other"
/// (configurable via [maxCategories] / [otherLabel]).
class FnxStackedBarChart extends StatelessWidget {
  /// Default constructor.
  const FnxStackedBarChart({
    super.key,
    required this.data,
    required this.categories,
    this.categoryColors = const <String, Color>{},
    this.height = 240,
    this.barWidth = 18,
    this.groupSpace = 12,
    this.maxCategories = 6,
    this.otherLabel = 'Other',
    this.numberFormat,
    this.showLegend = true,
  });

  /// Bar groups in display order.
  final List<FnxStackedBarPoint> data;

  /// Fixed category order. The first [maxCategories] are shown
  /// individually; remaining categories are summed into "Other".
  final List<String> categories;

  /// Optional per-category color overrides.
  final Map<String, Color> categoryColors;

  /// Reserved chart height (legend not included).
  final double height;

  /// Width of each stacked bar.
  final double barWidth;

  /// Space between groups.
  final double groupSpace;

  /// How many distinct categories to draw before bucketing into "Other".
  final int maxCategories;

  /// Label for the "Other" bucket.
  final String otherLabel;

  /// Y-axis number format.
  final NumberFormat? numberFormat;

  /// Whether to render the legend above the chart.
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || categories.isEmpty) {
      return FnxChartEmpty(height: height);
    }
    final ThemeData theme = Theme.of(context);
    final NumberFormat fmt = numberFormat ??
        NumberFormat.compact(
          locale: Localizations.maybeLocaleOf(context)?.toLanguageTag(),
        );

    final List<String> shownCats =
        categories.take(maxCategories).toList(growable: false);
    final List<String> hiddenCats = categories.skip(maxCategories).toList();
    final List<String> legendCats = <String>[
      ...shownCats,
      if (hiddenCats.isNotEmpty) otherLabel,
    ];

    Color colorFor(String cat, int i) =>
        categoryColors[cat] ?? FnxChartPalette.at(i);

    final double maxY = _computeMaxY(shownCats, hiddenCats);

    final Widget chart = SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: groupSpace,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
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
                interval: maxY / 4,
                getTitlesWidget: (double v, TitleMeta meta) => Text(
                  fmt.format(v),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (double v, TitleMeta meta) {
                  final int i = v.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: FnxTokens.space1),
                    child: Text(
                      data[i].label,
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (BarChartGroupData _) =>
                  theme.colorScheme.inverseSurface,
              getTooltipItem: (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
              ) {
                return BarTooltipItem(
                  fmt.format(rod.toY),
                  theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(),
                );
              },
            ),
          ),
          barGroups: <BarChartGroupData>[
            for (int i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: <BarChartRodData>[
                  _stackedRod(data[i], shownCats, hiddenCats, colorFor),
                ],
              ),
          ],
        ),
      ),
    );

    if (!showLegend) return chart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FnxChartLegend(
          entries: <FnxLegendEntry>[
            for (int i = 0; i < legendCats.length; i++)
              FnxLegendEntry(
                label: legendCats[i],
                color: colorFor(legendCats[i], i),
              ),
          ],
        ),
        const SizedBox(height: FnxTokens.space3),
        chart,
      ],
    );
  }

  BarChartRodData _stackedRod(
    FnxStackedBarPoint point,
    List<String> shown,
    List<String> hidden,
    Color Function(String, int) colorFor,
  ) {
    final List<BarChartRodStackItem> stacks = <BarChartRodStackItem>[];
    double cursor = 0;
    for (int i = 0; i < shown.length; i++) {
      final double v = point.values[shown[i]] ?? 0;
      if (v <= 0) continue;
      stacks.add(BarChartRodStackItem(cursor, cursor + v, colorFor(shown[i], i)));
      cursor += v;
    }
    double otherSum = 0;
    for (final String h in hidden) {
      otherSum += point.values[h] ?? 0;
    }
    if (otherSum > 0) {
      stacks.add(BarChartRodStackItem(
        cursor,
        cursor + otherSum,
        colorFor(otherLabel, shown.length),
      ));
      cursor += otherSum;
    }
    return BarChartRodData(
      toY: cursor,
      width: barWidth,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      rodStackItems: stacks,
      color: Colors.transparent,
    );
  }

  double _computeMaxY(List<String> shown, List<String> hidden) {
    double maxV = 0;
    for (final FnxStackedBarPoint p in data) {
      double sum = 0;
      for (final String s in shown) {
        sum += p.values[s] ?? 0;
      }
      for (final String h in hidden) {
        sum += p.values[h] ?? 0;
      }
      if (sum > maxV) maxV = sum;
    }
    if (maxV == 0) return 1;
    final double padded = maxV * 1.1;
    double mag = 1;
    while (mag * 10 < padded) {
      mag *= 10;
    }
    return (padded / mag).ceilToDouble() * mag;
  }
}
