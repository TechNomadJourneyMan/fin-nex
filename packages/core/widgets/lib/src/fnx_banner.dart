// Inline banner widget for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// Banner tone.
enum FnxBannerTone {
  /// Neutral informational tone.
  info,

  /// Success tone.
  success,

  /// Warning tone.
  warning,

  /// Error tone.
  error,
}

/// Inline FinNex banner.
class FnxBanner extends StatelessWidget {
  /// Creates a banner.
  const FnxBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = FnxBannerTone.info,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  /// Banner body text.
  final String message;

  /// Optional banner title.
  final String? title;

  /// Banner tone.
  final FnxBannerTone tone;

  /// Optional action label.
  final String? actionLabel;

  /// Action callback.
  final VoidCallback? onAction;

  /// Dismiss callback.
  final VoidCallback? onDismiss;

  ({Color bg, Color fg, IconData icon}) _palette(FnxSemanticColors c) {
    switch (tone) {
      case FnxBannerTone.info:
        return (bg: c.infoSubtle, fg: c.info, icon: Icons.info_outline);
      case FnxBannerTone.success:
        return (bg: c.successSubtle, fg: c.success, icon: Icons.check_circle_outline);
      case FnxBannerTone.warning:
        return (bg: c.warningSubtle, fg: c.warning, icon: Icons.warning_amber_outlined);
      case FnxBannerTone.error:
        return (bg: c.errorSubtle, fg: c.error, icon: Icons.error_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final palette = _palette(colors);

    return Semantics(
      container: true,
      liveRegion: tone == FnxBannerTone.error || tone == FnxBannerTone.warning,
      label: title ?? message,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: BorderRadius.circular(context.fnxRadii.r3),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(palette.icon, color: palette.fg, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: typo.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  Text(
                    message,
                    style: typo.bodySm.copyWith(color: colors.textPrimary),
                  ),
                  if (actionLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: onAction,
                        child: Text(
                          actionLabel!,
                          style: typo.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: palette.fg,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close, color: colors.textSecondary, size: 18),
                splashRadius: 18,
              ),
          ],
        ),
      ),
    );
  }
}
