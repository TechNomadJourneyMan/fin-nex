// Thin wrapper around just_audio's [AudioPlayer] so tests can swap in a fake
// without pulling in the platform channel.

import 'package:just_audio/just_audio.dart';

/// Minimal player surface used by [FeedbackService]. Implemented by
/// [JustAudioPlayerAdapter] in production and by fakes in tests.
abstract class PfAudioPlayer {
  /// Set the asset to play. Returns once the source is loaded (or fails
  /// silently in production).
  Future<void> setAsset(String assetPath, {String? package});

  /// Seek back to the start, then call [play].
  Future<void> replay();

  /// Release native resources.
  Future<void> dispose();
}

/// Production [PfAudioPlayer] backed by `package:just_audio`.
class JustAudioPlayerAdapter implements PfAudioPlayer {
  /// Wrap a freshly constructed [AudioPlayer].
  JustAudioPlayerAdapter() : _player = AudioPlayer();

  final AudioPlayer _player;
  String? _loadedAsset;

  @override
  Future<void> setAsset(String assetPath, {String? package}) async {
    final String key = package != null ? '$package:$assetPath' : assetPath;
    if (_loadedAsset == key) return;
    await _player.setAsset(assetPath, package: package);
    _loadedAsset = key;
  }

  @override
  Future<void> replay() async {
    await _player.seek(Duration.zero);
    // ignore: discarded_futures
    _player.play();
  }

  @override
  Future<void> dispose() => _player.dispose();
}

/// Factory signature so tests can inject a fake player per sound.
typedef PfAudioPlayerFactory = PfAudioPlayer Function();

/// Default factory — used when the app does not override
/// [FeedbackService.playerFactory].
PfAudioPlayer defaultAudioPlayerFactory() => JustAudioPlayerAdapter();
