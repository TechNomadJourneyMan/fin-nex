// Renders the settings root and asserts each section appears.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_feat_settings/settings.dart';

void main() {
  testWidgets('SettingsRootPage renders all sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          preferencesStoreProvider.overrideWithValue(
            InMemoryPreferencesStore(),
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
    expect(find.text('About'), findsOneWidget);
  });
}
