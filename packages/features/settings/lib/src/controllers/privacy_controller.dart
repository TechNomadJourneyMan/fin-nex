// Privacy & security preferences. Biometric / screenshot toggles are
// hidden on Flutter Web by the UI layer — this controller still owns the
// flags so non-web platforms can persist them.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences_store.dart';

/// Immutable bag of privacy / security toggles.
class PrivacyPrefs {
  /// Default constructor.
  const PrivacyPrefs({
    required this.biometricLock,
    required this.hideBalances,
  });

  /// Require biometric auth on app open / resume from background.
  final bool biometricLock;

  /// Mask balances on the dashboard until the user authenticates.
  final bool hideBalances;

  /// Conservative defaults — off for both.
  static const PrivacyPrefs defaults = PrivacyPrefs(
    biometricLock: false,
    hideBalances: false,
  );

  /// Returns a copy with the given fields replaced.
  PrivacyPrefs copyWith({
    bool? biometricLock,
    bool? hideBalances,
  }) =>
      PrivacyPrefs(
        biometricLock: biometricLock ?? this.biometricLock,
        hideBalances: hideBalances ?? this.hideBalances,
      );
}

/// StateNotifier owning [PrivacyPrefs] and persisting individual flags.
class PrivacyController extends StateNotifier<PrivacyPrefs> {
  /// Default constructor. Hydrates from [PreferencesStore].
  PrivacyController(this._store) : super(PrivacyPrefs.defaults) {
    _hydrate();
  }

  final PreferencesStore _store;

  Future<void> _hydrate() async {
    final bio = await _store.getBool(PreferenceKeys.biometric);
    final hide = await _store.getBool(PreferenceKeys.hideBalances);
    state = state.copyWith(
      biometricLock: bio ?? state.biometricLock,
      hideBalances: hide ?? state.hideBalances,
    );
  }

  /// Toggle biometric lock.
  Future<void> setBiometric(bool value) async {
    state = state.copyWith(biometricLock: value);
    await _store.setBool(PreferenceKeys.biometric, value);
  }

  /// Toggle hide-balances-until-auth.
  Future<void> setHideBalances(bool value) async {
    state = state.copyWith(hideBalances: value);
    await _store.setBool(PreferenceKeys.hideBalances, value);
  }
}
