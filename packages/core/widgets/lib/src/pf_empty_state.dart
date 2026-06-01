// Empty-state widget for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_button.dart';
import 'pf_theme_ext.dart';

/// PocketFlow empty / null-state placeholder.
class PfEmptyState extends StatelessWidget {
  /// Creates an empty state.
  const PfEmptyState({
    super.key,
    required this.title,
    required this.body,
    this.illustration,
    this.icon = Icons.inbox_outlined,
    this.ctaLabel,
    this.onCta,
  });

  /// Optional illustration widget.
  final Widget? illustration;

  /// Fallback icon when no illustration is provided.
  final IconData icon;

  /// Title text.
  final String title;

  /// Body text.
  final String body;

  /// Optional CTA label.
  final String? ctaLabel;

  /// CTA callback.
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    return Semantics(
      label: title,
      hint: body,
      container: true,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration ??
                Icon(icon, size: 64, color: colors.textMuted),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center, style: typo.heading2),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: typo.bodyMd.copyWith(color: colors.textSecondary),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 24),
              PfButton(label: ctaLabel!, onPressed: onCta),
            ],
          ],
        ),
      ),
    );
  }
}
