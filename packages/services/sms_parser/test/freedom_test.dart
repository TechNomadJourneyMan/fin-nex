import 'package:fnx_sms_parser/fnx_sms_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = FreedomParser();
  final at = DateTime.utc(2026, 5, 31, 12, 0, 0);

  group('FreedomParser', () {
    test('bankCode is freedom', () {
      expect(parser.bankCode, 'freedom');
    });

    test('parses incoming transfer with sender', () {
      final r = parser.tryParse(
        'Freedom Bank: На счёт 7 000 KZT от ИВАНОВ И.',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.income);
      expect(r.amountMinor, 700000);
      expect(r.currency, 'KZT');
      expect(r.merchant, 'ИВАНОВ И');
    });

    test('accepts the е-spelling of счет', () {
      final r = parser.tryParse(
        'Freedom Bank: На счет 15 000 KZT от ПЕТРОВ П.',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.income);
      expect(r.amountMinor, 1500000);
      expect(r.merchant, 'ПЕТРОВ П');
    });

    test('parses income with decimal amount', () {
      final r = parser.tryParse(
        'Freedom Bank: На счёт 1 234.50 KZT от ABAI K.',
        now: at,
      )!;
      expect(r.amountMinor, 123450);
      expect(r.merchant, 'ABAI K');
    });

    test('parses expense (Оплата) with merchant', () {
      final r = parser.tryParse(
        'Freedom Bank: Оплата 3 200 KZT в GLOVO.',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.expense);
      expect(r.amountMinor, 320000);
      expect(r.merchant, 'GLOVO');
    });

    test('parses income with apostrophe grouping (mixed locale)', () {
      final r = parser.tryParse(
        "Freedom Bank: На счёт 7'500 KZT от SALARY.",
        now: at,
      )!;
      expect(r.amountMinor, 750000);
      expect(r.merchant, 'SALARY');
    });

    test('returns null for unrelated text', () {
      expect(
        parser.tryParse('Freedom Bank: OTP код 1234.', now: at),
        isNull,
      );
    });
  });
}
