import 'package:flutter/material.dart';

/// FinNex color tokens — primitive ramps plus semantic light/dark roles.
///
/// All values are sourced from `07_design_system.md` (sections 2.2–2.9).
/// Brand palette is Indigo-Aurora `#3D5AFE` with Mint `#00C896` for income.
@immutable
class FnxColors extends ThemeExtension<FnxColors> {
  /// Creates a [FnxColors] bundle. Use [FnxColors.light] or [FnxColors.dark]
  /// rather than instantiating directly.
  const FnxColors({
    required this.surfaceBackground,
    required this.surfaceDefault,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceBrand,
    required this.surfaceBrandSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textBrand,
    required this.textInverse,
    required this.textSuccess,
    required this.textError,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderBrand,
    required this.divider,
    required this.success,
    required this.successSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.error,
    required this.errorSubtle,
    required this.info,
    required this.infoSubtle,
  });

  // ---------------------------------------------------------------------------
  // Primitive — Indigo (brand)
  // ---------------------------------------------------------------------------
  /// Indigo 50 tint background.
  static const Color indigo50 = Color(0xFFEEF1FF);
  /// Indigo 100 — hover/pressed light.
  static const Color indigo100 = Color(0xFFD9DFFF);
  /// Indigo 200 — disabled foreground.
  static const Color indigo200 = Color(0xFFB4BEFF);
  /// Indigo 300.
  static const Color indigo300 = Color(0xFF8B9BFF);
  /// Indigo 400 — hover / dark-mode primary.
  static const Color indigo400 = Color(0xFF6478FF);
  /// Indigo 500 — primary brand.
  static const Color primary500 = Color(0xFF3D5AFE);
  /// Indigo 500 alias.
  static const Color indigo500 = primary500;
  /// Indigo 600 — pressed primary.
  static const Color indigo600 = Color(0xFF2E48E6);
  /// Indigo 700 — strong text on indigo.
  static const Color indigo700 = Color(0xFF2238B8);
  /// Indigo 800 — dark-mode primary container.
  static const Color indigo800 = Color(0xFF1A2A8C);
  /// Indigo 900.
  static const Color indigo900 = Color(0xFF0F1A5C);

  // ---------------------------------------------------------------------------
  // Primitive — Mint (accent / income)
  // ---------------------------------------------------------------------------
  /// Mint 100 — success tint.
  static const Color mint100 = Color(0xFFCCF4E6);
  /// Mint 500 — accent / income.
  static const Color mint500 = Color(0xFF00C896);
  /// Mint 600 — pressed accent.
  static const Color mint600 = Color(0xFF00A87D);

  // ---------------------------------------------------------------------------
  // Primitive — Coral / Amber
  // ---------------------------------------------------------------------------
  /// Coral 100.
  static const Color coral100 = Color(0xFFFFE0DC);
  /// Coral 500 — secondary / non-critical warnings.
  static const Color coral500 = Color(0xFFFF6B5C);
  /// Amber 500 — warning brand.
  static const Color amber500 = Color(0xFFFFB020);

  // ---------------------------------------------------------------------------
  // Primitive — Neutral ramp (11 steps + 0)
  // ---------------------------------------------------------------------------
  /// Neutral 0 — pure white.
  static const Color neutral0 = Color(0xFFFFFFFF);
  /// Neutral 50 — app background.
  static const Color neutral50 = Color(0xFFFAFBFC);
  /// Neutral 100 — secondary surface / skeleton.
  static const Color neutral100 = Color(0xFFF4F5F7);
  /// Neutral 200 — subtle border.
  static const Color neutral200 = Color(0xFFE8EAED);
  /// Neutral 300 — default border / divider.
  static const Color neutral300 = Color(0xFFD5D8DD);
  /// Neutral 400 — disabled foreground / placeholder.
  static const Color neutral400 = Color(0xFFA0A5AE);
  /// Neutral 500 — muted text / secondary icon.
  static const Color neutral500 = Color(0xFF6B7280);
  /// Neutral 600 — secondary text.
  static const Color neutral600 = Color(0xFF4B5563);
  /// Neutral 700 — alt body text.
  static const Color neutral700 = Color(0xFF374151);
  /// Neutral 800 — primary text alt.
  static const Color neutral800 = Color(0xFF1F2937);
  /// Neutral 900 — high-emphasis text.
  static const Color neutral900 = Color(0xFF111827);
  /// Neutral 950 — deep dark surface.
  static const Color neutral950 = Color(0xFF0A0E14);

  // ---------------------------------------------------------------------------
  // Semantic — Light mode
  // ---------------------------------------------------------------------------
  /// Success (light).
  static const Color successLight = Color(0xFF00A87D);
  /// Success subtle tint (light).
  static const Color successSubtleLight = Color(0xFFE6F8F1);
  /// Warning (light).
  static const Color warningLight = Color(0xFFE89500);
  /// Warning subtle tint (light).
  static const Color warningSubtleLight = Color(0xFFFFF4D9);
  /// Error (light).
  static const Color errorLight = Color(0xFFD9342B);
  /// Error subtle tint (light).
  static const Color errorSubtleLight = Color(0xFFFCE8E6);
  /// Info (light).
  static const Color infoLight = Color(0xFF0066CC);
  /// Info subtle tint (light).
  static const Color infoSubtleLight = Color(0xFFE6F0FA);
  /// AAA-contrast success text (light).
  static const Color textSuccessLight = Color(0xFF00805C);
  /// AAA-contrast error text (light).
  static const Color textErrorLight = Color(0xFFB82B23);

  // ---------------------------------------------------------------------------
  // Semantic — Dark mode (OmniFi OS — deep obsidian, glassmorphism-ready)
  // ---------------------------------------------------------------------------
  /// Dark surface background — deep obsidian (OLED-optimized).
  static const Color surfaceBackgroundDark = Color(0xFF0A0A0C);
  /// Dark default surface — subtle glass elevation.
  static const Color surfaceDefaultDark = Color(0x0DFFFFFF); // rgba 255/255/255/0.05
  /// Dark raised surface — stronger glass elevation.
  static const Color surfaceRaisedDark = Color(0x14FFFFFF); // rgba 255/255/255/0.08
  /// Dark sunken surface.
  static const Color surfaceSunkenDark = Color(0xFF070709);
  /// Dark primary text — soft white.
  static const Color textPrimaryDark = Color(0xFFF2F2F3);
  /// Dark secondary text — silvery.
  static const Color textSecondaryDark = Color(0xFF8A8A93);
  /// Dark muted text.
  static const Color textMutedDark = Color(0xFF5C5C66);
  /// Dark disabled text.
  static const Color textDisabledDark = Color(0xFF3C3C44);
  /// Dark subtle border — 0.5px hairline (~5% white).
  static const Color borderSubtleDark = Color(0x14FFFFFF);
  /// Dark default border (~8% white).
  static const Color borderDefaultDark = Color(0x1FFFFFFF);
  /// Dark strong border.
  static const Color borderStrongDark = Color(0x33FFFFFF);
  /// Dark divider.
  static const Color dividerDark = Color(0x14FFFFFF);
  /// Success (dark).
  static const Color successDark = Color(0xFF3FD9A8);
  /// Success subtle (dark).
  static const Color successSubtleDark = Color(0xFF143B2E);
  /// Warning (dark).
  static const Color warningDark = Color(0xFFFFB840);
  /// Warning subtle (dark).
  static const Color warningSubtleDark = Color(0xFF3D2E0A);
  /// Error (dark).
  static const Color errorDark = Color(0xFFFF6B5C);
  /// Error subtle (dark).
  static const Color errorSubtleDark = Color(0xFF3D1614);
  /// Info (dark).
  static const Color infoDark = Color(0xFF5AA3FF);
  /// Info subtle (dark).
  static const Color infoSubtleDark = Color(0xFF0F2238);

  // ---------------------------------------------------------------------------
  // Data-viz palette (8 colourblind-safe categories)
  // ---------------------------------------------------------------------------
  /// Data-viz #1 (Indigo) — light mode.
  static const Color dataviz1Light = Color(0xFF3D5AFE);
  /// Data-viz #2 (Mint) — light mode.
  static const Color dataviz2Light = Color(0xFF00C896);
  /// Data-viz #3 (Coral) — light mode.
  static const Color dataviz3Light = Color(0xFFFF6B5C);
  /// Data-viz #4 (Amber) — light mode.
  static const Color dataviz4Light = Color(0xFFFFB020);
  /// Data-viz #5 (Violet) — light mode.
  static const Color dataviz5Light = Color(0xFF8B5CF6);
  /// Data-viz #6 (Cyan) — light mode.
  static const Color dataviz6Light = Color(0xFF06B6D4);
  /// Data-viz #7 (Pink) — light mode.
  static const Color dataviz7Light = Color(0xFFEC4899);
  /// Data-viz #8 (Slate) — light mode.
  static const Color dataviz8Light = Color(0xFF6B7280);

  /// Data-viz #1 — dark mode.
  static const Color dataviz1Dark = Color(0xFF6478FF);
  /// Data-viz #2 — dark mode.
  static const Color dataviz2Dark = Color(0xFF3FD9A8);
  /// Data-viz #3 — dark mode.
  static const Color dataviz3Dark = Color(0xFFFF8A7D);
  /// Data-viz #4 — dark mode.
  static const Color dataviz4Dark = Color(0xFFFFC85C);
  /// Data-viz #5 — dark mode.
  static const Color dataviz5Dark = Color(0xFFA78BFA);
  /// Data-viz #6 — dark mode.
  static const Color dataviz6Dark = Color(0xFF22D3EE);
  /// Data-viz #7 — dark mode.
  static const Color dataviz7Dark = Color(0xFFF472B6);
  /// Data-viz #8 — dark mode.
  static const Color dataviz8Dark = Color(0xFF9CA3AF);

  /// Ordered light-mode chart palette (8 entries).
  static const List<Color> datavizLight = <Color>[
    dataviz1Light,
    dataviz2Light,
    dataviz3Light,
    dataviz4Light,
    dataviz5Light,
    dataviz6Light,
    dataviz7Light,
    dataviz8Light,
  ];

  /// Ordered dark-mode chart palette (8 entries).
  static const List<Color> datavizDark = <Color>[
    dataviz1Dark,
    dataviz2Dark,
    dataviz3Dark,
    dataviz4Dark,
    dataviz5Dark,
    dataviz6Dark,
    dataviz7Dark,
    dataviz8Dark,
  ];

  // ---------------------------------------------------------------------------
  // Semantic instance fields
  // ---------------------------------------------------------------------------
  /// App background surface.
  final Color surfaceBackground;
  /// Default card / sheet surface.
  final Color surfaceDefault;
  /// Raised surface (modals).
  final Color surfaceRaised;
  /// Sunken surface (inputs).
  final Color surfaceSunken;
  /// Brand surface (primary CTA).
  final Color surfaceBrand;
  /// Brand tint surface.
  final Color surfaceBrandSubtle;
  /// Primary text colour.
  final Color textPrimary;
  /// Secondary text colour.
  final Color textSecondary;
  /// Muted text / placeholder.
  final Color textMuted;
  /// Disabled text colour.
  final Color textDisabled;
  /// Brand text colour.
  final Color textBrand;
  /// Inverse text colour.
  final Color textInverse;
  /// Success amounts (AA/AAA on surface).
  final Color textSuccess;
  /// Error amounts.
  final Color textError;
  /// Subtle border (cards).
  final Color borderSubtle;
  /// Default border (inputs).
  final Color borderDefault;
  /// Strong border (focused emphasis).
  final Color borderStrong;
  /// Brand border (focus ring).
  final Color borderBrand;
  /// Divider line.
  final Color divider;
  /// Success accent.
  final Color success;
  /// Success tint.
  final Color successSubtle;
  /// Warning accent.
  final Color warning;
  /// Warning tint.
  final Color warningSubtle;
  /// Error accent.
  final Color error;
  /// Error tint.
  final Color errorSubtle;
  /// Info accent.
  final Color info;
  /// Info tint.
  final Color infoSubtle;

  /// Semantic light-mode token bundle.
  static const FnxColors light = FnxColors(
    surfaceBackground: neutral50,
    surfaceDefault: neutral0,
    surfaceRaised: neutral0,
    surfaceSunken: neutral100,
    surfaceBrand: primary500,
    surfaceBrandSubtle: indigo50,
    textPrimary: neutral900,
    textSecondary: neutral600,
    textMuted: neutral500,
    textDisabled: neutral400,
    textBrand: indigo600,
    textInverse: neutral0,
    textSuccess: textSuccessLight,
    textError: textErrorLight,
    borderSubtle: neutral200,
    borderDefault: neutral300,
    borderStrong: neutral500,
    borderBrand: primary500,
    divider: neutral200,
    success: successLight,
    successSubtle: successSubtleLight,
    warning: warningLight,
    warningSubtle: warningSubtleLight,
    error: errorLight,
    errorSubtle: errorSubtleLight,
    info: infoLight,
    infoSubtle: infoSubtleLight,
  );

  /// Semantic dark-mode token bundle.
  static const FnxColors dark = FnxColors(
    surfaceBackground: surfaceBackgroundDark,
    surfaceDefault: surfaceDefaultDark,
    surfaceRaised: surfaceRaisedDark,
    surfaceSunken: surfaceSunkenDark,
    surfaceBrand: indigo400,
    surfaceBrandSubtle: indigo800,
    textPrimary: textPrimaryDark,
    textSecondary: textSecondaryDark,
    textMuted: textMutedDark,
    textDisabled: textDisabledDark,
    textBrand: indigo300,
    textInverse: surfaceBackgroundDark,
    textSuccess: mint500,
    textError: errorDark,
    borderSubtle: borderSubtleDark,
    borderDefault: borderDefaultDark,
    borderStrong: borderStrongDark,
    borderBrand: indigo400,
    divider: dividerDark,
    success: successDark,
    successSubtle: successSubtleDark,
    warning: warningDark,
    warningSubtle: warningSubtleDark,
    error: errorDark,
    errorSubtle: errorSubtleDark,
    info: infoDark,
    infoSubtle: infoSubtleDark,
  );

  @override
  FnxColors copyWith({
    Color? surfaceBackground,
    Color? surfaceDefault,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? surfaceBrand,
    Color? surfaceBrandSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? textBrand,
    Color? textInverse,
    Color? textSuccess,
    Color? textError,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderBrand,
    Color? divider,
    Color? success,
    Color? successSubtle,
    Color? warning,
    Color? warningSubtle,
    Color? error,
    Color? errorSubtle,
    Color? info,
    Color? infoSubtle,
  }) {
    return FnxColors(
      surfaceBackground: surfaceBackground ?? this.surfaceBackground,
      surfaceDefault: surfaceDefault ?? this.surfaceDefault,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceBrand: surfaceBrand ?? this.surfaceBrand,
      surfaceBrandSubtle: surfaceBrandSubtle ?? this.surfaceBrandSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      textBrand: textBrand ?? this.textBrand,
      textInverse: textInverse ?? this.textInverse,
      textSuccess: textSuccess ?? this.textSuccess,
      textError: textError ?? this.textError,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderBrand: borderBrand ?? this.borderBrand,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      successSubtle: successSubtle ?? this.successSubtle,
      warning: warning ?? this.warning,
      warningSubtle: warningSubtle ?? this.warningSubtle,
      error: error ?? this.error,
      errorSubtle: errorSubtle ?? this.errorSubtle,
      info: info ?? this.info,
      infoSubtle: infoSubtle ?? this.infoSubtle,
    );
  }

  @override
  FnxColors lerp(ThemeExtension<FnxColors>? other, double t) {
    if (other is! FnxColors) return this;
    return FnxColors(
      surfaceBackground:
          Color.lerp(surfaceBackground, other.surfaceBackground, t)!,
      surfaceDefault: Color.lerp(surfaceDefault, other.surfaceDefault, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      surfaceBrand: Color.lerp(surfaceBrand, other.surfaceBrand, t)!,
      surfaceBrandSubtle:
          Color.lerp(surfaceBrandSubtle, other.surfaceBrandSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textBrand: Color.lerp(textBrand, other.textBrand, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textSuccess: Color.lerp(textSuccess, other.textSuccess, t)!,
      textError: Color.lerp(textError, other.textError, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderBrand: Color.lerp(borderBrand, other.borderBrand, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSubtle: Color.lerp(successSubtle, other.successSubtle, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSubtle: Color.lerp(warningSubtle, other.warningSubtle, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorSubtle: Color.lerp(errorSubtle, other.errorSubtle, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSubtle: Color.lerp(infoSubtle, other.infoSubtle, t)!,
    );
  }
}
