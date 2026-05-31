import '../amount.dart';
import '../bank_notification_parser.dart';
import '../parsed_transaction.dart';

/// Parser for Kaspi Bank SMS / push notifications (Russian-language).
///
/// Recognized grammars (all amounts followed by the `₸` tenge sign):
///
/// * Income — deposits:
///   `Поступление 5 000 ₸. Доступно: 12 345 ₸. Сообщение: ...`
///   Keyword `Поступление` ("incoming"); the *first* amount is the txn value,
///   the `Доступно:` amount is the running balance and is ignored.
///
/// * Expense — card purchase at a named merchant:
///   `Оплата на сумму 1 234.56 ₸ в KASPI MAGAZIN.`
///   Keyword `Оплата` ("payment"); merchant follows the preposition `в`.
///
/// * Expense — generic debit:
///   `Списание 4 500 ₸. ...`
///   Keyword `Списание` ("write-off"); no merchant.
class KaspiParser implements BankNotificationParser {
  /// Const constructor.
  const KaspiParser();

  @override
  String get bankCode => 'kaspi';

  // First "<amount> ₸" occurrence after an income keyword.
  static final RegExp _income = RegExp(
    'Поступление\\s+($kztAmountPattern)\\s*₸',
    caseSensitive: false,
    unicode: true,
  );

  // "Оплата ... <amount> ₸ в <MERCHANT>" — merchant up to '.' or end.
  static final RegExp _payment = RegExp(
    'Оплата(?:\\s+на\\s+сумму)?\\s+($kztAmountPattern)\\s*₸'
    '(?:\\s+в\\s+(.+?))?\\s*[.\$]',
    caseSensitive: false,
    unicode: true,
  );

  // Generic debit.
  static final RegExp _debit = RegExp(
    'Списание\\s+($kztAmountPattern)\\s*₸',
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
        return ParsedTransaction.create(
          amountMinor: minor,
          type: ParsedTxnType.income,
          raw: text,
          occurredAt: at,
        );
      }
    }

    final payment = _payment.firstMatch(text);
    if (payment != null) {
      final minor = parseKztMinor(payment.group(1)!);
      if (minor != null) {
        final merchant = payment.group(2)?.trim();
        return ParsedTransaction.create(
          amountMinor: minor,
          type: ParsedTxnType.expense,
          raw: text,
          occurredAt: at,
          merchant: (merchant == null || merchant.isEmpty) ? null : merchant,
        );
      }
    }

    final debit = _debit.firstMatch(text);
    if (debit != null) {
      final minor = parseKztMinor(debit.group(1)!);
      if (minor != null) {
        return ParsedTransaction.create(
          amountMinor: minor,
          type: ParsedTxnType.expense,
          raw: text,
          occurredAt: at,
        );
      }
    }

    return null;
  }
}
