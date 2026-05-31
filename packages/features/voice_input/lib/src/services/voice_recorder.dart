// Thin abstraction over the `record` plugin.
//
// Wrapping it behind [VoiceRecorder] keeps the controller and widgets free of
// a hard dependency on platform channels, which lets widget tests inject a
// fake recorder that returns canned bytes synchronously.

import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';

/// Captures microphone audio and returns the encoded bytes on stop.
abstract class VoiceRecorder {
  /// True if the OS reports microphone permission as granted.
  Future<bool> hasPermission();

  /// Begins recording into a temporary buffer.
  Future<void> start();

  /// Stops recording and returns the encoded bytes, or `null` if nothing was
  /// captured.
  Future<Uint8List?> stop();

  /// Releases native resources.
  Future<void> dispose();
}

/// Default [VoiceRecorder] backed by `package:record`.
class RecordVoiceRecorder implements VoiceRecorder {
  /// Creates the recorder, optionally injecting an [AudioRecorder] (for tests).
  RecordVoiceRecorder({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _path;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> start() async {
    // `record` requires a path on most platforms; callers on web get a blob.
    _path = 'fnx_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _path!,
    );
  }

  @override
  Future<Uint8List?> stop() async {
    final result = await _recorder.stop();
    if (result == null) {
      return null;
    }
    // On native platforms `record` writes a file at [result]; read it back so
    // callers receive the encoded bytes ready to upload. On web `result` is a
    // blob URL the host must fetch, so we return null and let the host resolve
    // it (the controller treats null as "nothing captured").
    if (kIsWeb) {
      return null;
    }
    final file = File(result);
    if (!file.existsSync()) {
      return null;
    }
    return file.readAsBytes();
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}
