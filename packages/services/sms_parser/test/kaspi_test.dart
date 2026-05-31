import 'package:fnx_sms_parser/fnx_sms_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = KaspiParser();
  final at = DateTime.utc(2026, 5, 31, 12, 0, 0);

  group('KaspiParser', () {
    test('bankCode is kaspi', () {
      expect(parser.bankCode, 'kaspi');
    });

    test('parses income with space thousands separator', () {
      final r = parser.tryParse(
        'Поступление 5 000 ₸. Доступно: 12 345 ₸. Сообщение: Зарплата',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.income);
      expect(r.amountMinor, 500000); // 5000 ₸ -> 500000 tiyn
      expect(r.currency, 'KZT');
      // Balance (12 345) must NOT be picked up as the amount.
      expect(r.amountMinor, isNot(1234500));
    });

    test('parses payment with decimals and merchant', () {
      final r = parser.tryParse(
        'Оплата на сумму 1 234.56 ₸ в KASPI MAGAZIN.',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.expense);
      expect(r.amountMinor, 123456);
      expect(r.merchant, 'KASPI MAGAZIN');
    });

    test('parses generic debit (Списание) without merchant', () {
      final r = parser.tryParse(
        'Списание 4 500 ₸. Доступно: 7 845 ₸.',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.expense);
      expect(r.amountMinor, 450000);
      expect(r.merchant, isNull);
    });

    test('parses payment with comma decimals (mixed locale)', () {
      final r = parser.tryParse(
        'Оплата на сумму 99,90 ₸ в MAGNUM.',
        now: at,
      )!;
      expect(r.amountMinor, 9990);
      expect(r.merchant, 'MAGNUM');
    });

    test('handles non-breaking space grouping in large income', () {
      final r = parser.tryParse(
        'Поступление 1 250 000 ₸. Доступно: 1 300 000 ₸.',
        now: at,
      )!;
      expect(r.amountMinor, 125000000); // 1 250 000 ₸
    });

    test('externalRef is sha-1 of raw and is stable', () {
      const raw = 'Списание 4 500 ₸.';
      final r = parser.tryParse(raw, now: at)!;
      expect(r.externalRef, ParsedTransaction.sha1OfRaw(raw));
      expect(r.externalRef.length, 40);
    });

    test('returns null for unrelated text', () {
      expect(parser.tryParse('Ваш баланс обновлён.', now: at), isNull);
    });
  });
}
