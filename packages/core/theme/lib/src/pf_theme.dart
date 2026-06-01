import 'package:flutter/material.dart';
import 'package:pf_core_tokens/tokens.dart';

/// PocketFlow Material 3 theme builders.
///
/// Wire from `MaterialApp(theme: PfTheme.light(), darkTheme: PfTheme.dark())`.
/// Both builds embed the full PocketFlow token set as `ThemeExtension`s, so
/// widgets can read tokens with `Theme.of(context).extension<PfColors>()`.
abstract final class PfTheme {
  /// Build the light [ThemeData].
  static ThemeData light() => _build(
        brightness: Brightness.light,
        colors: PfColors.light,
      );

  /// Build the dark [ThemeData].
  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        colors: PfColors.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required PfColors colors,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final PfTypography typography = const PfTypography();

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: PfColors.primary500,
      onPrimary: PfColors.neutral0,
      primaryContainer:
          isDark ? PfColors.indigo800 : PfColors.indigo50,
      onPrimaryContainer:
          isDark ? PfColors.indigo100 : PfColors.indigo700,
      secondary: PfColors.mint500,
      onSecondary: PfColors.neutral900,
      secondaryContainer:
          isDark ? PfColors.successSubtleDark : PfColors.mint100,
      onSecondaryContainer:
          isDark ? PfColors.mint500 : PfColors.mint600,
      tertiary: PfColors.coral500,
      onTertiary: PfColors.neutral0,
      tertiaryContainer:
          isDark ? PfColors.errorSubtleDark : PfColors.coral100,
      onTertiaryContainer:
          isDark ? PfColors.coral500 : PfColors.coral500,
      error: colors.error,
      onError: PfColors.neutral0,
      errorContainer: colors.errorSubtle,
      onErrorContainer: colors.error,
      surface: colors.surfaceDefault,
      onSurface: colors.textPrimary,
      surfaceContainerLowest: colors.surfaceBackground,
      surfaceContainerLow: colors.surfaceBackground,
      surfaceContainer: colors.surfaceDefault,
      surfaceContainerHigh: colors.surfaceRaised,
      surfaceContainerHighest: colors.surfaceRaised,
      surfaceTint: PfColors.primary500,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.borderDefault,
      outlineVariant: colors.borderSubtle,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: isDark ? PfColors.neutral50 : PfColors.neutral900,
      onInverseSurface:
          isDark ? PfColors.neutral900 : PfColors.neutral50,
      inversePrimary:
          isDark ? PfColors.indigo600 : PfColors.indigo300,
    );

    final TextTheme textTheme = TextTheme(
      displayLarge: typography.displayLg.copyWith(color: colors.textPrimary),
      displayMedium: typography.displayMd.copyWith(color: colors.textPrimary),
      displaySmall: typography.displaySm.copyWith(color: colors.textPrimary),
      headlineLarge: typography.h1.copyWith(color: colors.textPrimary),
      headlineMedium: typography.h2.copyWith(color: colors.textPrimary),
      headlineSmall: typography.h3.copyWith(color: colors.textPrimary),
      titleLarge: typography.h2.copyWith(color: colors.textPrimary),
      titleMedium: typography.h3.copyWith(color: colors.textPrimary),
      titleSmall: typography.bodyM.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: typography.bodyL.copyWith(color: colors.textPrimary),
      bodyMedium: typography.bodyM.copyWith(color: colors.textSecondary),
      bodySmall: typography.bodyS.copyWith(color: colors.textMuted),
      labelLarge: typography.button.copyWith(color: colors.textPrimary),
      labelMedium: typography.caption.copyWith(color: colors.textSecondary),
      labelSmall: typography.overline.copyWith(color: colors.textMuted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.surfaceBackground,
      canvasColor: colors.surfaceDefault,
      dividerColor: colors.divider,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfaceBackground,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: typography.h2.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceDefault,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: PfRadius.xl,
          side: BorderSide(color: colors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PfColors.primary500,
          foregroundColor: PfColors.neutral0,
          disabledBackgroundColor: colors.textDisabled,
          disabledForegroundColor: colors.textInverse,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: PfSpacing.x4,
            vertical: PfSpacing.x3,
          ),
          textStyle: typography.button,
          shape: const RoundedRectangleBorder(borderRadius: PfRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PfColors.primary500,
          foregroundColor: PfColors.neutral0,
          elevation: 0,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: PfSpacing.x4,
            vertical: PfSpacing.x3,
          ),
          textStyle: typography.button,
          shape: const RoundedRectangleBorder(borderRadius: PfRadius.lg),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textBrand,
          side: BorderSide(color: colors.borderDefault),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: PfSpacing.x4,
            vertical: PfSpacing.x3,
          ),
          textStyle: typography.button,
          shape: const RoundedRectangleBorder(borderRadius: PfRadius.lg),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textBrand,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: PfSpacing.x3,
            vertical: PfSpacing.x2,
          ),
          textStyle: typography.button,
          shape: const RoundedRectangleBorder(borderRadius: PfRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSunken,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PfSpacing.x4,
          vertical: PfSpacing.x3,
        ),
        hintStyle: typography.bodyM.copyWith(color: colors.textMuted),
        labelStyle: typography.bodyS.copyWith(color: colors.textSecondary),
        helperStyle: typography.caption.copyWith(color: colors.textSecondary),
        errorStyle: typography.caption.copyWith(color: colors.textError),
        border: OutlineInputBorder(
          borderRadius: PfRadius.md,
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: PfRadius.md,
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PfRadius.md,
          borderSide: BorderSide(color: colors.borderBrand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: PfRadius.md,
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: PfRadius.md,
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: PfRadius.md,
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceRaised,
        modalBackgroundColor: colors.surfaceRaised,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: colors.borderDefault,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSunken,
        selectedColor: colors.surfaceBrandSubtle,
        disabledColor: colors.surfaceSunken,
        labelStyle: typography.caption.copyWith(color: colors.textPrimary),
        secondaryLabelStyle:
            typography.caption.copyWith(color: colors.textBrand),
        padding: const EdgeInsets.symmetric(
          horizontal: PfSpacing.x3,
          vertical: PfSpacing.x1,
        ),
        shape: const RoundedRectangleBorder(borderRadius: PfRadius.pill),
        side: BorderSide(color: colors.borderSubtle),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceRaised,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        titleTextStyle: typography.h2.copyWith(color: colors.textPrimary),
        contentTextStyle:
            typography.bodyM.copyWith(color: colors.textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? PfColors.neutral50
            : PfColors.neutral900,
        contentTextStyle: typography.bodyM.copyWith(
          color: isDark ? PfColors.neutral900 : PfColors.neutral0,
        ),
        actionTextColor: PfColors.indigo300,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: PfRadius.md),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surfaceDefault,
        selectedItemColor: colors.textBrand,
        unselectedItemColor: colors.textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: typography.caption,
        unselectedLabelStyle: typography.caption,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceDefault,
        indicatorColor: colors.surfaceBrandSubtle,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => typography.caption.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.textBrand
                : colors.textMuted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.textBrand
                : colors.textMuted,
            size: 24,
          ),
        ),
        height: 64,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: IconThemeData(color: colors.textPrimary, size: 24),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PfColors.primary500,
        linearTrackColor: PfColors.neutral200,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? PfColors.neutral0
              : PfColors.neutral0,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? PfColors.primary500
              : PfColors.neutral300,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? PfColors.primary500
              : Colors.transparent,
        ),
        side: BorderSide(color: colors.borderDefault, width: 2),
        shape: const RoundedRectangleBorder(borderRadius: PfRadius.sm),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? PfColors.primary500
              : colors.borderDefault,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? PfColors.neutral50 : PfColors.neutral900,
          borderRadius: PfRadius.sm,
        ),
        textStyle: typography.caption.copyWith(
          color: isDark ? PfColors.neutral900 : PfColors.neutral0,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        colors,
        const PfSpacing(),
        const PfRadius(),
        const PfElevation(),
        const PfMotion(),
        typography,
      ],
    );
  }
}
