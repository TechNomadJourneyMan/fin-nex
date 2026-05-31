import 'parsed_transaction.dart';

/// Contract every bank-specific notification parser implements.
///
/// Implementations are pure and stateless: [tryParse] must not perform IO and
/// must return `null` (never throw) when [text] does not match the bank's
/// notification grammar, so the [ParserRegistry] can fall through to the next
/// candidate.
abstract class BankNotificationParser {
  /// Stable short identifier for the bank, e.g. `'kaspi'`, `'halyk'`,
  /// `'freedom'`. Used by the registry for direct dispatch.
  String get bankCode;

  /// Attempts to parse [text] into a [ParsedTransaction], or returns `null` if
  /// this parser does not recognize the message.
  ///
  /// [now] is the timestamp used for [ParsedTransaction.occurredAt] when the
  /// message carries no explicit date; the registry injects it so parsing is
  /// deterministic and testable. When omitted, `DateTime.now()` is used.
  ParsedTransaction? tryParse(String text, {DateTime? now});
}
