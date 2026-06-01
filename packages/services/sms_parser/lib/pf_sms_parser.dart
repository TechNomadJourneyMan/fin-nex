/// PocketFlow SMS / push notification parsing for Kazakhstan banks (PRD F-03).
///
/// Pure-Dart, dependency-light. Wire [ParserRegistry.kazakhstan] into the app
/// and feed it raw notification strings captured by the Android
/// `SmsListener` BroadcastReceiver / NotificationListenerService.
library pf_sms_parser;

export 'src/amount.dart' show parseKztMinor, kztMinorPerMajor;
export 'src/bank_notification_parser.dart';
export 'src/parsed_transaction.dart';
export 'src/parser_registry.dart';
export 'src/parsers/freedom_parser.dart';
export 'src/parsers/halyk_parser.dart';
export 'src/parsers/kaspi_parser.dart';
