// Central feedback service. Calls HapticFeedback + plays short cue sounds.
//
// All public methods are fire-and-forget: callers do not await. On Flutter
// web the HapticFeedback channel is a no-op (Flutter swallows the
// MissingPluginException). just_audio also degrades gracefully on web.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_player_factory.dart';
import 'feedback_settings.dart';

/// Logical feedback "kind" enum — maps to one (haptic, sound) tuple.
enum PfFeedbackKind {
  /// Light selection click + tap.wav.
  selectTap,

  /// Medium impact + success.wav. For successful save / confirm flows.
  confirmAction,

  /// Heavy impact, no sound. Used for "you're about to break a limit".
  warn,

  /// Vibrate + error.wav. Used for validation / save failures.
  error,

  /// Heavy impact + achievement.wav. Used for milestones / rewards.
  achievement,

  /// Light selection click, no sound. Used for tab / route changes.
  navigate,

  /// Medium impact + tap.wav. Used for long-press grabs.
  longPress,
}

/// Asset paths for each sound cue, relative to this package's assets/sounds
/// directory. `null` means the cue is haptic-only.
const Map<PfFeedbackKind, String?> _kSoundAssets = <PfFeedbackKind, String?>{
  PfFeedbackKind.selectTap: 'assets/sounds/tap.wav',
  PfFeedbackKind.confirmAction: 'assets/sounds/success.wav',
  PfFeedbackKind.warn: null,
  PfFeedbackKind.error: 'assets/sounds/error.wav',
  PfFeedbackKind.achievement: 'assets/sounds/achievement.wav',
  PfFeedbackKind.navigate: null,
  PfFeedbackKind.longPress: 'assets/sounds/tap.wav',
};

/// SharedPreferences key for "sound enabled".
const String kPrefsKeySound = 'pf_feedback_sound';

/// SharedPreferences key for "haptics enabled".
const String kPrefsKeyHaptics = 'pf_feedback_haptics';

/// Central haptic + audio feedback service.
///
/// Construct once and share via [feedbackServiceProvider]. The service holds
/// a small pool of [PfAudioPlayer] instances (one per distinct sound asset)
/// so tap-spam doesn't allocate a new player every call.
class FeedbackService {
  /// Creates a service.
  ///
  /// - [prefs]: SharedPreferences used to persist the on/off toggles.
  /// - [playerFactory]: how to construct an [PfAudioPlayer] for each cue.
  ///   Override in tests.
  /// - [hapticChannel]: indirection over `HapticFeedback.*` calls so tests
  ///   can observe them. Defaults to the real platform channel.
  FeedbackService({
    required SharedPreferences prefs,
    PfAudioPlayerFactory playerFactory = defaultAudioPlayerFactory,
    PfHapticChannel hapticChannel = const _PlatformHapticChannel(),
  })  : _prefs = prefs,
        _playerFactory = playerFactory,
        _haptics = hapticChannel,
        _settings = FeedbackSettings(
          soundEnabled: prefs.getBool(kPrefsKeySound) ?? false,
          hapticsEnabled: prefs.getBool(kPrefsKeyHaptics) ?? true,
        );

  final SharedPreferences _prefs;
  final PfAudioPlayerFactory _playerFactory;
  final PfHapticChannel _haptics;
  final Map<String, PfAudioPlayer> _players = <String, PfAudioPlayer>{};
  FeedbackSettings _settings;
  final StreamController<FeedbackSettings> _settingsCtrl =
      StreamController<FeedbackSettings>.broadcast();

  /// Current settings snapshot.
  FeedbackSettings get settings => _settings;

  /// Stream of settings changes. Always emits the latest value on subscribe.
  Stream<FeedbackSettings> get settingsStream => _settingsCtrl.stream;

  /// Toggle haptics on/off and persist.
  Future<void> setHapticsEnabled(bool enabled) async {
    _settings = _settings.copyWith(hapticsEnabled: enabled);
    await _prefs.setBool(kPrefsKeyHaptics, enabled);
    _settingsCtrl.add(_settings);
  }

  /// Toggle sound on/off and persist.
  Future<void> setSoundEnabled(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
    await _prefs.setBool(kPrefsKeySound, enabled);
    _settingsCtrl.add(_settings);
  }

  // ---------------------------------------------------------------------
  // Semantic API. All fire-and-forget — callers never await.
  // ---------------------------------------------------------------------

  /// Light selection click + short tap sound. Use on list-item taps and
  /// chip toggles.
  void selectTap() => _fire(PfFeedbackKind.selectTap);

  /// Medium impact + success sound. Use on save / confirm flows.
  void confirmAction() => _fire(PfFeedbackKind.confirmAction);

  /// Heavy impact (no sound). Use when crossing a budget limit.
  void warn() => _fire(PfFeedbackKind.warn);

  /// System vibrate + error sound. Use on validation / save failure.
  void error() => _fire(PfFeedbackKind.error);

  /// Heavy impact + ascending arpeggio. Use for achievements / streaks.
  void achievement() => _fire(PfFeedbackKind.achievement);

  /// Light selection click (no sound). Use on tab / route changes.
  void navigate() => _fire(PfFeedbackKind.navigate);

  /// Medium impact + tap sound. Use when a long-press grab begins.
  void longPress() => _fire(PfFeedbackKind.longPress);

  /// Dispatch a [PfFeedbackKind]. Public so tests can fire by name.
  void play(PfFeedbackKind kind) => _fire(kind);

  /// Release every cached [PfAudioPlayer]. Safe to call multiple times.
  Future<void> dispose() async {
    final List<PfAudioPlayer> snapshot = _players.values.toList(growable: false);
    _players.clear();
    await _settingsCtrl.close();
    for (final PfAudioPlayer p in snapshot) {
      // Swallow errors — dispose is best-effort.
      try {
        await p.dispose();
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------
  // Internals.
  // ---------------------------------------------------------------------

  void _fire(PfFeedbackKind kind) {
    if (_settings.hapticsEnabled) {
      _haptics.trigger(kind);
    }
    if (!_settings.soundEnabled) return;
    final String? asset = _kSoundAssets[kind];
    if (asset == null) return;
    // Fire-and-forget — explicitly discard the future.
    unawaited(_playAsset(asset));
  }

  Future<void> _playAsset(String asset) async {
    try {
      final PfAudioPlayer player =
          _players.putIfAbsent(asset, _playerFactory);
      await player.setAsset(asset, package: 'pf_core_feedback');
      await player.replay();
    } catch (_) {
      // Best-effort: swallow audio errors so a missing asset or platform
      // quirk never breaks the calling UI flow.
    }
  }
}

/// Abstraction over the platform haptic channel so tests can verify calls.
abstract class PfHapticChannel {
  /// Default const ctor for subclasses.
  const PfHapticChannel();

  /// Fire the haptic associated with [kind].
  void trigger(PfFeedbackKind kind);
}

class _PlatformHapticChannel extends PfHapticChannel {
  const _PlatformHapticChannel();

  @override
  void trigger(PfFeedbackKind kind) {
    // The platform calls below return Futures; we intentionally discard them
    // because feedback must never block the calling code path.
    try {
      switch (kind) {
        case PfFeedbackKind.selectTap:
        case PfFeedbackKind.navigate:
          // ignore: discarded_futures
          HapticFeedback.selectionClick();
        case PfFeedbackKind.confirmAction:
        case PfFeedbackKind.longPress:
          // ignore: discarded_futures
          HapticFeedback.mediumImpact();
        case PfFeedbackKind.warn:
        case PfFeedbackKind.achievement:
          // ignore: discarded_futures
          HapticFeedback.heavyImpact();
        case PfFeedbackKind.error:
          // ignore: discarded_futures
          HapticFeedback.vibrate();
      }
    } catch (_) {
      // Haptic channel missing (web, headless tests) — silently no-op.
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod wiring
// ---------------------------------------------------------------------------

/// Provider for the singleton [FeedbackService]. The app overrides this at
/// bootstrap once SharedPreferences is ready.
final Provider<FeedbackService> feedbackServiceProvider =
    Provider<FeedbackService>((Ref ref) {
  throw StateError(
    'feedbackServiceProvider must be overridden at app bootstrap.',
  );
});

/// StreamProvider mirroring the current [FeedbackSettings].
///
/// Watch this from the settings UI to keep switches in sync with the
/// persisted state without rebuilding the entire service.
final StreamProvider<FeedbackSettings> feedbackSettingsProvider =
    StreamProvider<FeedbackSettings>((Ref ref) async* {
  final FeedbackService svc = ref.watch(feedbackServiceProvider);
  yield svc.settings;
  yield* svc.settingsStream;
});
