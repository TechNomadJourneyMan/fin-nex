// Persists [ThemeMode] across launches via [PreferencesStore].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences_store.dart';

/// StateNotifier that loads the theme on construction and persists every
/// change.
class ThemeController extends StateNotifier<ThemeMode> {
  /// Default constructor. Loads the persisted value asynchronously.
  ThemeController(this._store) : super(ThemeMode.system) {
    _hydrate();
  }

  final PreferencesStore _store;

  Future<void> _hydrate() async {
    final raw = await _store.getString(PreferenceKeys.theme);
    final next = _decode(raw);
    if (next != state) {
      state = next;
    }
  }

  /// Sets a new [ThemeMode] and persists it.
  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _store.setString(PreferenceKeys.theme, _encode(mode));
  }

  /// Cycles through `system → light → dark → system`. Useful for quick
  /// toggles from a single button.
  Future<void> toggle() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await set(next);
  }

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
      };

  static ThemeMode _decode(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
