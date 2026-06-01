// Legacy aggregate kept for back-compat with the initial scaffolding.
//
// The full design system lives in the `PfColors`, `PfSpacing`, `PfRadius`,
// `PfElevation`, `PfTypography`, `PfMotion`, and `PfBreakpoints` classes
// under `package:pf_core_tokens/tokens.dart`. This file mirrors the most
// commonly referenced primitives so older imports keep compiling.

import 'package:flutter/material.dart';

import 'colors.dart';
import 'radius.dart';
import 'spacing.dart';

/// Legacy aggregate of the most-used PocketFlow tokens.
///
/// Prefer the dedicated `Pf*` classes for new code.
abstract final class PfTokens {
  /// Primary brand color (Indigo 500).
  static const Color brandPrimary = PfColors.primary500;

  /// Default background for dark surfaces.
  static const Color surfaceDark = PfColors.surfaceBackgroundDark;

  /// Default background for light surfaces.
  static const Color surfaceLight = PfColors.neutral50;

  /// 4 px spacing unit.
  static const double space1 = PfSpacing.x1;

  /// 8 px spacing unit.
  static const double space2 = PfSpacing.x2;

  /// 12 px spacing unit.
  static const double space3 = PfSpacing.x3;

  /// 16 px spacing unit.
  static const double space4 = PfSpacing.x4;

  /// 24 px spacing unit.
  static const double space6 = PfSpacing.x6;

  /// 32 px spacing unit.
  static const double space8 = PfSpacing.x8;

  /// Small corner radius (8 px).
  static const double radiusSm = 8;

  /// Medium corner radius (12 px).
  static const double radiusMd = 12;

  /// Large corner radius (16 px).
  static const double radiusLg = 16;

  /// Convenience: pill radius matches [PfRadius.pill].
  static const BorderRadius pillRadius = PfRadius.pill;
}
