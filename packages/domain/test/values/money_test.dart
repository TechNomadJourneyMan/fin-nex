import 'package:decimal/decimal.dart';
import 'package:pf_domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    test('fromMajor scales by currency minor units', () {
      final m = Money.fromMajor(Decimal.parse('12.50'), Currency.usd);
      expect(m.minor, BigInt.from(1250));
      expect(m.currency, Currency.usd);
    });

    test('major recovers the decimal value', () {
      final m = Money(BigInt.from(199900), Currency.kzt);
      expect(m.major.toString(), '1999.00');
    });

    test('+ adds same currency', () {
      final a = Money(BigInt.from(500), Currency.kzt);
      final b = Money(BigInt.from(750), Currency.kzt);
      expect((a + b).minor, BigInt.from(1250));
    });

    test('+ rejects mismatched currency', () {
      final a = Money(BigInt.from(500), Currency.kzt);
      final b = Money(BigInt.from(500), Currency.usd);
      expect(() => a + b, throwsArgumentError);
    });

    test('- subtracts and can go negative', () {
      final a = Money(BigInt.from(100), Currency.eur);
      final b = Money(BigInt.from(250), Currency.eur);
      final r = a - b;
      expect(r.minor, BigInt.from(-150));
      expect(r.isNegative, isTrue);
    });

    test('* by int and Decimal', () {
      final m = Money(BigInt.from(1000), Currency.usd);
      expect((m * 3).minor, BigInt.from(3000));
      expect((m * Decimal.parse('0.5')).minor, BigInt.from(500));
    });

    test('compareTo orders by minor', () {
      final a = Money(BigInt.from(10), Currency.kzt);
      final b = Money(BigInt.from(20), Currency.kzt);
      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a.compareTo(b), lessThan(0));
    });

    test('toJson / fromJson round-trip', () {
      final m = Money(BigInt.parse('123456789012345'), Currency.rub);
      final j = m.toJson();
      final m2 = Money.fromJson(j);
      expect(m2, m);
    });

    test('equality + hashCode by props', () {
      final a = Money(BigInt.from(7), Currency.usd);
      final b = Money(BigInt.from(7), Currency.usd);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('Currency', () {
    test('parse is case-insensitive', () {
      expect(Currency.parse('usd'), Currency.usd);
      expect(Currency.parse('KZT'), Currency.kzt);
    });

    test('parse throws on unknown', () {
      expect(() => Currency.parse('XYZ'), throwsArgumentError);
    });

    test('tryParse returns null on unknown', () {
      expect(Currency.tryParse('XYZ'), isNull);
      expect(Currency.tryParse(null), isNull);
    });
  });
}
