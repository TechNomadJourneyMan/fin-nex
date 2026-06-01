// Numeric text field with thousands separators.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'pf_text_field.dart';

/// Input formatter that groups digits with locale separators while typing.
class PfThousandsFormatter extends TextInputFormatter {
  /// Creates a thousands formatter for [locale].
  PfThousandsFormatter({this.locale = 'ru'});

  /// Locale tag for separator selection.
  final String locale;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) {
      return const TextEditingValue();
    }
    final number = int.tryParse(raw);
    if (number == null) {
      return oldValue;
    }
    final formatted = NumberFormat.decimalPattern(locale).format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Numeric text field that formats with locale-aware thousands separators.
class PfNumericField extends StatelessWidget {
  /// Creates a numeric field.
  const PfNumericField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.helperText,
    this.errorText,
    this.locale = 'ru',
    this.suffixIcon,
    this.enabled = true,
  });

  /// Field label.
  final String? label;

  /// Placeholder hint.
  final String? hint;

  /// Controller (text is the formatted value).
  final TextEditingController? controller;

  /// Called with raw digits when the value changes.
  final ValueChanged<int?>? onChanged;

  /// Helper text.
  final String? helperText;

  /// Error message.
  final String? errorText;

  /// Locale used for separators.
  final String locale;

  /// Optional trailing icon.
  final IconData? suffixIcon;

  /// Whether enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PfTextField(
      label: label,
      hint: hint,
      controller: controller,
      helperText: helperText,
      errorText: errorText,
      suffixIcon: suffixIcon,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [PfThousandsFormatter(locale: locale)],
      onChanged: (value) {
        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
        onChanged?.call(digits.isEmpty ? null : int.tryParse(digits));
      },
    );
  }
}
