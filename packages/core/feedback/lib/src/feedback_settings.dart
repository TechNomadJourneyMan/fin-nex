// Settings record for [FeedbackService]: which feedback channels are
// currently enabled. Persisted via SharedPreferences (see [FeedbackService]).

/// Immutable settings snapshot for the feedback channels.
///
/// Defaults: haptics ON, sound OFF. Sound is opt-in because procedurally
/// generated tones can be jarring on shared devices and laptops, while
/// haptics are subtle and platform-respecting.
class FeedbackSettings {
  /// Creates a settings snapshot.
  const FeedbackSettings({
    this.soundEnabled = false,
    this.hapticsEnabled = true,
  });

  /// Whether sound effects should be played alongside haptics.
  final bool soundEnabled;

  /// Whether HapticFeedback calls should fire.
  final bool hapticsEnabled;

  /// Returns a copy with the listed fields replaced.
  FeedbackSettings copyWith({bool? soundEnabled, bool? hapticsEnabled}) =>
      FeedbackSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackSettings &&
          other.soundEnabled == soundEnabled &&
          other.hapticsEnabled == hapticsEnabled;

  @override
  int get hashCode => Object.hash(soundEnabled, hapticsEnabled);

  @override
  String toString() =>
      'FeedbackSettings(sound: $soundEnabled, haptics: $hapticsEnabled)';
}
