// Slider widget for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// FinNex themed slider (e.g. budget tier).
class FnxSlider extends StatelessWidget {
  /// Creates a slider.
  const FnxSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.semanticLabel,
  });

  /// Current value.
  final double value;

  /// Value handler.
  final ValueChanged<double>? onChanged;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Optional discrete divisions.
  final int? divisions;

  /// Floating tooltip label.
  final String? label;

  /// A11y label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    return Semantics(
      slider: true,
      label: semanticLabel ?? label,
      value: value.toStringAsFixed(2),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: colors.brand,
          inactiveTrackColor: colors.borderSubtle,
          thumbColor: colors.brand,
          overlayColor: colors.brand.withValues(alpha: 0.16),
          valueIndicatorColor: colors.brand,
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
