// Persists the high-contrast accessibility preference across launches via
// [PreferencesStore] (SharedPreferences key `pf_high_contrast`).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences_store.dart';

/// StateNotifier holding whether the high-contrast theme is enabled.
///
/// Loads the persisted value on construction and writes through on every
/// change. Defaults to `false` (standard brand theme).
class HighContrastController extends StateNotifier<bool> {
  /// Default constructor. Loads the persisted value asynchronously.
  HighContrastController(this._store) : super(false) {
    _hydrate();
  }

  final PreferencesStore _store;

  Future<void> _hydrate() async {
    final bool? raw = await _store.getBool(PreferenceKeys.highContrast);
    if (raw != null && raw != state) {
      state = raw;
    }
  }

  /// Sets and persists whether high-contrast mode is enabled.
  Future<void> set(bool enabled) async {
    state = enabled;
    await _store.setBool(PreferenceKeys.highContrast, enabled);
  }

  /// Flips the current value.
  Future<void> toggle() => set(!state);
}
