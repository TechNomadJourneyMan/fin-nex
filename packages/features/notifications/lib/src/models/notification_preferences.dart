import 'notification_type.dart';

/// Immutable per-type opt-in map for notification delivery.
class NotificationPreferences {
  /// Default constructor.
  const NotificationPreferences(this._values);

  /// All types enabled by default.
  factory NotificationPreferences.defaults() => NotificationPreferences(
        <NotificationPreferenceType, bool>{
          for (final t in NotificationPreferenceType.values) t: true,
        },
      );

  /// Hydrates from a flat JSON map.
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final out = <NotificationPreferenceType, bool>{};
    for (final t in NotificationPreferenceType.values) {
      final v = json[t.key];
      out[t] = v is bool ? v : true;
    }
    return NotificationPreferences(out);
  }

  final Map<NotificationPreferenceType, bool> _values;

  /// Whether [type] is currently enabled. Defaults to `true`.
  bool isEnabled(NotificationPreferenceType type) => _values[type] ?? true;

  /// Returns a copy with [type] flipped to [value].
  NotificationPreferences setEnabled(
    NotificationPreferenceType type,
    bool value,
  ) {
    final next = Map<NotificationPreferenceType, bool>.from(_values);
    next[type] = value;
    return NotificationPreferences(next);
  }

  /// Serializes to a flat JSON map (string keys).
  Map<String, dynamic> toJson() => <String, dynamic>{
        for (final entry in _values.entries) entry.key.key: entry.value,
      };

  @override
  bool operator ==(Object other) {
    if (other is! NotificationPreferences) {
      return false;
    }
    for (final t in NotificationPreferenceType.values) {
      if (isEnabled(t) != other.isEnabled(t)) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(
        NotificationPreferenceType.values.map(isEnabled),
      );
}
