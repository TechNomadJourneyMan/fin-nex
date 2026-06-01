// Renders the settings root and asserts each section appears.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_feat_settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('SettingsRootPage renders all sections', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          preferencesStoreProvider.overrideWithValue(
            InMemoryPreferencesStore(),
          ),
          feedbackServiceProvider.overrideWith(
            (Ref ref) => FeedbackService(prefs: prefs),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: <Locale>[Locale('en'), Locale('ru'), Locale('kk')],
          home: SettingsRootPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    // "About" sits at the bottom of the list and may be offscreen after the
    // new "Sound & Haptics" section pushed everything down — scroll it into
    // view before asserting.
    await tester.scrollUntilVisible(find.text('About'), 200);
    expect(find.text('About'), findsOneWidget);
  });
}
