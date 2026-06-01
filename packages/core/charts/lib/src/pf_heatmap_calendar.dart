import 'package:flutter/material.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';

import 'pf_chart_empty.dart';
import 'pf_chart_palette.dart';

/// A calendar-grid heatmap (GitHub-style) per design-system §10.25.
///
/// Renders a 7×N grid of [tileSize]-sized cells covering [from] through
/// [to]. Cell intensity is bucketed into 5 levels (0/25/50/75/100 %).
class PfHeatmapCalendar extends StatelessWidget {
  /// Default constructor.
  const PfHeatmapCalendar({
    super.key,
    required this.from,
    required this.to,
    required this.valueByDay,
    this.tileSize = 32,
    this.gap = 4,
    this.baseColor = PfChartPalette.indigo,
    this.onDayTap,
    this.maxValue,
  })  : assert(tileSize > 0, 'tileSize must be > 0'),
        assert(gap >= 0, 'gap must be ≥ 0');

  /// Inclusive start day (time component ignored).
  final DateTime from;

  /// Inclusive end day (time component ignored).
  final DateTime to;

  /// Value per day. Missing days are treated as 0.
  final Map<DateTime, double> valueByDay;

  /// Square cell size. Caller should pass `40` on tablet.
  final double tileSize;

  /// Spacing between cells.
  final double gap;

  /// Color used at 100 % intensity. Lower intensities are alpha-blends
  /// of this color.
  final Color baseColor;

  /// Tap callback (returns the tapped day, midnight-local).
  final ValueChanged<DateTime>? onDayTap;

  /// Override the max value for normalization. Defaults to the
  /// observed max across [valueByDay].
  final double? maxValue;

  @override
  Widget build(BuildContext context) {
    final DateTime start = _midnight(from);
    final DateTime end = _midnight(to);
    if (!end.isAfter(start) && !_sameDay(start, end)) {
      return PfChartEmpty(height: tileSize * 7 + gap * 6);
    }

    // Normalize values.
    final Map<DateTime, double> normalized = <DateTime, double>{
      for (final MapEntry<DateTime, double> e in valueByDay.entries)
        _midnight(e.key): e.value,
    };
    double maxV = maxValue ?? 0;
    if (maxValue == null) {
      for (final double v in normalized.values) {
        if (v > maxV) maxV = v;
      }
    }
    if (maxV <= 0) {
      // Render empty grid (all level-0 cells) — still useful skeleton.
      maxV = 1;
    }

    // Build weeks (columns). Each column has 7 cells (Mon..Sun).
    final List<List<DateTime?>> columns = _buildColumns(start, end);

    final ThemeData theme = Theme.of(context);
    final Color emptyCell =
        theme.colorScheme.onSurface.withValues(alpha: 0.06);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int c = 0; c < columns.length; c++) ...<Widget>[
            Column(
              children: <Widget>[
                for (int r = 0; r < 7; r++) ...<Widget>[
                  _buildCell(
                    columns[c][r],
                    normalized,
                    maxV,
                    emptyCell,
                  ),
                  if (r != 6) SizedBox(height: gap),
                ],
              ],
            ),
            if (c != columns.length - 1) SizedBox(width: gap),
          ],
        ],
      ),
    );
  }

  Widget _buildCell(
    DateTime? day,
    Map<DateTime, double> values,
    double maxV,
    Color emptyCell,
  ) {
    if (day == null) {
      return SizedBox(width: tileSize, height: tileSize);
    }
    final double v = values[day] ?? 0;
    final int level = _level(v, maxV);
    final Color color = level == 0
        ? emptyCell
        : baseColor.withValues(alpha: 0.25 * level);
    final Widget tile = Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PfTokens.radiusSm / 2),
      ),
    );
    if (onDayTap == null) return tile;
    return GestureDetector(
      onTap: () => onDayTap!(day),
      behavior: HitTestBehavior.opaque,
      child: tile,
    );
  }

  int _level(double v, double maxV) {
    if (v <= 0) return 0;
    final double ratio = v / maxV;
    if (ratio >= 0.75) return 4;
    if (ratio >= 0.50) return 3;
    if (ratio >= 0.25) return 2;
    return 1;
  }

  List<List<DateTime?>> _buildColumns(DateTime start, DateTime end) {
    // Align first column to Monday.
    final int startWeekday = start.weekday; // 1=Mon..7=Sun
    final DateTime firstMonday =
        start.subtract(Duration(days: startWeekday - 1));
    final List<List<DateTime?>> cols = <List<DateTime?>>[];
    DateTime cursor = firstMonday;
    while (!cursor.isAfter(end)) {
      final List<DateTime?> col = <DateTime?>[];
      for (int r = 0; r < 7; r++) {
        final DateTime day = cursor.add(Duration(days: r));
        if (day.isBefore(start) || day.isAfter(end)) {
          col.add(null);
        } else {
          col.add(day);
        }
      }
      cols.add(col);
      cursor = cursor.add(const Duration(days: 7));
    }
    return cols;
  }

  static DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);
  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
