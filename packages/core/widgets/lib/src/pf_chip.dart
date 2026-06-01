// Chip widget for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// PocketFlow chip with optional selected state.
class PfChip extends StatelessWidget {
  /// Creates a chip.
  const PfChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.color,
    this.semanticLabel,
  });

  /// Chip label.
  final String label;

  /// Whether the chip is selected.
  final bool selected;

  /// Tap handler.
  final VoidCallback? onTap;

  /// Optional leading icon.
  final IconData? icon;

  /// Override accent color (e.g. category color).
  final Color? color;

  /// A11y override.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final accent = color ?? colors.brand;
    final bg = selected ? accent.withValues(alpha: 0.12) : colors.surfaceSunken;
    final fg = selected ? accent : colors.textSecondary;
    final border = selected ? accent : Colors.transparent;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticLabel ?? label,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(context.fnxRadii.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.fnxRadii.full),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.fnxRadii.full),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: typo.caption
                      .copyWith(fontWeight: FontWeight.w600, color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
