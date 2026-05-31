import 'package:fnx_sms_parser/fnx_sms_parser.dart';
import 'package:test/test.dart';

void main() {
  final registry = ParserRegistry.kazakhstan();
  final at = DateTime.utc(2026, 5, 31, 12, 0, 0);

  group('ParserRegistry', () {
    test('exposes all bundled bank codes', () {
      expect(registry.bankCodes, containsAll(['kaspi', 'halyk', 'freedom']));
    });

    test('parseFrom dispatches by bankCode', () {
      final r = registry.parseFrom(
        'halyk',
        'Halyk Bank: Покупка 2 500 KZT в SMARTPOINT.',
        now: at,
      )!;
      expect(r.merchant, 'SMARTPOINT');
      expect(r.amountMinor, 250000);
    });

    test('parseFrom returns null for unknown bankCode', () {
      expect(
        registry.parseFrom('jysan', 'anything', now: at),
        isNull,
      );
    });

    test('parse falls through parsers in order (Kaspi)', () {
      final r = registry.parse(
        'Оплата на сумму 1 234.56 ₸ в KASPI MAGAZIN.',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.expense);
      expect(r.amountMinor, 123456);
    });

    test('parse falls through to Freedom', () {
      final r = registry.parse(
        'Freedom Bank: На счёт 7 000 KZT от ИВАНОВ И.',
        now: at,
      )!;
      expect(r.type, ParsedTxnType.income);
      expect(r.amountMinor, 700000);
    });

    test('parse returns null when nothing matches', () {
      expect(registry.parse('Random unrelated message', now: at), isNull);
    });
  });
}
