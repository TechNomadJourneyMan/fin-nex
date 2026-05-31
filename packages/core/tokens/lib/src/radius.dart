import 'package:flutter/material.dart';

/// FinNex corner-radius tokens.
@immutable
class FnxRadius extends ThemeExtension<FnxRadius> {
  /// Const constructor.
  const FnxRadius();

  /// Zero radius (sharp).
  static const BorderRadius none = BorderRadius.zero;
  /// 4 px radius — chips, tags.
  static const BorderRadius sm = BorderRadius.all(Radius.circular(4));
  /// 8 px radius — text fields, small buttons.
  static const BorderRadius md = BorderRadius.all(Radius.circular(8));
  /// 12 px radius — default buttons / inputs.
  static const BorderRadius lg = BorderRadius.all(Radius.circular(12));
  /// 16 px radius — cards / list items.
  static const BorderRadius xl = BorderRadius.all(Radius.circular(16));
  /// 24 px radius — bottom sheets.
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(24));
  /// Full pill (999 px).
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));

  @override
  FnxRadius copyWith() => const FnxRadius();

  @override
  FnxRadius lerp(ThemeExtension<FnxRadius>? other, double t) => this;
}
