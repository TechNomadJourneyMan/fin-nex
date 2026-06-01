// Compact 2-column stats card for the dashboard.
//
// Visualizes complementary numbers — e.g. "operations today" vs "spent
// today" — beneath the balance hero. Kept deliberately small so the page
// stays scannable on a 320 dp width.

import 'package:flutter/material.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

/// A pair of caption + headline blocks rendered side-by-side.
class QuickStatsCard extends StatelessWidget {
  /// Default constructor.
  const QuickStatsCard({
    super.key,
    required this.primaryLabel,
    required this.primaryValue,
    required this.secondaryLabel,
    required this.secondaryValue,
    this.primaryColor,
    this.secondaryColor,
  });

  /// Label of the left tile.
  final String primaryLabel;

  /// Pre-formatted value of the left tile.
  final String primaryValue;

  /// Label of the right tile.
  final String secondaryLabel;

  /// Pre-formatted value of the right tile.
  final String secondaryValue;

  /// Optional color override for the primary number.
  final Color? primaryColor;

  /// Optional color override for the secondary number.
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    return PfCard(
      elevation: 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _Tile(
              label: primaryLabel,
              value: primaryValue,
              color: primaryColor ?? colors.textPrimary,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: colors.divider,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _Tile(
                label: secondaryLabel,
                value: secondaryValue,
                color: secondaryColor ?? colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: typo.bodySm.copyWith(color: colors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: typo.amountLg.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
