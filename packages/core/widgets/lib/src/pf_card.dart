// Card surface for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// PocketFlow surface card.
class PfCard extends StatelessWidget {
  /// Creates a card.
  const PfCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation = 1,
    this.onTap,
    this.color,
    this.borderRadius,
  });

  /// Inner widget.
  final Widget child;

  /// Inner padding (defaults to 16).
  final EdgeInsetsGeometry? padding;

  /// Elevation level (0..2 commonly).
  final double elevation;

  /// Tap callback (makes the card interactive).
  final VoidCallback? onTap;

  /// Background color override.
  final Color? color;

  /// Border radius override.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final radius = borderRadius ?? BorderRadius.circular(context.fnxRadii.r4);
    final pad = padding ?? EdgeInsets.all(context.fnxSpacing.s5);

    Widget content = Container(
      padding: pad,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: radius,
        border: Border.all(color: colors.borderSubtle),
        boxShadow: elevation <= 0
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4 + elevation * 4,
                  offset: Offset(0, elevation),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return content;
  }
}
