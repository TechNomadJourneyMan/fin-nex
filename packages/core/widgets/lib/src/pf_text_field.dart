// Text field widget for PocketFlow.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';

import 'pf_theme_ext.dart';

/// PocketFlow outlined text field.
class PfTextField extends StatefulWidget {
  /// Creates a PocketFlow text field.
  const PfTextField({
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
    this.focusNode,
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

  /// Optional external focus node. When provided, the caller owns its
  /// lifecycle (e.g. to programmatically focus the field); otherwise the
  /// field manages an internal node.
  final FocusNode? focusNode;

  @override
  State<PfTextField> createState() => _PfTextFieldState();
}

class _PfTextFieldState extends State<PfTextField> {
  FocusNode? _internalFocusNode;
  bool _focused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final radius = context.fnxRadii;
    final typo = context.fnxTypography;
    final spacing = context.fnxSpacing;

    // The InputDecorator already animates border transitions internally, but
    // we wrap the field in an AnimatedContainer so the *outer* border ramps
    // its width 1 -> 2 and color neutral -> primary using PfMotion tokens.
    // This honors reduced-motion via PfMotion.effective.
    final Duration borderDuration = PfMotion.effective(context, PfMotion.fast);
    final Color borderColor = widget.errorText != null
        ? colors.error
        : (_focused ? colors.brand : colors.borderDefault);
    final double borderWidth = _focused || widget.errorText != null ? 2 : 1;

    // The TextFormField uses transparent inner borders so the only visible
    // ring is the AnimatedContainer outline.
    final OutlineInputBorder noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius.r3),
      borderSide: BorderSide.none,
    );

    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.label,
      value: widget.errorText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: typo.bodySm.copyWith(
                  fontWeight: FontWeight.w500, color: colors.textSecondary),
            ),
            SizedBox(height: spacing.s2),
          ],
          AnimatedContainer(
            duration: borderDuration,
            curve: PfEasing.standard,
            decoration: BoxDecoration(
              color: widget.enabled ? colors.surface : colors.surfaceSunken,
              borderRadius: BorderRadius.circular(radius.r3),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              obscureText: widget.obscure,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              maxLength: widget.maxLength,
              maxLines: widget.obscure ? 1 : widget.maxLines,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              validator: widget.validator,
              style: typo.bodyMd,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: typo.bodyMd.copyWith(color: colors.textMuted),
                helperText: widget.errorText == null ? widget.helperText : null,
                errorText: widget.errorText,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: colors.textMuted,
                        size: 20,
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? Icon(
                        widget.suffixIcon,
                        color: colors.textMuted,
                        size: 20,
                      )
                    : null,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: noBorder,
                enabledBorder: noBorder,
                focusedBorder: noBorder,
                errorBorder: noBorder,
                focusedErrorBorder: noBorder,
                disabledBorder: noBorder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
