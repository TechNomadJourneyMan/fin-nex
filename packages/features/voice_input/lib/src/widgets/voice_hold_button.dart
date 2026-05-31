// Hold-to-record FAB-style button.
//
// On long-press start it checks microphone permission, begins recording, and
// shows a pulsing [VoiceOverlay] via an [OverlayEntry]. On release it stops the
// recording and uploads for transcription; on success it opens the
// [VoiceConfirmSheet]. Permission denial surfaces a graceful dialog.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

import '../controllers/voice_controller.dart';
import '../pages/voice_confirm_sheet.dart';
import '../providers.dart';
import '../services/microphone_permission.dart';
import '../services/voice_transcription_service.dart';
import 'voice_overlay.dart';

/// Circular, Lottie-free FAB the user holds to record a voice transaction.
class VoiceHoldButton extends ConsumerStatefulWidget {
  /// Creates the hold button.
  const VoiceHoldButton({
    super.key,
    required this.onConfirm,
    this.size = 64,
    this.locale,
    this.icon = Icons.mic,
  });

  /// Called when the user confirms a parsed draft in the bottom sheet.
  final ValueChanged<VoiceTranscriptionResult> onConfirm;

  /// Diameter of the button.
  final double size;

  /// BCP-47 locale hint passed to the backend (e.g. `ru-RU`).
  final String? locale;

  /// Icon shown at rest.
  final IconData icon;

  @override
  ConsumerState<VoiceHoldButton> createState() => _VoiceHoldButtonState();
}

class _VoiceHoldButtonState extends ConsumerState<VoiceHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  OverlayEntry? _overlayEntry;
  bool _confirmShown = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.85,
      upperBound: 1.1,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _onLongPressStart() async {
    final perm = ref.read(microphonePermissionProvider);
    final status = await perm.ensure();
    if (!mounted) {
      return;
    }
    if (status != MicPermissionStatus.granted) {
      await _showDenied(status);
      return;
    }
    _confirmShown = false;
    _pulse.repeat(reverse: true);
    _showOverlay();
    await ref.read(voiceControllerProvider.notifier).startRecording();
  }

  Future<void> _onLongPressEnd() async {
    _pulse
      ..stop()
      ..value = 0.85;
    await ref
        .read(voiceControllerProvider.notifier)
        .stopAndTranscribe(locale: widget.locale);
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      return;
    }
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final state = ref.watch(voiceControllerProvider).valueOrNull;
        return VoiceOverlay(
          transcript: state?.partialTranscript ?? '',
          isUploading: state?.isUploading ?? false,
          onCancel: () {
            ref.read(voiceControllerProvider.notifier).cancel();
          },
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _showDenied(MicPermissionStatus status) async {
    final permanent = status == MicPermissionStatus.permanentlyDenied;
    final confirmed = await showFnxDialog(
      context: context,
      title: 'Microphone needed',
      message: permanent
          ? 'Enable microphone access in Settings to record voice '
              'transactions.'
          : 'FinNex needs microphone access to capture your voice '
              'transaction. Please allow it and try again.',
      kind: FnxDialogKind.confirm,
      confirmLabel: permanent ? 'Open Settings' : 'OK',
      cancelLabel: 'Not now',
    );
    if (permanent && confirmed == true) {
      await ref.read(microphonePermissionProvider).openSettings();
    }
  }

  Future<void> _openConfirmSheet(VoiceTranscriptionResult result) async {
    _confirmShown = true;
    _removeOverlay();
    final confirmed = await showVoiceConfirmSheet(
      context: context,
      initial: result,
      onConfirm: widget.onConfirm,
    );
    if (!mounted) {
      return;
    }
    ref.read(voiceControllerProvider.notifier).reset();
    if (confirmed != true) {
      _confirmShown = false;
    }
  }

  void _onStateChange(VoiceState? state) {
    if (state == null) {
      return;
    }
    switch (state.phase) {
      case VoicePhase.idle:
        _removeOverlay();
      case VoicePhase.recording:
      case VoicePhase.uploading:
        _showOverlay();
      case VoicePhase.transcribed:
        if (!_confirmShown && state.result != null) {
          _openConfirmSheet(state.result!);
        }
      case VoicePhase.error:
        _removeOverlay();
        final msg = state.errorMessage ?? 'Something went wrong.';
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
        ref.read(voiceControllerProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<VoiceState>>(voiceControllerProvider, (prev, next) {
      _onStateChange(next.valueOrNull);
    });

    final colors = context.fnxColors;

    return Semantics(
      button: true,
      label: 'Hold to record a voice transaction',
      child: GestureDetector(
        onLongPressStart: (_) => _onLongPressStart(),
        onLongPressEnd: (_) => _onLongPressEnd(),
        onLongPressCancel: () =>
            ref.read(voiceControllerProvider.notifier).cancel(),
        child: ScaleTransition(
          scale: _pulse,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: colors.brand,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.brand.withValues(alpha: 0.35),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: colors.onBrand,
              size: widget.size * 0.42,
            ),
          ),
        ),
      ),
    );
  }
}
