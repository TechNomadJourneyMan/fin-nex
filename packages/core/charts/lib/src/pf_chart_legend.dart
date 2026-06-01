import 'package:flutter/material.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';

/// One row in a chart legend.
class PfLegendEntry {
  /// Default constructor.
  const PfLegendEntry({
    required this.label,
    required this.color,
    this.value,
  });

  /// Human-readable category label.
  final String label;

  /// Swatch color.
  final Color color;

  /// Optional pre-formatted value (e.g. `12 000 ₸`).
  final String? value;
}

/// Shared chart legend rendered as a wrapping 2-column grid.
class PfChartLegend extends StatelessWidget {
  /// Default constructor.
  const PfChartLegend({
    super.key,
    required this.entries,
    this.highlightedLabel,
    this.onTap,
  });

  /// Items to render, in display order.
  final List<PfLegendEntry> entries;

  /// If non-null, the matching entry is rendered with stronger emphasis.
  final String? highlightedLabel;

  /// Optional tap callback wired to each row.
  final ValueChanged<PfLegendEntry>? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Wrap(
      spacing: PfTokens.space4,
      runSpacing: PfTokens.space2,
      children: <Widget>[
        for (final PfLegendEntry e in entries)
          _LegendRow(
            entry: e,
            highlighted: e.label == highlightedLabel,
            theme: theme,
            onTap: onTap == null ? null : () => onTap!(e),
          ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.entry,
    required this.highlighted,
    required this.theme,
    this.onTap,
  });

  final PfLegendEntry entry;
  final bool highlighted;
  final ThemeData theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = theme.textTheme.bodySmall;
    final TextStyle? label = highlighted
        ? base?.copyWith(fontWeight: FontWeight.w600)
        : base;
    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: entry.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: PfTokens.space2),
        Text(entry.label, style: label),
        if (entry.value != null) ...<Widget>[
          const SizedBox(width: PfTokens.space2),
          Text(
            entry.value!,
            style: label?.copyWith(
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PfTokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PfTokens.space1,
          vertical: PfTokens.space1,
        ),
        child: row,
      ),
    );
  }
}
