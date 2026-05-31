import '../amount.dart';
import '../bank_notification_parser.dart';
import '../parsed_transaction.dart';

/// Parser for Freedom Bank (Freedom Finance) SMS / push notifications.
///
/// Recognized grammar (amounts followed by the literal ISO code `KZT`):
///
/// * Income — incoming transfer:
///   `Freedom Bank: На счёт 7 000 KZT от ИВАНОВ И.`
///   Phrase `На счёт` ("to account"); sender/counterparty follows `от`.
///   Both `счёт` and the `е`-spelling `счет` are accepted.
///
/// * Expense — outgoing payment/purchase (`Оплата`/`Покупка`) is recognized
///   defensively so debits are not dropped; merchant follows `в`.
class FreedomParser implements BankNotificationParser {
  /// Const constructor.
  const FreedomParser();

  @override
  String get bankCode => 'freedom';

  // "Freedom Bank: На счёт <amount> KZT от <SENDER>." — sender optional.
  static final RegExp _income = RegExp(
    'Freedom\\s*Bank\\s*:?\\s*На\\s+сч[её]т\\s+($kztAmountPattern)\\s*KZT'
    '(?:\\s+от\\s+(.+?))?\\s*[.\$]',
    caseSensitive: false,
    unicode: true,
  );

  // Expense: "Freedom Bank: Оплата/Покупка <amount> KZT в <MERCHANT>.".
  static final RegExp _expense = RegExp(
    'Freedom\\s*Bank\\s*:?\\s*(?:Оплата|Покупка)\\s+'
    '($kztAmountPattern)\\s*KZT(?:\\s+в\\s+(.+?))?\\s*[.\$]',
    caseSensitive: false,
    unicode: true,
  );

  @override
  ParsedTransaction? tryParse(String text, {DateTime? now}) {
    final at = now ?? DateTime.now();

    final income = _income.firstMatch(text);
    if (income != null) {
      final minor = parseKztMinor(income.group(1)!);
      if (minor != null) {
        final sender = income.group(2)?.trim();
        return ParsedTransaction.create(
          amountMinor: minor,
          type: ParsedTxnType.income,
          raw: text,
          occurredAt: at,
          merchant: (sender == null || sender.isEmpty) ? null : sender,
        );
      }
    }

    final expense = _expense.firstMatch(text);
    if (expense != null) {
      final minor = parseKztMinor(expense.group(1)!);
      if (minor != null) {
        final merchant = expense.group(2)?.trim();
        return ParsedTransaction.create(
          amountMinor: minor,
          type: ParsedTxnType.expense,
          raw: text,
          occurredAt: at,
          merchant: (merchant == null || merchant.isEmpty) ? null : merchant,
        );
      }
    }

    return null;
  }
}
