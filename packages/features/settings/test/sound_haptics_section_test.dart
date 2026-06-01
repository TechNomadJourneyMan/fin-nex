// Widget tests for [SoundHapticsSection] — exercises the toggle wiring and
// the preview button.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_feat_settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoopPlayer implements PfAudioPlayer {
  @override
  Future<void> setAsset(String assetPath, {String? package}) async {}
  @override
  Future<void> replay() async {}
  @override
  Future<void> dispose() async {}
}

class _RecordingHaptics extends PfHapticChannel {
  _RecordingHaptics();
  final List<PfFeedbackKind> calls = <PfFeedbackKind>[];

  @override
  void trigger(PfFeedbackKind kind) => calls.add(kind);
}

Future<void> _pumpSection(
  WidgetTester tester, {
  required FeedbackService service,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        feedbackServiceProvider.overrideWith((Ref ref) => service),
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
        home: Scaffold(body: SoundHapticsSection()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late _RecordingHaptics haptics;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    haptics = _RecordingHaptics();
  });

  FeedbackService build() => FeedbackService(
        prefs: prefs,
        playerFactory: _NoopPlayer.new,
        hapticChannel: haptics,
      );

  testWidgets('renders default state: haptics ON, sound OFF', (tester) async {
    final svc = build();
    await _pumpSection(tester, service: svc);

    expect(find.text('Sound & Haptics'), findsOneWidget);
    expect(find.text('Haptic feedback'), findsOneWidget);
    expect(find.text('Sound effects'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);

    final SwitchListTile hapticsTile = tester.widget(
      find.byKey(const Key('settings.feedback.haptics')),
    );
    final SwitchListTile soundTile = tester.widget(
      find.byKey(const Key('settings.feedback.sound')),
    );
    expect(hapticsTile.value, true);
    expect(soundTile.value, false);
  });

  testWidgets('tapping sound toggle persists to prefs', (tester) async {
    final svc = build();
    await _pumpSection(tester, service: svc);

    await tester.tap(find.byKey(const Key('settings.feedback.sound')));
    await tester.pumpAndSettle();

    expect(prefs.getBool(kPrefsKeySound), true);
    expect(svc.settings.soundEnabled, true);
  });

  testWidgets('tapping haptics toggle persists and updates service',
      (tester) async {
    final svc = build();
    await _pumpSection(tester, service: svc);

    await tester.tap(find.byKey(const Key('settings.feedback.haptics')));
    await tester.pumpAndSettle();

    expect(prefs.getBool(kPrefsKeyHaptics), false);
    expect(svc.settings.hapticsEnabled, false);
  });

  testWidgets('preview button fires the achievement cue', (tester) async {
    final svc = build();
    await _pumpSection(tester, service: svc);

    await tester.tap(find.byKey(const Key('settings.feedback.preview')));
    await tester.pump();

    expect(haptics.calls, <PfFeedbackKind>[PfFeedbackKind.achievement]);
  });
}
