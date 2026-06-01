import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePlayer implements PfAudioPlayer {
  String? loaded;
  int playCount = 0;
  bool disposed = false;

  @override
  Future<void> setAsset(String assetPath, {String? package}) async {
    loaded = package != null ? '$package:$assetPath' : assetPath;
  }

  @override
  Future<void> replay() async {
    playCount++;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class _RecordingHapticChannel extends PfHapticChannel {
  _RecordingHapticChannel();
  final List<PfFeedbackKind> calls = <PfFeedbackKind>[];

  @override
  void trigger(PfFeedbackKind kind) => calls.add(kind);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late _RecordingHapticChannel haptics;
  late List<_FakePlayer> spawned;

  PfAudioPlayer factory() {
    final _FakePlayer p = _FakePlayer();
    spawned.add(p);
    return p;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    haptics = _RecordingHapticChannel();
    spawned = <_FakePlayer>[];
  });

  FeedbackService build() => FeedbackService(
        prefs: prefs,
        playerFactory: factory,
        hapticChannel: haptics,
      );

  test('defaults: haptics ON, sound OFF', () {
    final svc = build();
    expect(svc.settings.hapticsEnabled, true);
    expect(svc.settings.soundEnabled, false);
  });

  test('hydrates settings from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      kPrefsKeySound: true,
      kPrefsKeyHaptics: false,
    });
    prefs = await SharedPreferences.getInstance();
    final svc = build();
    expect(svc.settings.soundEnabled, true);
    expect(svc.settings.hapticsEnabled, false);
  });

  test('selectTap fires light haptic when enabled, no sound when sound off',
      () async {
    final svc = build();
    svc.selectTap();
    expect(haptics.calls, <PfFeedbackKind>[PfFeedbackKind.selectTap]);
    // Sound is off by default — no players were ever asked for.
    expect(spawned, isEmpty);
  });

  test('confirmAction plays success.wav when sound enabled', () async {
    final svc = build();
    await svc.setSoundEnabled(true);
    svc.confirmAction();
    // Give the unawaited _playAsset future a chance to run.
    await Future<void>.delayed(Duration.zero);
    expect(haptics.calls, <PfFeedbackKind>[PfFeedbackKind.confirmAction]);
    expect(spawned, hasLength(1));
    expect(
      spawned.first.loaded,
      'pf_core_feedback:assets/sounds/success.wav',
    );
    expect(spawned.first.playCount, 1);
  });

  test('warn does NOT play sound (haptic-only cue)', () async {
    final svc = build();
    await svc.setSoundEnabled(true);
    svc.warn();
    await Future<void>.delayed(Duration.zero);
    expect(haptics.calls, <PfFeedbackKind>[PfFeedbackKind.warn]);
    expect(spawned, isEmpty);
  });

  test('navigate does NOT play sound', () async {
    final svc = build();
    await svc.setSoundEnabled(true);
    svc.navigate();
    await Future<void>.delayed(Duration.zero);
    expect(haptics.calls, <PfFeedbackKind>[PfFeedbackKind.navigate]);
    expect(spawned, isEmpty);
  });

  test('error plays error.wav and uses HapticFeedback.vibrate channel mapping',
      () async {
    final svc = build();
    await svc.setSoundEnabled(true);
    svc.error();
    await Future<void>.delayed(Duration.zero);
    expect(haptics.calls, <PfFeedbackKind>[PfFeedbackKind.error]);
    expect(spawned.single.loaded, 'pf_core_feedback:assets/sounds/error.wav');
  });

  test('longPress plays tap.wav and uses medium impact', () async {
    final svc = build();
    await svc.setSoundEnabled(true);
    svc.longPress();
    await Future<void>.delayed(Duration.zero);
    expect(haptics.calls, <PfFeedbackKind>[PfFeedbackKind.longPress]);
    expect(spawned.single.loaded, 'pf_core_feedback:assets/sounds/tap.wav');
  });

  test('when haptics disabled the haptic channel is not called', () async {
    final svc = build();
    await svc.setHapticsEnabled(false);
    svc.selectTap();
    svc.confirmAction();
    expect(haptics.calls, isEmpty);
  });

  test('player is reused across repeated calls for the same asset', () async {
    final svc = build();
    await svc.setSoundEnabled(true);
    svc.selectTap();
    svc.selectTap();
    svc.selectTap();
    await Future<void>.delayed(Duration.zero);
    expect(spawned, hasLength(1));
    expect(spawned.single.playCount, 3);
  });

  test('different assets allocate distinct players', () async {
    final svc = build();
    await svc.setSoundEnabled(true);
    svc.selectTap(); // tap.wav
    svc.confirmAction(); // success.wav
    svc.error(); // error.wav
    svc.achievement(); // achievement.wav
    await Future<void>.delayed(Duration.zero);
    expect(spawned, hasLength(4));
  });

  test('setSoundEnabled / setHapticsEnabled persist to prefs and broadcast',
      () async {
    final svc = build();
    final List<FeedbackSettings> emissions = <FeedbackSettings>[];
    final sub = svc.settingsStream.listen(emissions.add);

    await svc.setSoundEnabled(true);
    await svc.setHapticsEnabled(false);
    // Allow the broadcast stream to deliver to listeners.
    await Future<void>.delayed(Duration.zero);

    expect(prefs.getBool(kPrefsKeySound), true);
    expect(prefs.getBool(kPrefsKeyHaptics), false);
    expect(emissions.length, 2);
    expect(emissions.last.soundEnabled, true);
    expect(emissions.last.hapticsEnabled, false);
    await sub.cancel();
  });

  test('dispose tears down all cached players', () async {
    final svc = build();
    await svc.setSoundEnabled(true);
    svc.selectTap();
    svc.confirmAction();
    await Future<void>.delayed(Duration.zero);
    await svc.dispose();
    expect(spawned.every((p) => p.disposed), true);
  });

  test('FeedbackSettings equality + copyWith', () {
    const a = FeedbackSettings();
    expect(a.soundEnabled, false);
    expect(a.hapticsEnabled, true);
    expect(
      a.copyWith(soundEnabled: true),
      const FeedbackSettings(soundEnabled: true),
    );
    expect(a, const FeedbackSettings());
    expect(a.hashCode, const FeedbackSettings().hashCode);
  });
}
