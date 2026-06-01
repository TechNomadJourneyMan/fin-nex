import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:intl/intl.dart';

import 'pf_chart_empty.dart';
import 'pf_chart_palette.dart';

/// A single slice of a [PfDonutChart].
class PfDonutSlice {
  /// Default constructor.
  const PfDonutSlice({
    required this.label,
    required this.value,
    this.color,
  });

  /// Category label.
  final String label;

  /// Raw value (currency amount, count, etc.). Must be ≥ 0.
  final double value;

  /// Optional explicit color; if null the palette is used.
  final Color? color;
}

/// Donut chart used for the expense-structure card.
///
/// Per design-system §10.25:
///  * Outer radius 100, inner 70 (30dp thick).
///  * Tap to highlight a slice (offsets 8dp).
///  * Center shows total + label.
class PfDonutChart extends StatefulWidget {
  /// Default constructor.
  const PfDonutChart({
    super.key,
    required this.data,
    required this.semanticDescription,
    this.total,
    this.centerLabel,
    this.onSliceTap,
    this.numberFormat,
    this.size = 220,
    this.outerRadius = 100,
    this.innerRadius = 70,
  });

  /// Slices to render. Empty list → [PfChartEmpty] is shown instead.
  final List<PfDonutSlice> data;

  /// Human-readable screen-reader description of the chart's data. Exposed
  /// via [Semantics.value] so the chart is meaningful to assistive tech.
  final String semanticDescription;

  /// Pre-computed total. If null the sum of slice values is used.
  final double? total;

  /// Label shown under the total in the center.
  final String? centerLabel;

  /// Called with the slice index when a slice is tapped.
  /// `null` means deselected.
  final ValueChanged<int?>? onSliceTap;

  /// Number format for the center total.
  final NumberFormat? numberFormat;

  /// Square canvas size.
  final double size;

  /// Outer radius of the donut ring.
  final double outerRadius;

  /// Inner (hole) radius.
  final double innerRadius;

  @override
  State<PfDonutChart> createState() => _PfDonutChartState();
}

class _PfDonutChartState extends State<PfDonutChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return PfChartEmpty(height: widget.size);
    }
    final ThemeData theme = Theme.of(context);
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final NumberFormat fmt = widget.numberFormat ??
        NumberFormat.decimalPattern(
          Localizations.maybeLocaleOf(context)?.toLanguageTag(),
        );
    final double total = widget.total ??
        widget.data.fold<double>(0, (double s, PfDonutSlice e) => s + e.value);

    return Semantics(
      label: 'Donut chart',
      value: widget.semanticDescription,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: widget.innerRadius,
                startDegreeOffset: -90,
                sections: <PieChartSectionData>[
                  for (int i = 0; i < widget.data.length; i++)
                    _buildSection(i, widget.data[i], theme),
                ],
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback:
                      (FlTouchEvent event, PieTouchResponse? response) {
                    if (!event.isInterestedForInteractions) return;
                    final int? idx =
                        response?.touchedSection?.touchedSectionIndex;
                    setState(() => _selected = idx);
                    widget.onSliceTap?.call(idx);
                  },
                ),
              ),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            ),
            IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    fmt.format(total),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (widget.centerLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: PfTokens.space1),
                      child: Text(
                        widget.centerLabel!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildSection(
    int i,
    PfDonutSlice slice,
    ThemeData theme,
  ) {
    final bool selected = _selected == i;
    final Color color = slice.color ?? PfChartPalette.at(i);
    final double radius = selected
        ? widget.outerRadius - widget.innerRadius + 8
        : widget.outerRadius - widget.innerRadius;
    return PieChartSectionData(
      value: slice.value <= 0 ? 0.0001 : slice.value,
      color: color,
      radius: radius,
      showTitle: false,
      borderSide: selected
          ? BorderSide(color: theme.colorScheme.surface, width: 2)
          : BorderSide.none,
    );
  }
}
