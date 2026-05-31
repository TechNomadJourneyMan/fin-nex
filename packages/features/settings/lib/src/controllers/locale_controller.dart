// Persists the user-selected [Locale] across launches.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences_store.dart';

/// Supported BCP-47 locale tags for FinNex.
const Set<String> kSupportedLocaleTags = <String>{'en', 'ru', 'kk'};

/// StateNotifier that owns the active locale (or `null` = follow system).
class LocaleController extends StateNotifier<Locale?> {
  /// Default constructor. Loads the persisted value asynchronously.
  LocaleController(this._store) : super(null) {
    _hydrate();
  }

  final PreferencesStore _store;

  Future<void> _hydrate() async {
    final tag = await _store.getString(PreferenceKeys.locale);
    if (tag != null && kSupportedLocaleTags.contains(tag)) {
      state = Locale(tag);
    }
  }

  /// Sets a new locale and persists it. Passing `null` clears the override
  /// so the platform locale takes over.
  Future<void> set(Locale? locale) async {
    state = locale;
    await _store.setString(
      PreferenceKeys.locale,
      locale?.toLanguageTag(),
    );
  }
}
