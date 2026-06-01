// Primary button widget for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// Visual variant of [PfButton].
enum PfButtonVariant {
  /// Solid brand fill, white text. One per screen.
  primary,

  /// Neutral fill, primary text. Secondary actions.
  secondary,

  /// Transparent fill, brand text. Tertiary actions.
  ghost,

  /// Red fill for destructive actions.
  destructive,
}

/// Size of [PfButton].
enum PfButtonSize {
  /// 36 dp height.
  sm,

  /// 44 dp height (default).
  md,

  /// 52 dp height.
  lg,
}

/// PocketFlow branded button.
///
/// All variants meet the 44 dp minimum touch target and resolve colors from
/// the theme via [PfThemeExt].
class PfButton extends StatelessWidget {
  /// Creates a PocketFlow button.
  const PfButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PfButtonVariant.primary,
    this.size = PfButtonSize.md,
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
  final PfButtonVariant variant;

  /// Size token.
  final PfButtonSize size;

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
      case PfButtonSize.sm:
        return 36;
      case PfButtonSize.md:
        return 44;
      case PfButtonSize.lg:
        return 52;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case PfButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case PfButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case PfButtonSize.lg:
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
      case PfButtonVariant.primary:
        bg = colors.brand;
        fg = colors.onBrand;
        border = null;
      case PfButtonVariant.secondary:
        bg = colors.surfaceSunken;
        fg = colors.textPrimary;
        border = null;
      case PfButtonVariant.ghost:
        bg = Colors.transparent;
        fg = colors.brand;
        border = null;
      case PfButtonVariant.destructive:
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
      child:
          fullWidth ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
