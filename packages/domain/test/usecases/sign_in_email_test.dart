import 'package:fnx_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockAuth extends Mock implements AuthRepository {}

void main() {
  test('rejects invalid email', () async {
    final auth = _MockAuth();
    final uc = SignInEmail(auth);
    await expectLater(
      uc.call(email: 'nope', password: '12345678'),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('rejects short password', () async {
    final auth = _MockAuth();
    final uc = SignInEmail(auth);
    await expectLater(
      uc.call(email: 'a@b.com', password: '123'),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('delegates to repo on valid input', () async {
    final auth = _MockAuth();
    final user = User(
      id: Ulid.now(),
      locale: 'ru-KZ',
      timezone: 'Asia/Almaty',
      primaryCurrency: Currency.kzt,
      countryCode: 'KZ',
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final session = AuthSession(
      accessToken: 'a',
      refreshToken: 'r',
      expiresAt: DateTime.utc(2026, 6, 1),
      user: user,
    );
    when(() => auth.signInWithEmail(email: 'a@b.com', password: '12345678'))
        .thenAnswer((_) async => session);

    final out = await SignInEmail(auth)
        .call(email: 'a@b.com', password: '12345678');

    expect(out, session);
  });
}
