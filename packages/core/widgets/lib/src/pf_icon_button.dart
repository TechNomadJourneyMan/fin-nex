// Icon button widget for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// PocketFlow icon button with brand ripple.
class PfIconButton extends StatelessWidget {
  /// Creates a PocketFlow icon button.
  const PfIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.size = 44,
    this.iconSize = 22,
    this.color,
    this.backgroundColor,
  });

  /// Icon to display.
  final IconData icon;

  /// Tap handler.
  final VoidCallback? onPressed;

  /// Accessibility label.
  final String? semanticLabel;

  /// Tooltip text.
  final String? tooltip;

  /// Hit-target diameter (>= 44 recommended).
  final double size;

  /// Icon glyph size.
  final double iconSize;

  /// Icon color override.
  final Color? color;

  /// Background color override.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final radius = context.fnxRadii;
    final disabled = onPressed == null;
    final fg = color ?? colors.textPrimary;

    final widget = Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(radius.r3),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(radius.r3),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, size: iconSize, color: fg),
          ),
        ),
      ),
    );

    final semantic = Semantics(
      button: true,
      enabled: !disabled,
      label: semanticLabel ?? tooltip,
      child: widget,
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: semantic);
    }
    return semantic;
  }
}
