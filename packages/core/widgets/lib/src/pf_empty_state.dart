// Empty-state widget for Pocket Flow.

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'pf_button.dart';
import 'pf_theme_ext.dart';

/// Pocket Flow empty / null-state placeholder.
///
/// Visual priority for the leading graphic:
///   1. [illustration] (an explicit widget), if provided;
///   2. a [Lottie] animation loaded from [lottieAsset], if provided;
///   3. a static [icon] fallback.
///
/// The Lottie asset is loaded from the `pf_core_widgets` package bundle, so
/// callers only pass the asset path (e.g.
/// `assets/lottie/empty_transactions.json`).
class PfEmptyState extends StatelessWidget {
  /// Creates an empty state.
  const PfEmptyState({
    super.key,
    required this.title,
    required this.body,
    this.illustration,
    this.lottieAsset,
    this.icon = Icons.inbox_outlined,
    this.ctaLabel,
    this.onCta,
  });

  /// Optional illustration widget. Takes precedence over [lottieAsset] and
  /// [icon].
  final Widget? illustration;

  /// Optional Lottie animation asset path (within `pf_core_widgets`). Used
  /// when [illustration] is null. Falls back to [icon] when null.
  final String? lottieAsset;

  /// Fallback icon when neither [illustration] nor [lottieAsset] is provided.
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
    // Honour the OS "reduce motion" toggle: freeze the Lottie on its first
    // frame rather than looping. This also keeps widget tests deterministic
    // under `pumpAndSettle` (an infinitely-repeating Lottie never settles).
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

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
            _leading(colors.textMuted, animate: !reduceMotion),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: typo.heading2,
            ),
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

  Widget _leading(Color iconColor, {required bool animate}) {
    if (illustration != null) {
      return illustration!;
    }
    if (lottieAsset != null) {
      return SizedBox(
        height: 140,
        child: ExcludeSemantics(
          child: Lottie.asset(
            lottieAsset!,
            package: 'pf_core_widgets',
            animate: animate,
            repeat: true,
            // Static first frame if the asset is missing or fails to decode,
            // so the empty state never crashes the page.
            errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
                Icon(icon, size: 64, color: iconColor),
          ),
        ),
      );
    }
    return Icon(icon, size: 64, color: iconColor);
  }
}
