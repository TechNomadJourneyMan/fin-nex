import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PocketFlow typography ramp.
///
/// Body uses Inter; numeric/mono uses JetBrains Mono (loaded via
/// `google_fonts`). Tabular numerals are enabled for amount styles.
@immutable
class PfTypography extends ThemeExtension<PfTypography> {
  /// Default const constructor — uses Google Fonts lazily via getters.
  const PfTypography();

  static const String _interFamily = 'Inter';
  static const String _monoFamily = 'JetBrainsMono';

  static const FontFeature _tabularNums = FontFeature.tabularFigures();

  /// Inter base text style (registered via `google_fonts`).
  static TextStyle _inter({
    required double size,
    required double height,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: const <String>[_interFamily]);
  }

  /// JetBrains Mono base style with tabular numerals enabled.
  static TextStyle _mono({
    required double size,
    required double height,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      fontFeatures: const <FontFeature>[_tabularNums],
    ).copyWith(fontFamilyFallback: const <String>[_monoFamily]);
  }

  /// Display large — onboarding hero / big numbers (48 / 56, w700).
  TextStyle get displayLg => _inter(
        size: 48,
        height: 56,
        weight: FontWeight.w700,
        letterSpacing: -0.96,
      );

  /// Display medium — dashboard hero amount (36 / 44, w700).
  TextStyle get displayMd => _inter(
        size: 36,
        height: 44,
        weight: FontWeight.w700,
        letterSpacing: -0.72,
      );

  /// Display small — section heros (30 / 36, w600).
  TextStyle get displaySm => _inter(
        size: 30,
        height: 36,
        weight: FontWeight.w600,
        letterSpacing: -0.30,
      );

  /// Heading 1 — screen title (24 / 32, w600).
  TextStyle get h1 => _inter(
        size: 24,
        height: 32,
        weight: FontWeight.w600,
        letterSpacing: -0.24,
      );

  /// Heading 2 — card title (20 / 28, w600).
  TextStyle get h2 => _inter(
        size: 20,
        height: 28,
        weight: FontWeight.w600,
        letterSpacing: -0.10,
      );

  /// Heading 3 — subsection (18 / 26, w600).
  TextStyle get h3 => _inter(
        size: 18,
        height: 26,
        weight: FontWeight.w600,
      );

  /// Body large — default body (16 / 24, w400).
  TextStyle get bodyL => _inter(
        size: 16,
        height: 24,
        weight: FontWeight.w400,
      );

  /// Body medium — default secondary (14 / 20, w400).
  TextStyle get bodyM => _inter(
        size: 14,
        height: 20,
        weight: FontWeight.w400,
      );

  /// Body small — captions / metadata (13 / 18, w400).
  TextStyle get bodyS => _inter(
        size: 13,
        height: 18,
        weight: FontWeight.w400,
        letterSpacing: 0.065,
      );

  /// Caption — timestamps / micro labels (12 / 16, w500).
  TextStyle get caption => _inter(
        size: 12,
        height: 16,
        weight: FontWeight.w500,
        letterSpacing: 0.12,
      );

  /// Overline — group headers (11 / 16, w600, uppercase).
  TextStyle get overline => _inter(
        size: 11,
        height: 16,
        weight: FontWeight.w600,
        letterSpacing: 0.88,
      );

  /// Mono large amount — hero amounts (24 / 28, w600 + tnum).
  TextStyle get monoAmountLg => _mono(
        size: 24,
        height: 28,
        weight: FontWeight.w600,
        letterSpacing: -0.24,
      );

  /// Mono medium amount — list item amounts (18 / 24, w600 + tnum).
  TextStyle get monoAmountMd => _mono(
        size: 18,
        height: 24,
        weight: FontWeight.w600,
        letterSpacing: -0.09,
      );

  /// Mono small amount — inline amounts (14 / 20, w500 + tnum).
  TextStyle get monoAmountSm => _mono(
        size: 14,
        height: 20,
        weight: FontWeight.w500,
      );

  /// Generic mono style — alias to medium amount for general numeric text.
  TextStyle get mono => monoAmountMd;

  /// Button label (15 / 20, w600).
  TextStyle get button => _inter(
        size: 15,
        height: 20,
        weight: FontWeight.w600,
        letterSpacing: 0.15,
      );

  @override
  PfTypography copyWith() => const PfTypography();

  @override
  PfTypography lerp(ThemeExtension<PfTypography>? other, double t) {
    return this;
  }
}
