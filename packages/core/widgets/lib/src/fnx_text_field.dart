// Text field widget for FinNex.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fnx_theme_ext.dart';

/// FinNex outlined text field.
class FnxTextField extends StatelessWidget {
  /// Creates a FinNex text field.
  const FnxTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscure = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Field label, shown above the input.
  final String? label;

  /// Placeholder hint.
  final String? hint;

  /// Helper text shown below the input.
  final String? helperText;

  /// Error message (when non-null overrides helper).
  final String? errorText;

  /// Optional leading icon.
  final IconData? prefixIcon;

  /// Optional trailing icon.
  final IconData? suffixIcon;

  /// Obscure the text (passwords).
  final bool obscure;

  /// Controller for the field.
  final TextEditingController? controller;

  /// Validator for [Form] usage.
  final String? Function(String?)? validator;

  /// Called when the value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits.
  final ValueChanged<String>? onSubmitted;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Input action.
  final TextInputAction? textInputAction;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Optional max length.
  final int? maxLength;

  /// Max visible lines.
  final int maxLines;

  /// Whether the input is enabled.
  final bool enabled;

  /// Autofocus on mount.
  final bool autofocus;

  /// Optional override for semantic label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final radius = context.fnxRadii;
    final typo = context.fnxTypography;
    final spacing = context.fnxSpacing;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius.r3),
      borderSide: BorderSide(color: colors.borderDefault),
    );

    return Semantics(
      textField: true,
      label: semanticLabel ?? label,
      value: errorText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: typo.bodySm
                  .copyWith(fontWeight: FontWeight.w500, color: colors.textSecondary),
            ),
            SizedBox(height: spacing.s2),
          ],
          TextFormField(
            controller: controller,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            maxLines: obscure ? 1 : maxLines,
            enabled: enabled,
            autofocus: autofocus,
            validator: validator,
            style: typo.bodyMd,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: typo.bodyMd.copyWith(color: colors.textMuted),
              helperText: errorText == null ? helperText : null,
              errorText: errorText,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: colors.textMuted, size: 20)
                  : null,
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: colors.textMuted, size: 20)
                  : null,
              filled: true,
              fillColor: enabled ? colors.surface : colors.surfaceSunken,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.r3),
                borderSide: BorderSide(color: colors.brand, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.r3),
                borderSide: BorderSide(color: colors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.r3),
                borderSide: BorderSide(color: colors.error, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
