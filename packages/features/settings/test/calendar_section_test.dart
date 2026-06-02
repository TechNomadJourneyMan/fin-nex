// Verifies the Calendar settings section connects and persists a choice.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_calendar/pf_calendar.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_feat_settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('connect lists calendars and persists the chosen id',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final store = InMemoryPreferencesStore();
    final stub = StubCalendarService(
      calendars: const <PfCalendar>[
        PfCalendar(id: 'cal-a', name: 'Personal', accountName: 'me@x.com'),
        PfCalendar(id: 'cal-b', name: 'Family', accountName: 'me@x.com'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          preferencesStoreProvider.overrideWithValue(store),
          calendarServiceProvider.overrideWithValue(stub),
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
          home: Scaffold(body: CalendarSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially not connected.
    expect(find.text('Not connected'), findsOneWidget);

    // Tap connect.
    await tester.tap(find.byKey(const Key('settings.calendar.connect')));
    await tester.pumpAndSettle();

    // Calendars now listed.
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);

    // Choose "Family" → persisted under pf_calendar_id.
    await tester.tap(find.byKey(const Key('settings.calendar.option.cal-b')));
    await tester.pumpAndSettle();

    expect(await store.getString(kCalendarIdKey), 'cal-b');
    expect(find.text('Using Family'), findsOneWidget);
  });
}
