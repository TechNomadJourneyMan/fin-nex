// Dropdown / select wrapper for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// Generic option used by [PfSelect].
class PfSelectOption<T> {
  /// Creates a select option.
  const PfSelectOption({required this.value, required this.label, this.icon});

  /// Value to emit when picked.
  final T value;

  /// Visible label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;
}

/// Themed dropdown wrapper.
class PfSelect<T> extends StatelessWidget {
  /// Creates a select.
  const PfSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
    this.hint,
    this.errorText,
  });

  /// Currently selected value.
  final T? value;

  /// Available options.
  final List<PfSelectOption<T>> options;

  /// Called when the user changes the selection.
  final ValueChanged<T?> onChanged;

  /// Optional label above the field.
  final String? label;

  /// Placeholder.
  final String? hint;

  /// Validation error.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final radius = context.fnxRadii;
    final spacing = context.fnxSpacing;

    return Semantics(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: typo.bodySm.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: spacing.s2),
          ],
          DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            items: [
              for (final option in options)
                DropdownMenuItem<T>(
                  value: option.value,
                  child: Row(
                    children: [
                      if (option.icon != null) ...[
                        Icon(option.icon, size: 18, color: colors.textSecondary),
                        SizedBox(width: spacing.s3),
                      ],
                      Flexible(
                        child: Text(option.label,
                            style: typo.bodyMd, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
            ],
            onChanged: onChanged,
            hint: hint == null
                ? null
                : Text(hint!,
                    style: typo.bodyMd.copyWith(color: colors.textMuted)),
            decoration: InputDecoration(
              errorText: errorText,
              filled: true,
              fillColor: colors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.r3),
                borderSide: BorderSide(color: colors.borderDefault),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.r3),
                borderSide: BorderSide(color: colors.borderDefault),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.r3),
                borderSide: BorderSide(color: colors.brand, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
