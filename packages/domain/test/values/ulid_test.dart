import 'package:fnx_domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('Ulid', () {
    test('now() generates a 26-char base32 string', () {
      final id = Ulid.now();
      expect(id.value.length, 26);
      expect(RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$').hasMatch(id.value), isTrue);
    });

    test('round-trips through value constructor', () {
      final a = Ulid.now();
      final b = Ulid(a.value);
      expect(b, a);
    });

    test('rejects wrong length', () {
      expect(() => Ulid('SHORT'), throwsArgumentError);
    });

    test('rejects invalid alphabet', () {
      expect(() => Ulid('I' * 26), throwsArgumentError);
    });

    test('createdAt round-trips through timestamp', () {
      final fixed = DateTime.utc(2026, 5, 31, 12, 0, 0);
      final id = Ulid.now(at: fixed);
      expect(id.createdAt.millisecondsSinceEpoch,
          fixed.millisecondsSinceEpoch);
    });

    test('different generations yield different ids', () {
      final a = Ulid.now();
      final b = Ulid.now();
      expect(a, isNot(equals(b)));
    });
  });
}
