// Primary button widget for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// Visual variant of [FnxButton].
enum FnxButtonVariant {
  /// Solid brand fill, white text. One per screen.
  primary,

  /// Neutral fill, primary text. Secondary actions.
  secondary,

  /// Transparent fill, brand text. Tertiary actions.
  ghost,

  /// Red fill for destructive actions.
  destructive,
}

/// Size of [FnxButton].
enum FnxButtonSize {
  /// 36 dp height.
  sm,

  /// 44 dp height (default).
  md,

  /// 52 dp height.
  lg,
}

/// FinNex branded button.
///
/// All variants meet the 44 dp minimum touch target and resolve colors from
/// the theme via [FnxThemeExt].
class FnxButton extends StatelessWidget {
  /// Creates a FinNex button.
  const FnxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FnxButtonVariant.primary,
    this.size = FnxButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    this.semanticLabel,
  });

  /// Button label text.
  final String label;

  /// Tap handler. `null` disables the button.
  final VoidCallback? onPressed;

  /// Visual variant.
  final FnxButtonVariant variant;

  /// Size token.
  final FnxButtonSize size;

  /// Optional leading icon.
  final IconData? leadingIcon;

  /// Optional trailing icon.
  final IconData? trailingIcon;

  /// Shows a spinner in place of the label when true.
  final bool loading;

  /// Stretches to fill parent width when true.
  final bool fullWidth;

  /// Optional override for semantic label (a11y).
  final String? semanticLabel;

  double get _height {
    switch (size) {
      case FnxButtonSize.sm:
        return 36;
      case FnxButtonSize.md:
        return 44;
      case FnxButtonSize.lg:
        return 52;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case FnxButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case FnxButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case FnxButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final radius = context.fnxRadii;
    final typo = context.fnxTypography;
    final disabled = onPressed == null || loading;

    late final Color bg;
    late final Color fg;
    late final Color? border;
    switch (variant) {
      case FnxButtonVariant.primary:
        bg = colors.brand;
        fg = colors.onBrand;
        border = null;
      case FnxButtonVariant.secondary:
        bg = colors.surfaceSunken;
        fg = colors.textPrimary;
        border = null;
      case FnxButtonVariant.ghost:
        bg = Colors.transparent;
        fg = colors.brand;
        border = null;
      case FnxButtonVariant.destructive:
        bg = colors.error;
        fg = colors.onBrand;
        border = null;
    }

    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: typo.button.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, size: 18, color: fg),
              ],
            ],
          );

    final button = Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(radius.r3),
        shape: border != null
            ? RoundedRectangleBorder(
                side: BorderSide(color: border),
                borderRadius: BorderRadius.circular(radius.r3),
              )
            : null,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(radius.r3),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: _height, minWidth: _height),
            child: Padding(padding: _padding, child: Center(child: child)),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      label: semanticLabel ?? label,
      child: fullWidth
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
