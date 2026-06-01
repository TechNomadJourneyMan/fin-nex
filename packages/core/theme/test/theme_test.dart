import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_theme/theme.dart';
import 'package:pf_core_tokens/tokens.dart';

void main() {
  test('PfTheme.light builds without throwing and uses indigo primary', () {
    final ThemeData theme = PfTheme.light();
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, PfColors.primary500);
  });

  test('PfTheme.dark builds without throwing', () {
    final ThemeData theme = PfTheme.dark();
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, PfColors.primary500);
  });

  test('Both themes register all PocketFlow extensions', () {
    for (final ThemeData theme in <ThemeData>[
      PfTheme.light(),
      PfTheme.dark(),
    ]) {
      expect(theme.extension<PfColors>(), isNotNull);
      expect(theme.extension<PfSpacing>(), isNotNull);
      expect(theme.extension<PfRadius>(), isNotNull);
      expect(theme.extension<PfElevation>(), isNotNull);
      expect(theme.extension<PfMotion>(), isNotNull);
      expect(theme.extension<PfTypography>(), isNotNull);
    }
  });

  testWidgets('BuildContext extensions resolve tokens from theme',
      (WidgetTester tester) async {
    late PfColors colors;
    late PfSpacing spacing;
    late PfTypography typography;

    await tester.pumpWidget(
      MaterialApp(
        theme: PfTheme.light(),
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

    expect(colors.surfaceBackground, PfColors.neutral50);
    expect(PfSpacing.x4, 16);
    // typography getter returns a valid TextStyle
    expect(typography.bodyL.fontSize, 16);
    // Ensure spacing extension lookup succeeded.
    expect(spacing, isA<PfSpacing>());
  });
}
