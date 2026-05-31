// High-level, offline-testable LLM use-cases for Pocket Flow.
//
// Each use-case:
//   1. Builds a strict prompt (the `build*Prompt` helpers — pure, no I/O, so
//      they can be unit-tested without a model).
//   2. Runs it through an injected [LocalLlmService].
//   3. Parses the model's text output into a typed result.
//
// Money is always handled in MINOR units (tiyın / cents) to avoid floating
// point drift, matching the domain `Money` convention.

import 'dart:convert';

import 'local_llm_service.dart';

// ---------------------------------------------------------------------------
// Receipt parsing
// ---------------------------------------------------------------------------

/// Structured result of [LlmUseCases.parseReceipt].
class ParsedReceipt {
  const ParsedReceipt({
    required this.merchant,
    required this.totalMinor,
    required this.currency,
    required this.items,
    this.date,
  });

  final String merchant;
  final int totalMinor;
  final String currency;
  final List<ReceiptItem> items;

  /// ISO-8601 date string as emitted by the model (`null` if not found).
  final String? date;

  factory ParsedReceipt.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        (json['items'] as List<dynamic>?) ?? const <dynamic>[];
    return ParsedReceipt(
      merchant: (json['merchant'] as String?)?.trim() ?? '',
      totalMinor: _asInt(json['totalMinor']),
      currency: (json['currency'] as String?)?.trim() ?? 'KZT',
      date: (json['date'] as String?)?.trim(),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(ReceiptItem.fromJson)
          .toList(growable: false),
    );
  }
}

/// A single line item on a receipt.
class ReceiptItem {
  const ReceiptItem({
    required this.name,
    required this.priceMinor,
    this.quantity = 1,
  });

  final String name;
  final int priceMinor;
  final int quantity;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => ReceiptItem(
        name: (json['name'] as String?)?.trim() ?? '',
        priceMinor: _asInt(json['priceMinor']),
        quantity: _asInt(json['quantity'], fallback: 1),
      );
}

// ---------------------------------------------------------------------------
// Push notification categorisation
// ---------------------------------------------------------------------------

/// Structured result of [LlmUseCases.categorizePushNotification].
class CategorizedPush {
  const CategorizedPush({
    required this.type,
    required this.amountMinor,
    required this.currency,
    this.merchant,
  });

  /// `expense`, `income` or `transfer`.
  final String type;
  final int amountMinor;
  final String currency;
  final String? merchant;

  factory CategorizedPush.fromJson(Map<String, dynamic> json) =>
      CategorizedPush(
        type: (json['type'] as String?)?.trim() ?? 'expense',
        amountMinor: _asInt(json['amountMinor']),
        currency: (json['currency'] as String?)?.trim() ?? 'KZT',
        merchant: (json['merchant'] as String?)?.trim(),
      );
}

// ---------------------------------------------------------------------------
// Use-case orchestrator
// ---------------------------------------------------------------------------

class LlmUseCases {
  const LlmUseCases(this._llm);

  final LocalLlmService _llm;

  /// Parses raw OCR text from a photographed receipt into a [ParsedReceipt].
  Future<ParsedReceipt> parseReceipt(String ocrText) async {
    final String raw = await _llm.infer(buildReceiptPrompt(ocrText));
    return ParsedReceipt.fromJson(_extractJsonObject(raw));
  }

  /// Categorises a bank push-notification body into a [CategorizedPush].
  Future<CategorizedPush> categorizePushNotification(String pushBody) async {
    final String raw = await _llm.infer(buildPushPrompt(pushBody));
    return CategorizedPush.fromJson(_extractJsonObject(raw));
  }

  /// Free-form financial Q&A grounded in [context] (e.g. balances, budgets).
  /// Returns the model's plain-text answer.
  Future<String> quickAdvice(String question, Map<String, Object?> context) {
    return _llm.infer(buildAdvicePrompt(question, context));
  }
}

// ---------------------------------------------------------------------------
// Prompt builders (pure — unit-tested offline)
// ---------------------------------------------------------------------------

/// JSON-strict receipt-extraction prompt.
String buildReceiptPrompt(String ocrText) {
  return '''
You are a receipt parser for a personal finance app. Extract structured data
from the OCR text below.

Rules:
- Respond with ONE JSON object and nothing else. No prose, no markdown fences.
- All money values are INTEGER MINOR units (tiyın/cents): 1234.56 -> 123456.
- "currency" is an ISO-4217 code (e.g. "KZT", "USD"). Default to "KZT".
- "date" is ISO-8601 (YYYY-MM-DD) or null if absent.
- "items" lists line items; use [] when none are detectable.

Schema:
{
  "merchant": string,
  "totalMinor": integer,
  "currency": string,
  "date": string|null,
  "items": [ { "name": string, "priceMinor": integer, "quantity": integer } ]
}

OCR text:
"""
$ocrText
"""

JSON:''';
}

/// JSON-strict bank-push categorisation prompt.
String buildPushPrompt(String pushBody) {
  return '''
You classify bank push notifications for a personal finance app.

Rules:
- Respond with ONE JSON object and nothing else. No prose, no markdown fences.
- "type" is one of: "expense", "income", "transfer".
- "amountMinor" is the INTEGER MINOR amount (tiyın/cents): 5000.00 -> 500000.
- "currency" is an ISO-4217 code. Default to "KZT".
- "merchant" is the counterparty/merchant name, or null if unknown.

Schema:
{
  "type": "expense"|"income"|"transfer",
  "amountMinor": integer,
  "currency": string,
  "merchant": string|null
}

Notification:
"""
$pushBody
"""

JSON:''';
}

/// Grounded financial-advice prompt. Context is serialized to compact JSON so
/// the model can reference the user's real figures.
String buildAdvicePrompt(String question, Map<String, Object?> context) {
  final String ctx = const JsonEncoder().convert(context);
  return '''
You are Pocket Flow's on-device financial assistant. Answer the user's
question concisely using ONLY the context provided. If the context is
insufficient, say so plainly. Do not invent numbers. Respond in the same
language as the question.

Context (JSON):
$ctx

Question:
$question

Answer:''';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pulls the first balanced `{ ... }` JSON object out of a model response,
/// tolerating leading/trailing prose or markdown fences the model may emit.
Map<String, dynamic> _extractJsonObject(String raw) {
  final int start = raw.indexOf('{');
  final int end = raw.lastIndexOf('}');
  if (start == -1 || end == -1 || end <= start) {
    throw FormatException('No JSON object in model output', raw);
  }
  final String slice = raw.substring(start, end + 1);
  final Object? decoded = jsonDecode(slice);
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Model output was not a JSON object', slice);
  }
  return decoded;
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}
