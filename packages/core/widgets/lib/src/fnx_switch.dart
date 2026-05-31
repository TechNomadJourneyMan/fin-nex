// Switch widget for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// FinNex themed switch.
class FnxSwitch extends StatelessWidget {
  /// Creates a switch.
  const FnxSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  /// Current value.
  final bool value;

  /// Change handler.
  final ValueChanged<bool>? onChanged;

  /// A11y label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: colors.brand,
        activeTrackColor: colors.brand.withValues(alpha: 0.5),
        inactiveThumbColor: colors.surface,
        inactiveTrackColor: colors.borderDefault,
      ),
    );
  }
}
