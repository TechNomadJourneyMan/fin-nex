// Widget test: pumping the [VoiceHoldButton] and long-pressing it surfaces the
// recording overlay. Uses fakes for the recorder, permission, and
// transcription service so no platform channels are involved.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_feat_voice_input/fnx_feat_voice_input.dart';

class _FakeRecorder implements VoiceRecorder {
  bool started = false;

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  Future<Uint8List?> stop() async => Uint8List.fromList(<int>[1, 2, 3]);
}

class _FakePermission implements MicrophonePermission {
  @override
  Future<MicPermissionStatus> ensure() async => MicPermissionStatus.granted;

  @override
  Future<bool> openSettings() async => true;
}

class _FakeTranscription implements VoiceTranscriptionService {
  @override
  Future<VoiceTranscriptionResult> transcribe(
    Uint8List bytes, {
    String mimeType = 'audio/m4a',
    String? locale,
  }) async {
    return const VoiceTranscriptionResult(transcript: 'spent 1500 on coffee');
  }
}

void main() {
  testWidgets('long-press shows the recording overlay', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          voiceRecorderProvider.overrideWithValue(_FakeRecorder()),
          microphonePermissionProvider.overrideWithValue(_FakePermission()),
          voiceTranscriptionServiceProvider
              .overrideWithValue(_FakeTranscription()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceHoldButton(onConfirm: (_) {}),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(VoiceOverlay), findsNothing);

    // Begin (but do not release) the long-press to enter recording.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(VoiceHoldButton)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await tester.pump();

    expect(find.byType(VoiceOverlay), findsOneWidget);
    expect(find.text('Listening…'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Release to avoid leaking the pointer.
    await gesture.up();
    await tester.pumpAndSettle();
  });
}
