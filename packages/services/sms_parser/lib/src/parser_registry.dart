import 'bank_notification_parser.dart';
import 'parsed_transaction.dart';
import 'parsers/freedom_parser.dart';
import 'parsers/halyk_parser.dart';
import 'parsers/kaspi_parser.dart';

/// Holds the set of available [BankNotificationParser]s and dispatches an
/// incoming notification to the right one.
///
/// Two strategies are supported:
/// * [parseFrom] — direct dispatch when the originating bank is already known
///   (e.g. the Android SMS sender address mapped to a [BankNotificationParser.bankCode]).
/// * [parse] — fallback that tries every registered parser in registration
///   order and returns the first non-null result (used for push notifications
///   where the source bank is ambiguous).
class ParserRegistry {
  /// Creates a registry over [parsers], preserving their order.
  ParserRegistry(List<BankNotificationParser> parsers)
      : _ordered = List<BankNotificationParser>.unmodifiable(parsers),
        _byCode = {
          for (final p in parsers) p.bankCode: p,
        };

  /// Registry pre-populated with all bundled Kazakhstan bank parsers, in
  /// priority order: Kaspi, Halyk, Freedom.
  factory ParserRegistry.kazakhstan() => ParserRegistry(
        const <BankNotificationParser>[
          KaspiParser(),
          HalykParser(),
          FreedomParser(),
        ],
      );

  final List<BankNotificationParser> _ordered;
  final Map<String, BankNotificationParser> _byCode;

  /// All registered parsers, in registration order.
  List<BankNotificationParser> get parsers => _ordered;

  /// The [bankCode]s this registry can dispatch to.
  Iterable<String> get bankCodes => _byCode.keys;

  /// Parses [text] using the parser registered under [bankCode]. Returns
  /// `null` if no such parser exists or it does not recognize [text].
  ParsedTransaction? parseFrom(
    String bankCode,
    String text, {
    DateTime? now,
  }) {
    final parser = _byCode[bankCode];
    if (parser == null) {
      return null;
    }
    return parser.tryParse(text, now: now);
  }

  /// Tries every parser in order and returns the first successful parse, or
  /// `null` if none recognize [text].
  ParsedTransaction? parse(String text, {DateTime? now}) {
    for (final parser in _ordered) {
      final result = parser.tryParse(text, now: now);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
