// AsyncNotifier driving the voice-capture state machine.
//
// States: idle -> recording -> uploading -> transcribed(result) | error(msg).
// Cancelling at any point returns to idle.

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../services/voice_recorder.dart';
import '../services/voice_transcription_service.dart';

/// Discriminated phase of the voice capture flow.
enum VoicePhase {
  /// Nothing happening; ready to record.
  idle,

  /// Microphone is live and capturing.
  recording,

  /// Captured bytes are being sent for transcription.
  uploading,

  /// A parsed transaction draft is available.
  transcribed,

  /// Something went wrong; [VoiceState.errorMessage] explains.
  error,
}

/// Immutable state for the voice controller.
class VoiceState {
  /// Creates a voice state.
  const VoiceState({
    required this.phase,
    this.partialTranscript = '',
    this.result,
    this.errorMessage,
  });

  /// The idle starting state.
  const VoiceState.idle()
      : phase = VoicePhase.idle,
        partialTranscript = '',
        result = null,
        errorMessage = null;

  /// Current phase.
  final VoicePhase phase;

  /// Live (possibly partial) transcript shown in the overlay.
  final String partialTranscript;

  /// Parsed result, present only in [VoicePhase.transcribed].
  final VoiceTranscriptionResult? result;

  /// Error text, present only in [VoicePhase.error].
  final String? errorMessage;

  /// Convenience flags.
  bool get isRecording => phase == VoicePhase.recording;

  /// True while uploading.
  bool get isUploading => phase == VoicePhase.uploading;

  /// True when an overlay should be visible (recording or uploading).
  bool get isActive =>
      phase == VoicePhase.recording || phase == VoicePhase.uploading;

  /// Returns a copy with overrides.
  VoiceState copyWith({
    VoicePhase? phase,
    String? partialTranscript,
    VoiceTranscriptionResult? result,
    String? errorMessage,
  }) {
    return VoiceState(
      phase: phase ?? this.phase,
      partialTranscript: partialTranscript ?? this.partialTranscript,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// AsyncNotifier orchestrating record -> upload -> transcribe.
class VoiceController extends AsyncNotifier<VoiceState> {
  late VoiceRecorder _recorder;
  late VoiceTranscriptionService _service;
  bool _cancelled = false;

  @override
  Future<VoiceState> build() async {
    _recorder = ref.watch(voiceRecorderProvider);
    _service = ref.watch(voiceTranscriptionServiceProvider);
    ref.onDispose(() => _recorder.dispose());
    return const VoiceState.idle();
  }

  /// Begins capturing audio. No-ops if already recording.
  Future<void> startRecording() async {
    final current = state.valueOrNull;
    if (current != null && current.isActive) {
      return;
    }
    _cancelled = false;
    try {
      await _recorder.start();
      state = const AsyncData<VoiceState>(
        VoiceState(phase: VoicePhase.recording),
      );
    } on Object catch (e) {
      state = AsyncData<VoiceState>(
        VoiceState(
          phase: VoicePhase.error,
          errorMessage: 'Could not start recording: $e',
        ),
      );
    }
  }

  /// Stops capture and uploads the bytes for transcription.
  Future<void> stopAndTranscribe({String? locale}) async {
    final current = state.valueOrNull;
    if (current == null || current.phase != VoicePhase.recording) {
      return;
    }
    Uint8List? bytes;
    try {
      bytes = await _recorder.stop();
    } on Object catch (e) {
      state = AsyncData<VoiceState>(
        VoiceState(
          phase: VoicePhase.error,
          errorMessage: 'Recording failed: $e',
        ),
      );
      return;
    }
    if (_cancelled) {
      state = const AsyncData<VoiceState>(VoiceState.idle());
      return;
    }
    if (bytes == null || bytes.isEmpty) {
      state = const AsyncData<VoiceState>(
        VoiceState(
          phase: VoicePhase.error,
          errorMessage: 'Nothing was recorded. Hold the button and speak.',
        ),
      );
      return;
    }

    state =
        const AsyncData<VoiceState>(VoiceState(phase: VoicePhase.uploading));
    try {
      final result = await _service.transcribe(bytes, locale: locale);
      if (_cancelled) {
        state = const AsyncData<VoiceState>(VoiceState.idle());
        return;
      }
      state = AsyncData<VoiceState>(
        VoiceState(
          phase: VoicePhase.transcribed,
          partialTranscript: result.transcript,
          result: result,
        ),
      );
    } on VoiceTranscriptionException catch (e) {
      state = AsyncData<VoiceState>(
        VoiceState(phase: VoicePhase.error, errorMessage: e.message),
      );
    } on Object catch (e) {
      state = AsyncData<VoiceState>(
        VoiceState(
          phase: VoicePhase.error,
          errorMessage: 'Transcription failed: $e',
        ),
      );
    }
  }

  /// Cancels any in-flight capture and returns to idle.
  Future<void> cancel() async {
    _cancelled = true;
    final current = state.valueOrNull;
    if (current != null && current.phase == VoicePhase.recording) {
      try {
        await _recorder.stop();
      } on Object catch (_) {
        // Ignore stop errors while cancelling.
      }
    }
    state = const AsyncData<VoiceState>(VoiceState.idle());
  }

  /// Resets to idle (e.g. after the confirm sheet is dismissed).
  void reset() {
    _cancelled = false;
    state = const AsyncData<VoiceState>(VoiceState.idle());
  }
}

/// Provider exposing the [VoiceController].
final voiceControllerProvider =
    AsyncNotifierProvider<VoiceController, VoiceState>(VoiceController.new);
