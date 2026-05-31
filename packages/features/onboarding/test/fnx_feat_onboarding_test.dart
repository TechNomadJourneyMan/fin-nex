import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_feat_onboarding/onboarding.dart';

void main() {
  test('fnx_feat_onboarding barrel exports expected symbols', () {
    expect(OnboardingStep.values.length, 5);
    expect(kOnboardingCompletedKey, 'onboarding_completed_v1');
    expect(kOnboardingPath, '/onboarding');
  });
}
