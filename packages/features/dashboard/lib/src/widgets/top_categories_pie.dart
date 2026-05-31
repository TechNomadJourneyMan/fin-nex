// Top categories breakdown card.
//
// Wraps `FnxDonutChart` from `fnx_core_charts` with dashboard-specific
// layout (header + chart + "see all" link + legend) and tolerates the
// empty-state by short-circuiting to a small placeholder.

import 'package:flutter/material.dart' hide Category;
import 'package:fnx_core_charts/fnx_core_charts.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';

/// Donut card showing the top spend categories.
class TopCategoriesPie extends StatelessWidget {
  /// Default constructor.
  const TopCategoriesPie({
    super.key,
    required this.slices,
    required this.categoriesById,
    required this.title,
    this.seeAllLabel,
    this.onSeeAll,
    this.emptyText = 'No category data yet.',
  });

  /// Top-N category slices to render.
  final List<CategoryBreakdownSlice> slices;

  /// Lookup so the legend can resolve names and colors.
  final Map<Ulid, Category> categoriesById;

  /// Card title (e.g. "Top categories").
  final String title;

  /// Optional "see all" CTA label.
  final String? seeAllLabel;

  /// Tap handler for the "see all" link.
  final VoidCallback? onSeeAll;

  /// Fallback string when [slices] is empty.
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    final donutData = <FnxDonutSlice>[
      for (final s in slices)
        FnxDonutSlice(
          label: categoriesById[s.categoryId]?.name ?? '—',
          value: s.percent * 100,
          color: _hexToColor(categoriesById[s.categoryId]?.color.hex),
        ),
    ];

    return FnxCard(
      elevation: 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: typo.heading3)),
              if (seeAllLabel != null && onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(seeAllLabel!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (slices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  emptyText,
                  style: typo.bodyMd.copyWith(color: colors.textMuted),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: FnxDonutChart(
                data: donutData,
                size: 180,
                outerRadius: 80,
                innerRadius: 56,
              ),
            ),
        ],
      ),
    );
  }

  static Color? _hexToColor(String? hex) {
    if (hex == null) return null;
    final raw = hex.startsWith('#') ? hex.substring(1) : hex;
    final v = int.tryParse(raw, radix: 16);
    if (v == null) return null;
    return Color(0xFF000000 | v);
  }
}
