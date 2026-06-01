// Theme convenience extension for PocketFlow widgets.
//
// Bridges raw color/typography primitives into a semantic API
// (colors, spacing, typography) that widgets can read off `BuildContext`.
// This layer intentionally lives inside the widgets package so widgets are
// not coupled to a particular ThemeExtension shape.
//
// IMPORTANT: The public token classes (`PfColors`, `PfSpacing`,
// `PfRadius`, `PfTypography`, etc.) live in `package:pf_core_tokens` and
// are the single source of truth. To avoid dual-import collisions in feature
// code that imports both the tokens and widgets barrels, this file defines
// its semantic helpers under distinct names (`PfSemanticColors`,
// `PfSemanticSpacing`, `PfSemanticTypography`) and `PfRadii` (a separate
// helper from the tokens' `PfRadius`). Widgets consume them via the
// `context.fnxColors`, `context.fnxSpacing`, `context.fnxRadii`, and
// `context.fnxTypography` extensions below.

import 'package:flutter/material.dart';

/// Semantic color palette for PocketFlow widgets.
///
/// Distinct from `PfColors` in `pf_core_tokens` (which is a Material
/// `ThemeExtension`). This type exposes the field shape that widgets in
/// this package rely on (e.g. `brand`, `surface`, `income`).
class PfSemanticColors {
  /// Build a semantic palette.
  const PfSemanticColors._({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.brand,
    required this.brandSubtle,
    required this.onBrand,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textInverse,
    required this.success,
    required this.successSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.error,
    required this.errorSubtle,
    required this.info,
    required this.infoSubtle,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.divider,
    required this.income,
  });

  /// App background.
  final Color background;

  /// Default surface (cards).
  final Color surface;

  /// Raised surface (sheets, dialogs).
  final Color surfaceRaised;

  /// Sunken surface (inputs).
  final Color surfaceSunken;

  /// Primary brand color.
  final Color brand;

  /// Brand tint (subtle background).
  final Color brandSubtle;

  /// Foreground on top of brand.
  final Color onBrand;

  /// Primary text.
  final Color textPrimary;

  /// Secondary text (captions, helpers).
  final Color textSecondary;

  /// Muted text (placeholders, timestamps).
  final Color textMuted;

  /// Disabled text.
  final Color textDisabled;

  /// Text on dark backgrounds.
  final Color textInverse;

  /// Success semantic color.
  final Color success;

  /// Success subtle (tint background).
  final Color successSubtle;

  /// Warning semantic color.
  final Color warning;

  /// Warning subtle (tint background).
  final Color warningSubtle;

  /// Error semantic color.
  final Color error;

  /// Error subtle (tint background).
  final Color errorSubtle;

  /// Info semantic color.
  final Color info;

  /// Info subtle (tint background).
  final Color infoSubtle;

  /// Subtle border (cards).
  final Color borderSubtle;

  /// Default border (inputs).
  final Color borderDefault;

  /// Strong border (focused, emphasis).
  final Color borderStrong;

  /// Divider color.
  final Color divider;

  /// Income amount color (mint).
  final Color income;

  /// Light palette derived from spec semantics.
  static const PfSemanticColors light = PfSemanticColors._(
    background: Color(0xFFFAFBFC),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF4F5F7),
    brand: Color(0xFF3D5AFE),
    brandSubtle: Color(0xFFEEF1FF),
    onBrand: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textMuted: Color(0xFF6B7280),
    textDisabled: Color(0xFFA0A5AE),
    textInverse: Color(0xFFFFFFFF),
    success: Color(0xFF00A87D),
    successSubtle: Color(0xFFE6F8F1),
    warning: Color(0xFFE89500),
    warningSubtle: Color(0xFFFFF4D9),
    error: Color(0xFFD9342B),
    errorSubtle: Color(0xFFFCE8E6),
    info: Color(0xFF0066CC),
    infoSubtle: Color(0xFFE6F0FA),
    borderSubtle: Color(0xFFE8EAED),
    borderDefault: Color(0xFFD5D8DD),
    borderStrong: Color(0xFF6B7280),
    divider: Color(0xFFE8EAED),
    income: Color(0xFF00C896),
  );

  /// Dark palette derived from spec semantics.
  static const PfSemanticColors dark = PfSemanticColors._(
    background: Color(0xFF0F1115),
    surface: Color(0xFF161A21),
    surfaceRaised: Color(0xFF1E232C),
    surfaceSunken: Color(0xFF0A0D12),
    brand: Color(0xFF6478FF),
    brandSubtle: Color(0xFF1A2A8C),
    onBrand: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFF0F2F5),
    textSecondary: Color(0xFFB8BCC4),
    textMuted: Color(0xFF7C8290),
    textDisabled: Color(0xFF4A4F58),
    textInverse: Color(0xFF0F1115),
    success: Color(0xFF3FD9A8),
    successSubtle: Color(0xFF143B2E),
    warning: Color(0xFFFFB840),
    warningSubtle: Color(0xFF3D2E0A),
    error: Color(0xFFFF6B5C),
    errorSubtle: Color(0xFF3D1614),
    info: Color(0xFF5AA3FF),
    infoSubtle: Color(0xFF0F2238),
    borderSubtle: Color(0xFF262B35),
    borderDefault: Color(0xFF363C47),
    borderStrong: Color(0xFF5A6170),
    divider: Color(0xFF1F242E),
    income: Color(0xFF00C896),
  );
}

/// Semantic spacing scale (4-pt base).
///
/// Distinct from `PfSpacing` in `pf_core_tokens` (which is a Material
/// `ThemeExtension` with `xN` constants).
class PfSemanticSpacing {
  /// Default const constructor.
  const PfSemanticSpacing();

  /// 0 px.
  double get s0 => 0;

  /// 2 px hairline gap.
  double get s1 => 2;

  /// 4 px.
  double get s2 => 4;

  /// 8 px.
  double get s3 => 8;

  /// 12 px.
  double get s4 => 12;

  /// 16 px (default).
  double get s5 => 16;

  /// 24 px section gap.
  double get s6 => 24;

  /// 32 px hero gap.
  double get s7 => 32;

  /// 48 px.
  double get s8 => 48;

  /// 64 px.
  double get s9 => 64;
}

/// Semantic radius scale.
///
/// Note: this is *not* `PfRadius` from `pf_core_tokens`; widgets in this
/// package use `rN` getters, so we keep this as a separate helper.
class PfRadii {
  /// Default const constructor.
  const PfRadii();

  /// 4 px (chips, tags).
  double get r1 => 4;

  /// 8 px (sm controls).
  double get r2 => 8;

  /// 12 px (default buttons, inputs).
  double get r3 => 12;

  /// 16 px (cards).
  double get r4 => 16;

  /// 24 px (sheets).
  double get r5 => 24;

  /// 32 px (dialogs).
  double get r6 => 32;

  /// Full pill.
  double get full => 9999;
}

/// Semantic typography styles for PocketFlow widgets.
///
/// Distinct from `PfTypography` in `pf_core_tokens` (which is a Material
/// `ThemeExtension` exposing `h1/h2/h3`, `bodyL/M/S`, `monoAmountLg/Md/Sm`).
/// This helper exposes the field shape that widgets in this package rely on.
class PfSemanticTypography {
  /// Build a typography set from a [TextTheme].
  const PfSemanticTypography(this._base, this._textColor);

  final TextTheme _base;
  final Color _textColor;

  /// Display hero amount.
  TextStyle get displayLg => TextStyle(
        fontSize: 48,
        height: 1.10,
        letterSpacing: -0.96,
        fontWeight: FontWeight.w700,
        color: _textColor,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Display medium hero.
  TextStyle get displayMd => TextStyle(
        fontSize: 36,
        height: 1.15,
        letterSpacing: -0.72,
        fontWeight: FontWeight.w700,
        color: _textColor,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Section hero.
  TextStyle get displaySm => TextStyle(
        fontSize: 30,
        height: 1.20,
        letterSpacing: -0.30,
        fontWeight: FontWeight.w600,
        color: _textColor,
      );

  /// Screen title.
  TextStyle get heading1 => TextStyle(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: _textColor,
      );

  /// Card title.
  TextStyle get heading2 => TextStyle(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: _textColor,
      );

  /// Subsection.
  TextStyle get heading3 => TextStyle(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w600,
        color: _textColor,
      );

  /// Default body.
  TextStyle get bodyLg => TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: _textColor,
      );

  /// Secondary body.
  TextStyle get bodyMd => TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: _textColor,
      );

  /// Caption.
  TextStyle get bodySm => TextStyle(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: _textColor,
      );

  /// Caption.
  TextStyle get caption => TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: _textColor,
      );

  /// Overline labels.
  TextStyle get overline => TextStyle(
        fontSize: 11,
        height: 16 / 11,
        letterSpacing: 0.88,
        fontWeight: FontWeight.w600,
        color: _textColor,
      );

  /// Tabular amount large.
  TextStyle get amountLg => TextStyle(
        fontSize: 24,
        height: 28 / 24,
        fontWeight: FontWeight.w600,
        color: _textColor,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Tabular amount medium.
  TextStyle get amountMd => TextStyle(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        color: _textColor,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Tabular amount small.
  TextStyle get amountSm => TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: _textColor,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Button label.
  TextStyle get button => TextStyle(
        fontSize: 15,
        height: 20 / 15,
        letterSpacing: 0.15,
        fontWeight: FontWeight.w600,
        color: _textColor,
      );

  /// Fallback to base [TextTheme] (rarely used).
  TextTheme get material => _base;
}

/// Resolve semantic helpers from [BuildContext].
extension PfThemeExt on BuildContext {
  /// Semantic color palette for the current brightness.
  PfSemanticColors get fnxColors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? PfSemanticColors.dark
        : PfSemanticColors.light;
  }

  /// Spacing scale.
  PfSemanticSpacing get fnxSpacing => const PfSemanticSpacing();

  /// Radii scale.
  PfRadii get fnxRadii => const PfRadii();

  /// Typography scale.
  PfSemanticTypography get fnxTypography =>
      PfSemanticTypography(Theme.of(this).textTheme, fnxColors.textPrimary);
}
