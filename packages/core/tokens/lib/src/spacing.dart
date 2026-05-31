import 'package:flutter/material.dart';

/// FinNex spacing tokens — 4px base scale.
///
/// Field names use `xN` where `N` is the step index (`x4 = 16`).
@immutable
class FnxSpacing extends ThemeExtension<FnxSpacing> {
  /// Const constructor — all values are static.
  const FnxSpacing();

  /// 0 px.
  static const double x0 = 0;
  /// 4 px — icon-to-text within chips.
  static const double x1 = 4;
  /// 8 px — intra-component padding.
  static const double x2 = 8;
  /// 12 px — compact list spacing.
  static const double x3 = 12;
  /// 16 px — default card / screen padding.
  static const double x4 = 16;
  /// 24 px — section spacing.
  static const double x6 = 24;
  /// 32 px — hero spacing.
  static const double x8 = 32;
  /// 48 px — large block separator.
  static const double x12 = 48;
  /// 64 px — empty state breathing room.
  static const double x16 = 64;

  @override
  FnxSpacing copyWith() => const FnxSpacing();

  @override
  FnxSpacing lerp(ThemeExtension<FnxSpacing>? other, double t) => this;
}
