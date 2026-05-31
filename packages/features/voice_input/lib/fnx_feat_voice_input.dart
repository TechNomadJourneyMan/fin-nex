// Public API for the FinNex voice-input feature module (PRD F-05, client side).
//
// Exposes the hold-to-record button, the recording overlay, the confirm sheet,
// the Riverpod controller + providers, and the transcription service
// abstraction.

library fnx_feat_voice_input;

export 'src/controllers/voice_controller.dart';
export 'src/pages/voice_confirm_sheet.dart';
export 'src/providers.dart';
export 'src/services/microphone_permission.dart';
export 'src/services/voice_recorder.dart';
export 'src/services/voice_transcription_service.dart';
export 'src/widgets/voice_hold_button.dart';
export 'src/widgets/voice_overlay.dart';
