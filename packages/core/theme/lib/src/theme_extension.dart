import 'package:flutter/material.dart';
import 'package:fnx_core_tokens/tokens.dart';

/// Convenience accessors so widgets can pull FinNex tokens directly from
/// a [BuildContext] without manually unwrapping [ThemeData.extension].
extension FnxThemeContext on BuildContext {
  /// Semantic colour bundle for the current theme.
  FnxColors get fnxColors =>
      Theme.of(this).extension<FnxColors>() ?? FnxColors.light;

  /// Spacing scale (static — same in every theme).
  FnxSpacing get fnxSpacing =>
      Theme.of(this).extension<FnxSpacing>() ?? const FnxSpacing();

  /// Radius scale.
  FnxRadius get fnxRadius =>
      Theme.of(this).extension<FnxRadius>() ?? const FnxRadius();

  /// Elevation scale.
  FnxElevation get fnxElevation =>
      Theme.of(this).extension<FnxElevation>() ?? const FnxElevation();

  /// Motion durations and curves.
  FnxMotion get fnxMotion =>
      Theme.of(this).extension<FnxMotion>() ?? const FnxMotion();

  /// Typography ramp.
  FnxTypography get fnxTypography =>
      Theme.of(this).extension<FnxTypography>() ?? const FnxTypography();
}
