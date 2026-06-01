import 'package:flutter_test/flutter_test.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_receipt_scanner/receipt_scanner.dart';

void main() {
  const ReceiptParser parser = ReceiptParser();
  final DateTime now = DateTime(2026, 5, 31, 12);

  group('ReceiptParser - Magnum hypermarket (Cyrillic, dd.MM.yyyy)', () {
    const String raw = '''
МАГНУМ КЭШ ЭНД КЕРРИ
г. Алматы, ул. Розыбакиева 247
БИН 050540004455
ЧЕК № 0042
12.03.2026 18:42

Молоко Айран 1л       2 x 450,00   900,00
Хлеб Бородинский                   320,00
Сыр Голландский 200г               1 250,50
НДС 12%                            257,20
ПОДЫТОГ                          2 470,50
ИТОГО                            2 470,50
Карта                            2 470,50
''';

    final ParsedReceipt result = parser.parse(raw, now: now);

    test('extracts grand total in minor units (KZT, 2dp)', () {
      // 2 470,50 KZT -> 247050 tiyn.
      expect(result.totalMinor, 247050);
      expect(result.currency, Currency.kzt);
      expect(result.total, Money(BigInt.from(247050), Currency.kzt));
    });

    test('parses dd.MM.yyyy date with time near the top', () {
      expect(result.occurredAt, DateTime(2026, 3, 12, 18, 42));
    });

    test('merchant is the first alphabetic header line', () {
      expect(result.merchant, 'МАГНУМ КЭШ ЭНД КЕРРИ');
    });

    test('filters out VAT / subtotal / payment lines from items', () {
      final List<String> names =
          result.lineItems.map((ReceiptLineItem i) => i.name).toList();
      expect(names, contains('Молоко Айран 1л'));
      expect(names, contains('Хлеб Бородинский'));
      expect(names, contains('Сыр Голландский 200г'));
      // The tax/subtotal/total lines must not appear as line items. (We match
      // whole "words" to avoid false positives like НДС inside ГОЛЛАНДСКИЙ.)
      bool startsWith(String prefix) =>
          names.any((String n) => n.toUpperCase().startsWith(prefix));
      expect(startsWith('НДС'), isFalse);
      expect(startsWith('ПОДЫТОГ'), isFalse);
      expect(startsWith('ИТОГО'), isFalse);
      // Exactly the three real products are detected.
      expect(result.lineItems, hasLength(3));
    });

    test('parses quantity from "N x price" form', () {
      final ReceiptLineItem milk = result.lineItems
          .firstWhere((ReceiptLineItem i) => i.name == 'Молоко Айран 1л');
      expect(milk.quantity, 2);
      expect(milk.priceMinor, 90000); // 900,00 KZT
    });

    test('preserves raw text verbatim', () {
      expect(result.rawText, raw);
    });
  });

  group('ReceiptParser - Small store (Latin TOTAL, yyyy-MM-dd)', () {
    const String raw = '''
GREEN MARKET LLP
Astana
2026-01-07 09:15

Coffee Latte           1 200.00
Croissant                650.00
Water 0.5L               180.00
TAX 12%                  244.50
TOTAL                  2 030.00
CASH                   2 500.00
CHANGE                   470.00
''';

    final ParsedReceipt result = parser.parse(raw, now: now);

    test('parses Latin TOTAL keyword', () {
      expect(result.totalMinor, 203000); // 2 030.00
    });

    test('parses yyyy-MM-dd date', () {
      expect(result.occurredAt, DateTime(2026, 1, 7, 9, 15));
    });

    test('detects merchant', () {
      expect(result.merchant, 'GREEN MARKET LLP');
    });

    test('excludes TAX / CASH / CHANGE rows', () {
      final List<String> names =
          result.lineItems.map((ReceiptLineItem i) => i.name).toList();
      expect(names, containsAll(<String>['Coffee Latte', 'Croissant']));
      expect(names.any((String n) => n.contains('TAX')), isFalse);
      expect(names.any((String n) => n.contains('CASH')), isFalse);
      expect(names.any((String n) => n.contains('CHANGE')), isFalse);
    });

    test('default quantity is 1 when not printed', () {
      final ReceiptLineItem croissant = result.lineItems
          .firstWhere((ReceiptLineItem i) => i.name == 'Croissant');
      expect(croissant.quantity, 1);
      expect(croissant.priceMinor, 65000);
    });
  });

  group('ReceiptParser - Pharmacy (К ОПЛАТЕ, no time)', () {
    const String raw = '''
АПТЕКА ЕВРОПА
Аспирин 500мг           890,00
Витамин С                450,00
СКИДКА                    50,00
К ОПЛАТЕ               1 290,00
25.12.2025
''';

    final ParsedReceipt result = parser.parse(raw, now: now);

    test('recognizes "К ОПЛАТЕ" as the total', () {
      expect(result.totalMinor, 129000);
    });

    test('finds date even when not in the top window', () {
      expect(result.occurredAt, DateTime(2025, 12, 25));
    });

    test('excludes discount line from items', () {
      final List<String> names =
          result.lineItems.map((ReceiptLineItem i) => i.name).toList();
      expect(names, containsAll(<String>['Аспирин 500мг', 'Витамин С']));
      expect(
          names.any((String n) => n.toUpperCase().contains('СКИДКА')), isFalse);
    });
  });

  group('ReceiptParser - graceful degradation', () {
    test('empty input never throws and falls back to now', () {
      final ParsedReceipt result = parser.parse('', now: now);
      expect(result.totalMinor, 0);
      expect(result.merchant, isNull);
      expect(result.occurredAt, now);
      expect(result.lineItems, isEmpty);
    });

    test('garbage input yields zero total without throwing', () {
      final ParsedReceipt result = parser.parse('@@@ ### \$\$\$', now: now);
      expect(result.totalMinor, 0);
      expect(result.occurredAt, now);
    });
  });
}
