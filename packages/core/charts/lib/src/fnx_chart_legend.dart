import 'package:flutter/material.dart';
import 'package:fnx_core_tokens/fnx_core_tokens.dart';

/// One row in a chart legend.
class FnxLegendEntry {
  /// Default constructor.
  const FnxLegendEntry({
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
class FnxChartLegend extends StatelessWidget {
  /// Default constructor.
  const FnxChartLegend({
    super.key,
    required this.entries,
    this.highlightedLabel,
    this.onTap,
  });

  /// Items to render, in display order.
  final List<FnxLegendEntry> entries;

  /// If non-null, the matching entry is rendered with stronger emphasis.
  final String? highlightedLabel;

  /// Optional tap callback wired to each row.
  final ValueChanged<FnxLegendEntry>? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Wrap(
      spacing: FnxTokens.space4,
      runSpacing: FnxTokens.space2,
      children: <Widget>[
        for (final FnxLegendEntry e in entries)
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

  final FnxLegendEntry entry;
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
        const SizedBox(width: FnxTokens.space2),
        Text(entry.label, style: label),
        if (entry.value != null) ...<Widget>[
          const SizedBox(width: FnxTokens.space2),
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
      borderRadius: BorderRadius.circular(FnxTokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FnxTokens.space1,
          vertical: FnxTokens.space1,
        ),
        child: row,
      ),
    );
  }
}
