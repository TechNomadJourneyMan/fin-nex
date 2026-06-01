import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:intl/intl.dart';

import 'pf_chart_empty.dart';
import 'pf_chart_palette.dart';

/// One bar group (period bucket) for [PfBarChart].
class PfBarPoint {
  /// Default constructor.
  const PfBarPoint({
    required this.label,
    this.income = 0,
    this.expense = 0,
  });

  /// X-axis label (e.g. `Mon`, `01`, `Jan`).
  final String label;

  /// Income amount.
  final double income;

  /// Expense amount.
  final double expense;
}

/// Daily / weekly / monthly bar chart used in Analytics & Dashboard.
///
/// Income (mint) and expense (indigo) are drawn as grouped side-by-side
/// bars when both series have non-zero values; otherwise a single series
/// is shown.
class PfBarChart extends StatelessWidget {
  /// Default constructor.
  const PfBarChart({
    super.key,
    required this.data,
    this.height = 220,
    this.numberFormat,
    this.barWidth = 16,
    this.groupSpace = 12,
    this.incomeColor = PfChartPalette.mint,
    this.expenseColor = PfChartPalette.indigo,
    this.onBarTap,
  });

  /// Bar points in display order.
  final List<PfBarPoint> data;

  /// Reserved chart height.
  final double height;

  /// Number format for Y-axis labels.
  final NumberFormat? numberFormat;

  /// Width of each bar (per design-system: 16dp).
  final double barWidth;

  /// Space between groups.
  final double groupSpace;

  /// Income series color.
  final Color incomeColor;

  /// Expense series color.
  final Color expenseColor;

  /// Callback fired with the tapped bar group index.
  final ValueChanged<int>? onBarTap;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return PfChartEmpty(height: height);
    }
    final ThemeData theme = Theme.of(context);
    final NumberFormat fmt = numberFormat ??
        NumberFormat.compact(
          locale: Localizations.maybeLocaleOf(context)?.toLanguageTag(),
        );
    final bool hasIncome = data.any((PfBarPoint p) => p.income > 0);
    final bool hasExpense = data.any((PfBarPoint p) => p.expense > 0);
    final bool grouped = hasIncome && hasExpense;
    final double maxY = _computeMaxY();

    return SizedBox(
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
                interval: maxY / 4,
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
                  final int i = v.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: PfTokens.space1),
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
            touchCallback:
                (FlTouchEvent event, BarTouchResponse? response) {
              if (!event.isInterestedForInteractions) return;
              final int? i = response?.spot?.touchedBarGroupIndex;
              if (i != null) onBarTap?.call(i);
            },
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
                barsSpace: 4,
                barRods: <BarChartRodData>[
                  if (!grouped && hasIncome)
                    _rod(data[i].income, incomeColor),
                  if (!grouped && hasExpense)
                    _rod(data[i].expense, expenseColor),
                  if (grouped) ...<BarChartRodData>[
                    _rod(data[i].income, incomeColor),
                    _rod(data[i].expense, expenseColor),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  BarChartRodData _rod(double v, Color c) => BarChartRodData(
        toY: v,
        color: c,
        width: barWidth,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(4),
        ),
      );

  double _computeMaxY() {
    double maxV = 0;
    for (final PfBarPoint p in data) {
      if (p.income > maxV) maxV = p.income;
      if (p.expense > maxV) maxV = p.expense;
    }
    if (maxV == 0) return 1;
    // Pad ~10 % and round up to a nice number.
    final double padded = maxV * 1.1;
    final double mag = _orderOfMagnitude(padded);
    return (padded / mag).ceilToDouble() * mag;
  }

  double _orderOfMagnitude(double v) {
    if (v <= 0) return 1;
    double mag = 1;
    while (mag * 10 < v) {
      mag *= 10;
    }
    return mag;
  }
}
