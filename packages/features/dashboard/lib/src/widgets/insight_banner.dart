// Small banner used to surface a single insight or smart hint at the top
// of the dashboard. Optional — collapses to `SizedBox.shrink` when null.

import 'package:flutter/material.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

/// Banner that renders a single informational message with optional action.
class InsightBanner extends StatelessWidget {
  /// Default constructor.
  const InsightBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.icon = Icons.lightbulb_outline,
  });

  /// Body copy.
  final String message;

  /// Optional CTA label (e.g. "See details").
  final String? actionLabel;

  /// Tap handler for the CTA.
  final VoidCallback? onAction;

  /// Optional dismiss handler — shows an `X` button when non-null.
  final VoidCallback? onDismiss;

  /// Leading icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    return PfCard(
      elevation: 0,
      color: colors.infoSubtle,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: typo.bodyMd.copyWith(color: colors.textPrimary),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionLabel!,
                      style: typo.bodyMd.copyWith(
                        color: colors.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              icon: Icon(Icons.close, size: 18, color: colors.textMuted),
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
