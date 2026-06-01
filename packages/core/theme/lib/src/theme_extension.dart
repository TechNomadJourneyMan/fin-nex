import 'package:flutter/material.dart';
import 'package:pf_core_tokens/tokens.dart';

/// Convenience accessors so widgets can pull PocketFlow tokens directly from
/// a [BuildContext] without manually unwrapping [ThemeData.extension].
extension PfThemeContext on BuildContext {
  /// Semantic colour bundle for the current theme.
  PfColors get fnxColors =>
      Theme.of(this).extension<PfColors>() ?? PfColors.light;

  /// Spacing scale (static — same in every theme).
  PfSpacing get fnxSpacing =>
      Theme.of(this).extension<PfSpacing>() ?? const PfSpacing();

  /// Radius scale.
  PfRadius get fnxRadius =>
      Theme.of(this).extension<PfRadius>() ?? const PfRadius();

  /// Elevation scale.
  PfElevation get fnxElevation =>
      Theme.of(this).extension<PfElevation>() ?? const PfElevation();

  /// Motion durations and curves.
  PfMotion get fnxMotion =>
      Theme.of(this).extension<PfMotion>() ?? const PfMotion();

  /// Typography ramp.
  PfTypography get fnxTypography =>
      Theme.of(this).extension<PfTypography>() ?? const PfTypography();
}
