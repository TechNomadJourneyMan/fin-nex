// Legacy aggregate kept for back-compat with the initial scaffolding.
//
// The full design system lives in the `FnxColors`, `FnxSpacing`, `FnxRadius`,
// `FnxElevation`, `FnxTypography`, `FnxMotion`, and `FnxBreakpoints` classes
// under `package:fnx_core_tokens/tokens.dart`. This file mirrors the most
// commonly referenced primitives so older imports keep compiling.

import 'package:flutter/material.dart';

import 'colors.dart';
import 'radius.dart';
import 'spacing.dart';

/// Legacy aggregate of the most-used FinNex tokens.
///
/// Prefer the dedicated `Fnx*` classes for new code.
abstract final class FnxTokens {
  /// Primary brand color (Indigo 500).
  static const Color brandPrimary = FnxColors.primary500;

  /// Default background for dark surfaces.
  static const Color surfaceDark = FnxColors.surfaceBackgroundDark;

  /// Default background for light surfaces.
  static const Color surfaceLight = FnxColors.neutral50;

  /// 4 px spacing unit.
  static const double space1 = FnxSpacing.x1;
  /// 8 px spacing unit.
  static const double space2 = FnxSpacing.x2;
  /// 12 px spacing unit.
  static const double space3 = FnxSpacing.x3;
  /// 16 px spacing unit.
  static const double space4 = FnxSpacing.x4;
  /// 24 px spacing unit.
  static const double space6 = FnxSpacing.x6;
  /// 32 px spacing unit.
  static const double space8 = FnxSpacing.x8;

  /// Small corner radius (8 px).
  static const double radiusSm = 8;
  /// Medium corner radius (12 px).
  static const double radiusMd = 12;
  /// Large corner radius (16 px).
  static const double radiusLg = 16;

  /// Convenience: pill radius matches [FnxRadius.pill].
  static const BorderRadius pillRadius = FnxRadius.pill;
}
