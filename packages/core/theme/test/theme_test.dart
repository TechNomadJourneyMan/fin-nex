import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_theme/theme.dart';
import 'package:fnx_core_tokens/tokens.dart';

void main() {
  test('FnxTheme.light builds without throwing and uses indigo primary', () {
    final ThemeData theme = FnxTheme.light();
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, FnxColors.primary500);
  });

  test('FnxTheme.dark builds without throwing', () {
    final ThemeData theme = FnxTheme.dark();
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, FnxColors.primary500);
  });

  test('Both themes register all FinNex extensions', () {
    for (final ThemeData theme in <ThemeData>[
      FnxTheme.light(),
      FnxTheme.dark(),
    ]) {
      expect(theme.extension<FnxColors>(), isNotNull);
      expect(theme.extension<FnxSpacing>(), isNotNull);
      expect(theme.extension<FnxRadius>(), isNotNull);
      expect(theme.extension<FnxElevation>(), isNotNull);
      expect(theme.extension<FnxMotion>(), isNotNull);
      expect(theme.extension<FnxTypography>(), isNotNull);
    }
  });

  testWidgets('BuildContext extensions resolve tokens from theme',
      (WidgetTester tester) async {
    late FnxColors colors;
    late FnxSpacing spacing;
    late FnxTypography typography;

    await tester.pumpWidget(
      MaterialApp(
        theme: FnxTheme.light(),
        home: Builder(
          builder: (BuildContext context) {
            colors = context.fnxColors;
            spacing = context.fnxSpacing;
            typography = context.fnxTypography;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(colors.surfaceBackground, FnxColors.neutral50);
    expect(FnxSpacing.x4, 16);
    // typography getter returns a valid TextStyle
    expect(typography.bodyL.fontSize, 16);
    // Ensure spacing extension lookup succeeded.
    expect(spacing, isA<FnxSpacing>());
  });
}
