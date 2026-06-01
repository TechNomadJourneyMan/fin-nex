import 'package:pf_domain/pf_domain.dart';

/// A single line item extracted from a receipt.
///
/// [priceMinor] is the line's total price in minor currency units (tiyn for
/// KZT). [quantity] defaults to 1 when the receipt does not spell it out.
class ReceiptLineItem {
  /// Creates a line item.
  const ReceiptLineItem({
    required this.name,
    required this.quantity,
    required this.priceMinor,
  });

  /// Human-readable product name as printed on the receipt.
  final String name;

  /// Number of units. Defaults to 1 when not detected.
  final int quantity;

  /// Total price for this line in minor units (e.g. tiyn for KZT).
  final int priceMinor;

  /// Plain-map form, handy for debugging and tests.
  Map<String, Object?> toMap() => <String, Object?>{
        'name': name,
        'quantity': quantity,
        'priceMinor': priceMinor,
      };

  @override
  String toString() => 'ReceiptLineItem(name: $name, quantity: $quantity, '
      'priceMinor: $priceMinor)';
}

/// Structured output of [ReceiptParser.parse].
///
/// Money is always represented as an integer minor amount plus a [Currency]
/// — never as a double, per PocketFlow money rules.
class ParsedReceipt {
  /// Creates a parsed receipt result.
  const ParsedReceipt({
    required this.totalMinor,
    required this.currency,
    required this.merchant,
    required this.occurredAt,
    required this.lineItems,
    required this.rawText,
  });

  /// Receipt grand total in minor units (tiyn for KZT). Zero when not found.
  final int totalMinor;

  /// Detected currency. Defaults to KZT for the Kazakhstan-first launch.
  final Currency currency;

  /// Best-guess merchant name, or `null` when undetectable.
  final String? merchant;

  /// Date/time of purchase. Falls back to "now" when no date is on the
  /// receipt; callers may override in the confirm step.
  final DateTime occurredAt;

  /// Parsed line items in printed order (tax lines filtered out).
  final List<ReceiptLineItem> lineItems;

  /// The raw OCR text the parse was derived from, preserved verbatim.
  final String rawText;

  /// The detected total expressed as [Money].
  Money get total => Money(BigInt.from(totalMinor), currency);

  /// Plain-map form, handy for debugging and tests.
  Map<String, Object?> toMap() => <String, Object?>{
        'totalMinor': totalMinor,
        'currency': currency.code,
        'merchant': merchant,
        'occurredAt': occurredAt.toIso8601String(),
        'lineItems': lineItems.map((ReceiptLineItem i) => i.toMap()).toList(),
        'rawText': rawText,
      };
}
