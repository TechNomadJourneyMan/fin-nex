// Avatar widget for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// PocketFlow circular avatar — supports initials, icon, or network image.
class PfAvatar extends StatelessWidget {
  /// Creates an avatar.
  const PfAvatar({
    super.key,
    this.initials,
    this.icon,
    this.imageUrl,
    this.size = 40,
    this.color,
    this.semanticLabel,
  });

  /// Up-to-two character initials.
  final String? initials;

  /// Icon glyph (alternative to initials).
  final IconData? icon;

  /// Network image URL.
  final String? imageUrl;

  /// Diameter (default 40).
  final double size;

  /// Background tint color.
  final Color? color;

  /// A11y label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final accent = color ?? colors.brand;
    final bg = accent.withValues(alpha: 0.12);

    Widget child;
    if (imageUrl != null) {
      child = ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(icon ?? Icons.person, color: accent, size: size * 0.55),
        ),
      );
    } else if (icon != null) {
      child = Icon(icon, color: accent, size: size * 0.55);
    } else {
      final text = (initials ?? '?').substring(
        0,
        (initials ?? '?').length > 2 ? 2 : (initials ?? '?').length,
      );
      child = Text(
        text.toUpperCase(),
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
        ),
      );
    }

    return Semantics(
      label: semanticLabel ?? initials,
      image: imageUrl != null,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}
