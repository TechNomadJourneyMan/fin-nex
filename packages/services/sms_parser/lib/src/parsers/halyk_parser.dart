import '../amount.dart';
import '../bank_notification_parser.dart';
import '../parsed_transaction.dart';

/// Parser for Halyk Bank SMS / push notifications.
///
/// Recognized grammar (amounts followed by the literal ISO code `KZT`):
///
/// * Expense — card purchase:
///   `Halyk Bank: Покупка 2 500 KZT в SMARTPOINT.`
///   Keyword `Покупка` ("purchase"); merchant follows the preposition `в`.
///
/// Income variants (`Пополнение`, `Зачисление`) are also recognized
/// defensively so a deposit notification is not silently dropped.
class HalykParser implements BankNotificationParser {
  /// Const constructor.
  const HalykParser();

  @override
  String get bankCode => 'halyk';

  // "Halyk Bank: Покупка <amount> KZT в <MERCHANT>." — merchant optional.
  static final RegExp _purchase = RegExp(
    'Halyk\\s*Bank\\s*:?\\s*Покупка\\s+($kztAmountPattern)\\s*KZT'
    '(?:\\s+в\\s+(.+?))?\\s*[.\$]',
    caseSensitive: false,
    unicode: true,
  );

  // Income: "Halyk Bank: Пополнение/Зачисление <amount> KZT ...".
  static final RegExp _income = RegExp(
    'Halyk\\s*Bank\\s*:?\\s*(?:Пополнение|Зачисление)\\s+'
    '($kztAmountPattern)\\s*KZT',
    caseSensitive: false,
    unicode: true,
  );

  @override
  ParsedTransaction? tryParse(String text, {DateTime? now}) {
    final at = now ?? DateTime.now();

    final purchase = _purchase.firstMatch(text);
    if (purchase != null) {
      final minor = parseKztMinor(purchase.group(1)!);
      if (minor != null) {
        final merchant = purchase.group(2)?.trim();
        return ParsedTransaction.create(
          amountMinor: minor,
          type: ParsedTxnType.expense,
          raw: text,
          occurredAt: at,
          merchant: (merchant == null || merchant.isEmpty) ? null : merchant,
        );
      }
    }

    final income = _income.firstMatch(text);
    if (income != null) {
      final minor = parseKztMinor(income.group(1)!);
      if (minor != null) {
        return ParsedTransaction.create(
          amountMinor: minor,
          type: ParsedTxnType.income,
          raw: text,
          occurredAt: at,
        );
      }
    }

    return null;
  }
}
