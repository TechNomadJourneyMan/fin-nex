// pf_core_feedback — haptic + sound cue service.
//
// Public surface:
//   - FeedbackService (with selectTap / confirmAction / warn / error /
//     achievement / navigate / longPress methods)
//   - FeedbackSettings (immutable settings snapshot)
//   - PfFeedbackKind (enum of cue kinds, useful for tests)
//   - feedbackServiceProvider (Riverpod singleton, override at bootstrap)
//   - feedbackSettingsProvider (StreamProvider mirroring current settings)
//   - kPrefsKeySound / kPrefsKeyHaptics (SharedPreferences keys)
//   - PfAudioPlayer / PfAudioPlayerFactory (test injection seam)
//   - PfHapticChannel (test injection seam for platform haptics)

library pf_core_feedback;

export 'src/audio_player_factory.dart';
export 'src/feedback_service.dart';
export 'src/feedback_settings.dart';
