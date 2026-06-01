import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('starts on welcome step, not completed', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = OnboardingController(prefs);
    expect(c.state.step, OnboardingStep.welcome);
    expect(c.state.completed, isFalse);
    expect(c.state.currencyCode, 'KZT');
  });

  test('next advances through all steps then completes + persists flag',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final c = OnboardingController(prefs);
    await c.next(); // -> valueProps
    expect(c.state.step, OnboardingStep.valueProps);
    await c.next(); // -> setupAccount
    await c.next(); // -> permissions
    await c.next(); // -> firstTransaction
    expect(c.state.step, OnboardingStep.firstTransaction);
    expect(c.state.completed, isFalse);
    await c.next(); // -> complete()
    expect(c.state.completed, isTrue);
    expect(prefs.getBool(kOnboardingCompletedKey), isTrue);
  });

  test('complete persists onboarding_completed_v1 flag', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = OnboardingController(prefs);
    await c.complete();
    expect(prefs.getBool(kOnboardingCompletedKey), isTrue);
    expect(c.state.completed, isTrue);
  });

  test('controller hydrates completion flag from prefs', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      kOnboardingCompletedKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final c = OnboardingController(prefs);
    expect(c.state.completed, isTrue);
  });

  test('setCurrency + setAccountName update state', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = OnboardingController(prefs);
    c.setCurrency('USD');
    c.setAccountName('Trip fund');
    expect(c.state.currencyCode, 'USD');
    expect(c.state.accountName, 'Trip fund');
  });

  test('requestNotifications flips flag', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = OnboardingController(prefs);
    expect(c.state.notificationsGranted, isFalse);
    await c.requestNotifications();
    expect(c.state.notificationsGranted, isTrue);
  });

  test('resetForTest clears flag', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = OnboardingController(prefs);
    await c.complete();
    expect(c.state.completed, isTrue);
    await c.resetForTest();
    expect(c.state.completed, isFalse);
    expect(prefs.getBool(kOnboardingCompletedKey), isNull);
  });
}
