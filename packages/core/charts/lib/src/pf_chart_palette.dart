import 'package:flutter/material.dart';

/// Data-viz palette used as fallback when a chart is given series without
/// explicit colors.
///
/// Mirrors the palette described in design-system §2.9. Concrete values
/// are intentionally local so this package does not depend on the
/// (not-yet-final) full token ramp.
abstract final class PfChartPalette {
  /// Primary brand-aligned ramp.
  static const Color indigo = Color(0xFF4F46E5);

  /// Positive / income.
  static const Color mint = Color(0xFF10B981);

  /// Warning / over-budget.
  static const Color amber = Color(0xFFF59E0B);

  /// Error / dangerous overflow.
  static const Color rose = Color(0xFFE11D48);

  /// Secondary categorical hues.
  static const Color sky = Color(0xFF0EA5E9);

  /// Tertiary categorical hue.
  static const Color violet = Color(0xFF8B5CF6);

  /// Quaternary categorical hue.
  static const Color teal = Color(0xFF14B8A6);

  /// Neutral muted gridline / axis color.
  static const Color neutral = Color(0xFF94A3B8);

  /// Default categorical palette, in display order.
  static const List<Color> categorical = <Color>[
    indigo,
    mint,
    amber,
    sky,
    violet,
    teal,
    rose,
  ];

  /// Returns the [index]-th categorical color, wrapping around.
  static Color at(int index) => categorical[index.abs() % categorical.length];
}
