// "Sound & Haptics" settings section.
//
// Two SwitchListTiles + a Preview button that fires the achievement cue, so
// users can A/B both haptic and sound channels.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

/// Settings section exposing the [FeedbackService] toggles + a preview.
///
/// Reads/writes the persisted settings via [feedbackSettingsProvider] +
/// [feedbackServiceProvider].
class SoundHapticsSection extends ConsumerWidget {
  /// Const ctor.
  const SoundHapticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final AsyncValue<FeedbackSettings> async =
        ref.watch(feedbackSettingsProvider);
    final FeedbackSettings settings = async.maybeWhen(
      data: (s) => s,
      orElse: () => const FeedbackSettings(),
    );
    final FeedbackService svc = ref.read(feedbackServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.settings_section_feedback,
            style: typo.bodySm.copyWith(
              color: colors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        SwitchListTile(
          key: const Key('settings.feedback.haptics'),
          title: Text(l10n.feedback_haptics),
          value: settings.hapticsEnabled,
          onChanged: (bool v) {
            // ignore: discarded_futures
            svc.setHapticsEnabled(v);
          },
        ),
        SwitchListTile(
          key: const Key('settings.feedback.sound'),
          title: Text(l10n.feedback_sound),
          value: settings.soundEnabled,
          onChanged: (bool v) {
            // ignore: discarded_futures
            svc.setSoundEnabled(v);
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('settings.feedback.preview'),
              onPressed: svc.achievement,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.feedback_preview),
            ),
          ),
        ),
        Divider(
          height: 1,
          color: colors.divider,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
