// List item widget for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// PocketFlow list item (leading + title/subtitle + trailing).
class PfListItem extends StatelessWidget {
  /// Creates a list item.
  const PfListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.dense = false,
    this.semanticLabel,
  });

  /// Leading widget (avatar, icon).
  final Widget? leading;

  /// Title text.
  final String title;

  /// Optional secondary text.
  final String? subtitle;

  /// Trailing widget.
  final Widget? trailing;

  /// Tap handler.
  final VoidCallback? onTap;

  /// Long-press handler.
  final VoidCallback? onLongPress;

  /// Use 56 dp dense layout (default 72).
  final bool dense;

  /// Optional a11y label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final height = dense ? 56.0 : 72.0;

    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: typo.bodyLg
                              .copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style: typo.bodySm
                                  .copyWith(color: colors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
