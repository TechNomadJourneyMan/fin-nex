// AI insight card for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// PocketFlow insight card (AI-generated tip, with optional CTA).
class PfInsightCard extends StatelessWidget {
  /// Creates an insight card.
  const PfInsightCard({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.auto_awesome,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  /// Insight title.
  final String title;

  /// Insight body.
  final String body;

  /// Leading icon.
  final IconData icon;

  /// CTA label.
  final String? actionLabel;

  /// CTA callback.
  final VoidCallback? onAction;

  /// Dismiss callback.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    return Semantics(
      label: title,
      hint: body,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.brandSubtle, colors.income.withValues(alpha: 0.18)],
          ),
          borderRadius: BorderRadius.circular(context.fnxRadii.r4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.brand, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: typo.bodyLg.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(Icons.close,
                        color: colors.textSecondary, size: 18),
                    splashRadius: 18,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body,
                style: typo.bodyMd.copyWith(color: colors.textPrimary)),
            if (actionLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel!,
                    style: typo.bodyMd.copyWith(
                      color: colors.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
