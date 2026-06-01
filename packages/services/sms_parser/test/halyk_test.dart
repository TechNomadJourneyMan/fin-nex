import 'package:pf_sms_parser/pf_sms_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = HalykParser();
  final at = DateTime.utc(2026, 5, 31, 12, 0, 0);

  group('HalykParser', () {
    test('bankCode is halyk', () {
      expect(parser.bankCode, 'halyk');
    });

    test('parses purchase with merchant', () {
      final r = parser.tryParse(
        'Halyk Bank: Покупка 2 500 KZT в SMARTPOINT.',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.expense);
      expect(r.amountMinor, 250000);
      expect(r.currency, 'KZT');
      expect(r.merchant, 'SMARTPOINT');
    });

    test('parses purchase with decimals', () {
      final r = parser.tryParse(
        'Halyk Bank: Покупка 349.99 KZT в WOLT.',
        now: at,
      )!;
      expect(r.amountMinor, 34999);
      expect(r.merchant, 'WOLT');
    });

    test('parses purchase with multi-word merchant', () {
      final r = parser.tryParse(
        'Halyk Bank: Покупка 12 000 KZT в SMALL TALK COFFEE.',
        now: at,
      )!;
      expect(r.amountMinor, 1200000);
      expect(r.merchant, 'SMALL TALK COFFEE');
    });

    test('parses income (Пополнение)', () {
      final r = parser.tryParse(
        'Halyk Bank: Пополнение 30 000 KZT. Доступно 45 000 KZT.',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.income);
      expect(r.amountMinor, 3000000);
    });

    test('tolerates missing colon after bank name (push variant)', () {
      final r = parser.tryParse(
        'Halyk Bank Покупка 1 000 KZT в TECHNODOM.',
        now: at,
      )!;
      expect(r.amountMinor, 100000);
      expect(r.merchant, 'TECHNODOM');
    });

    test('returns null for non-Halyk text', () {
      expect(
        parser.tryParse('Kaspi: Оплата 100 ₸ в SHOP.', now: at),
        isNull,
      );
    });
  });
}
