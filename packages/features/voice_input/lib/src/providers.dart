// Riverpod providers for the voice-input feature.
//
// The app composition layer overrides [voiceDioProvider] with the configured
// authenticated Dio instance. Defaults here keep the feature self-contained so
// it renders and runs in isolation (and in widget tests via fakes).

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/microphone_permission.dart';
import 'services/voice_recorder.dart';
import 'services/voice_transcription_service.dart';

/// The Dio used to reach the backend. Overridden in app composition with the
/// shared authenticated client; the default targets a local backend.
final voiceDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
});

/// The active transcription service. Defaults to the Dio implementation; tests
/// and the host app may override with a fake.
final voiceTranscriptionServiceProvider =
    Provider<VoiceTranscriptionService>((ref) {
  return DioVoiceTranscriptionService(ref.watch(voiceDioProvider));
});

/// The active microphone recorder.
final voiceRecorderProvider = Provider<VoiceRecorder>((ref) {
  return RecordVoiceRecorder();
});

/// The active microphone permission gateway.
final microphonePermissionProvider = Provider<MicrophonePermission>((ref) {
  return const PermissionHandlerMicrophonePermission();
});
