// Riverpod providers for the onboarding feature.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/onboarding_controller.dart';

/// Provides the [SharedPreferences] instance.
///
/// Override at app bootstrap with:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// runApp(ProviderScope(overrides: [
///   sharedPreferencesProvider.overrideWithValue(prefs),
/// ], child: const App()));
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden at app bootstrap.',
  );
});

/// Provides the [OnboardingController].
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingController(prefs);
});

/// Convenience: emits `true` once onboarding is complete.
final onboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(onboardingControllerProvider.select((s) => s.completed));
});
