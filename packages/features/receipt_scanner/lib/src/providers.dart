import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/pf_domain.dart';

import 'ocr/ocr_engine.dart';
import 'parsing/receipt_parser.dart';

/// Provides the on-device [OcrEngine].
///
/// Defaults to the ML Kit implementation. Override in tests with a fake.
/// Disposed automatically when the provider is torn down.
final ocrEngineProvider = Provider<OcrEngine>((Ref ref) {
  final OcrEngine engine = MlKitOcrEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

/// Provides the stateless heuristic [ReceiptParser].
final receiptParserProvider = Provider<ReceiptParser>(
  (Ref ref) => const ReceiptParser(),
);

/// Default [Currency] applied to parsed receipts.
///
/// Defaults to KZT for the Kazakhstan-first launch; override from settings.
final receiptCurrencyProvider = Provider<Currency>((Ref ref) => Currency.kzt);
