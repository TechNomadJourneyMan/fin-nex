// Numeric badge for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// FinNex numeric badge (e.g. notification counter).
class FnxBadge extends StatelessWidget {
  /// Creates a numeric badge.
  const FnxBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.color,
  });

  /// Display count.
  final int count;

  /// Maximum count before `+` suffix is used.
  final int maxCount;

  /// Background color override.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    final colors = context.fnxColors;
    final text = count > maxCount ? '$maxCount+' : '$count';

    return Semantics(
      label: '$count',
      child: Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color ?? colors.error,
          borderRadius: BorderRadius.circular(context.fnxRadii.full),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: colors.onBrand,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
