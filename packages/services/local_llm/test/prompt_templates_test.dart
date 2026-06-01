// Offline tests for the pure prompt builders + output parsers.
//
// These never touch a model — they verify the JSON-strict prompt shape and
// that the parsers tolerate noisy model output.

import 'package:flutter_test/flutter_test.dart';
import 'package:pf_local_llm/pf_local_llm.dart';

void main() {
  group('buildReceiptPrompt', () {
    const String ocr = 'KASPI MAGAZIN\nMilk 450.00\nTotal 1234.56 KZT';
    final String prompt = buildReceiptPrompt(ocr);

    test('embeds the OCR text', () {
      expect(prompt, contains('KASPI MAGAZIN'));
      expect(prompt, contains('1234.56'));
    });

    test('demands a single JSON object, no markdown', () {
      expect(prompt, contains('ONE JSON object'));
      expect(prompt, contains('no markdown fences'));
    });

    test('declares the full schema keys', () {
      expect(prompt, contains('"merchant"'));
      expect(prompt, contains('"totalMinor"'));
      expect(prompt, contains('"currency"'));
      expect(prompt, contains('"date"'));
      expect(prompt, contains('"items"'));
      expect(prompt, contains('"priceMinor"'));
      expect(prompt, contains('"quantity"'));
    });

    test('specifies minor-unit money convention', () {
      expect(prompt, contains('MINOR'));
      expect(prompt, contains('123456'));
    });

    test('ends with a JSON cue', () {
      expect(prompt.trimRight(), endsWith('JSON:'));
    });
  });

  group('buildPushPrompt', () {
    const String body = 'Pokupka 5000 KZT v MAGNUM. Dostupno: 12000 KZT';
    final String prompt = buildPushPrompt(body);

    test('embeds the push body', () {
      expect(prompt, contains('MAGNUM'));
    });

    test('declares the categorisation schema', () {
      expect(prompt, contains('"type"'));
      expect(prompt, contains('"amountMinor"'));
      expect(prompt, contains('"currency"'));
      expect(prompt, contains('"merchant"'));
      expect(prompt, contains('"expense"'));
      expect(prompt, contains('"income"'));
      expect(prompt, contains('"transfer"'));
    });

    test('requires a single JSON object', () {
      expect(prompt, contains('ONE JSON object'));
    });
  });

  group('buildAdvicePrompt', () {
    final String prompt = buildAdvicePrompt(
      'Сколько я трачу на еду?',
      <String, Object?>{'foodMinor': 4500000, 'currency': 'KZT'},
    );

    test('embeds the question', () {
      expect(prompt, contains('Сколько я трачу на еду?'));
    });

    test('serializes context as JSON', () {
      expect(prompt, contains('"foodMinor":4500000'));
      expect(prompt, contains('"currency":"KZT"'));
    });

    test('instructs to use only provided context', () {
      expect(prompt, contains('ONLY the context'));
    });
  });

  group('ParsedReceipt.fromJson', () {
    test('parses a full object', () {
      final ParsedReceipt r = ParsedReceipt.fromJson(<String, dynamic>{
        'merchant': '  Magnum ',
        'totalMinor': 123456,
        'currency': 'KZT',
        'date': '2026-05-31',
        'items': <dynamic>[
          <String, dynamic>{
            'name': 'Milk',
            'priceMinor': 45000,
            'quantity': 2,
          },
        ],
      });
      expect(r.merchant, 'Magnum');
      expect(r.totalMinor, 123456);
      expect(r.currency, 'KZT');
      expect(r.date, '2026-05-31');
      expect(r.items, hasLength(1));
      expect(r.items.first.name, 'Milk');
      expect(r.items.first.quantity, 2);
    });

    test('coerces string/double money and defaults', () {
      final ParsedReceipt r = ParsedReceipt.fromJson(<String, dynamic>{
        'merchant': 'X',
        'totalMinor': '99900',
      });
      expect(r.totalMinor, 99900);
      expect(r.currency, 'KZT'); // default
      expect(r.date, isNull);
      expect(r.items, isEmpty);
    });
  });

  group('CategorizedPush.fromJson', () {
    test('parses a typical expense', () {
      final CategorizedPush p = CategorizedPush.fromJson(<String, dynamic>{
        'type': 'expense',
        'amountMinor': 500000,
        'currency': 'KZT',
        'merchant': 'Magnum',
      });
      expect(p.type, 'expense');
      expect(p.amountMinor, 500000);
      expect(p.merchant, 'Magnum');
    });

    test('defaults type/currency when missing', () {
      final CategorizedPush p = CategorizedPush.fromJson(<String, dynamic>{
        'amountMinor': 100,
      });
      expect(p.type, 'expense');
      expect(p.currency, 'KZT');
      expect(p.merchant, isNull);
    });
  });

  group('use-cases parse noisy model output via injected service', () {
    test('parseReceipt strips prose + markdown fences', () async {
      const String noisy = '''
Here is the result:
```json
{ "merchant": "Magnum", "totalMinor": 123456, "currency": "KZT",
  "date": null, "items": [] }
```
Hope that helps!''';
      final LlmUseCases uc = LlmUseCases(_FakeLlm(noisy));
      final ParsedReceipt r = await uc.parseReceipt('whatever');
      expect(r.merchant, 'Magnum');
      expect(r.totalMinor, 123456);
    });

    test('categorizePushNotification extracts embedded JSON', () async {
      const String noisy = 'Sure -> {"type":"income","amountMinor":700000,'
          '"currency":"KZT","merchant":null}';
      final LlmUseCases uc = LlmUseCases(_FakeLlm(noisy));
      final CategorizedPush p = await uc.categorizePushNotification('x');
      expect(p.type, 'income');
      expect(p.amountMinor, 700000);
    });

    test('throws FormatException when no JSON present', () async {
      final LlmUseCases uc = LlmUseCases(_FakeLlm('no json here'));
      expect(
        () => uc.parseReceipt('x'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

/// Minimal in-memory [LocalLlmService] that returns a canned string.
class _FakeLlm implements LocalLlmService {
  _FakeLlm(this.canned);
  final String canned;

  @override
  String get modelId => 'fake';
  @override
  int get approxModelSizeBytes => 0;
  @override
  Future<bool> isInstalled() async => true;
  @override
  Future<bool> isReady() async => true;
  @override
  Future<void> download() async {}
  @override
  Stream<LlmDownloadProgress> get downloadProgress =>
      const Stream<LlmDownloadProgress>.empty();
  @override
  Future<String> infer(String prompt) async => canned;
  @override
  Stream<String> stream(String prompt) => Stream<String>.value(canned);
  @override
  Future<void> dispose() async {}
}
