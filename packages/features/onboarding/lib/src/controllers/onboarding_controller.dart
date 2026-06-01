// Onboarding controller — tracks step + persists completion flag.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage key for the onboarding completion flag (v1).
const String kOnboardingCompletedKey = 'onboarding_completed_v1';

/// Ordered onboarding steps (matches go_router subroutes).
enum OnboardingStep {
  /// Welcome / value framing.
  welcome,

  /// 4-slide value props pager.
  valueProps,

  /// Create first account + pick currency.
  setupAccount,

  /// Permission asks (notifications, biometric).
  permissions,

  /// Final "try it now" prompt that hands off to transactions.
  firstTransaction,
}

/// Snapshot of onboarding state.
@immutable
class OnboardingState {
  /// Default constructor.
  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.completed = false,
    this.currencyCode = 'KZT',
    this.accountName = '',
    this.notificationsGranted = false,
    this.biometricGranted = false,
  });

  /// Currently active step.
  final OnboardingStep step;

  /// Whether the user has finished (or skipped through) onboarding.
  final bool completed;

  /// Selected default currency ISO code. Defaults to KZT per spec.
  final String currencyCode;

  /// Account name the user typed on the setup screen.
  final String accountName;

  /// Whether notifications permission has been granted (or stubbed on web).
  final bool notificationsGranted;

  /// Whether biometric unlock has been granted (skipped on web).
  final bool biometricGranted;

  /// Returns true when the user is on the final step.
  bool get isLastStep => step == OnboardingStep.firstTransaction;

  /// Copy with override fields.
  OnboardingState copyWith({
    OnboardingStep? step,
    bool? completed,
    String? currencyCode,
    String? accountName,
    bool? notificationsGranted,
    bool? biometricGranted,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      completed: completed ?? this.completed,
      currencyCode: currencyCode ?? this.currencyCode,
      accountName: accountName ?? this.accountName,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      biometricGranted: biometricGranted ?? this.biometricGranted,
    );
  }
}

/// Controls onboarding flow + persists the completion flag.
class OnboardingController extends StateNotifier<OnboardingState> {
  /// Inject a [SharedPreferences] instance (tests may pass a mock).
  OnboardingController(this._prefs) : super(const OnboardingState()) {
    _hydrate();
  }

  final SharedPreferences _prefs;

  void _hydrate() {
    final done = _prefs.getBool(kOnboardingCompletedKey) ?? false;
    if (done) {
      state = state.copyWith(completed: true);
    }
  }

  /// Move to a specific [step].
  void goTo(OnboardingStep step) {
    state = state.copyWith(step: step);
  }

  /// Advance to the next step. On the final step, calls [complete].
  Future<void> next() async {
    final values = OnboardingStep.values;
    final idx = values.indexOf(state.step);
    if (idx < values.length - 1) {
      state = state.copyWith(step: values[idx + 1]);
    } else {
      await complete();
    }
  }

  /// Set the default currency for the first account.
  void setCurrency(String code) {
    state = state.copyWith(currencyCode: code);
  }

  /// Set the typed account name.
  void setAccountName(String name) {
    state = state.copyWith(accountName: name);
  }

  /// Stubbed permission ask for notifications.
  ///
  /// On Web we just toggle the local flag (no real permission prompt to
  /// avoid native plugin dependencies); on other platforms the host app
  /// should wire flutter_local_notifications and call [grantNotifications]
  /// from its actual result.
  // TODO(F-NOTIF): replace web stub with real flutter_local_notifications.
  Future<void> requestNotifications() async {
    state = state.copyWith(notificationsGranted: true);
  }

  /// Manually mark notifications as granted.
  void grantNotifications({bool granted = true}) {
    state = state.copyWith(notificationsGranted: granted);
  }

  /// Stubbed biometric request. Skipped entirely on web.
  // TODO(F-BIOM): replace stub with local_auth integration.
  Future<void> requestBiometric() async {
    if (kIsWeb) {
      state = state.copyWith(biometricGranted: false);
      return;
    }
    state = state.copyWith(biometricGranted: true);
  }

  /// Mark onboarding as complete and persist the flag.
  Future<void> complete() async {
    await _prefs.setBool(kOnboardingCompletedKey, true);
    state =
        state.copyWith(completed: true, step: OnboardingStep.firstTransaction);
  }

  /// Reset for test/debug only.
  @visibleForTesting
  Future<void> resetForTest() async {
    await _prefs.remove(kOnboardingCompletedKey);
    state = const OnboardingState();
  }
}
