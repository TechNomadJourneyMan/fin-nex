// OS share-sheet integration ("integration with other apps").
//
// Three share-out flows:
//   1. Share a single transaction as plain text.
//   2. Share a day's spending summary as plain text.
//   3. Export upcoming payment events as an .ics file any calendar app can
//      import.
//
// Text composition is delegated to pure helpers ([buildTransactionShareText],
// [buildDaySummaryShareText]) so the formatting is unit-testable; the actual
// `share_plus` calls are thin wrappers. The .ics body is produced by the pure
// [IcsExporter] in pf_calendar.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pf_calendar/pf_calendar.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:share_plus/share_plus.dart';

/// Builds the plain-text body for sharing a single [transaction].
///
/// [amountLabel] is the pre-formatted, sign-aware amount; [categoryName] and
/// [accountName] are optional context lines.
String buildTransactionShareText(
  Transaction transaction, {
  required String amountLabel,
  String? categoryName,
  String? accountName,
  String locale = 'en',
}) {
  final df = DateFormat.yMMMMd(locale).add_jm();
  final lines = <String>[
    'Pocket Flow',
    '',
    amountLabel,
    if ((transaction.description ?? '').isNotEmpty) transaction.description!,
    if (categoryName != null) 'Category: $categoryName',
    if (accountName != null) 'Account: $accountName',
    df.format(transaction.occurredAt.toLocal()),
  ];
  return lines.join('\n');
}

/// Builds the plain-text body for a day's spending summary.
String buildDaySummaryShareText({
  required DateTime day,
  required String totalLabel,
  required int transactionCount,
  required List<String> lineItems,
  String locale = 'en',
}) {
  final df = DateFormat.yMMMMd(locale);
  final out = <String>[
    'Pocket Flow — ${df.format(day)}',
    '',
    'Total: $totalLabel ($transactionCount)',
  ];
  if (lineItems.isNotEmpty) {
    out
      ..add('')
      ..addAll(lineItems.map((e) => '• $e'));
  }
  return out.join('\n');
}

/// Wraps `share_plus` + the .ics exporter for the app's share actions.
class ShareService {
  /// Creates a share service.
  const ShareService({this.icsExporter = const IcsExporter()});

  /// Exporter used by [shareUpcomingPaymentsIcs].
  final IcsExporter icsExporter;

  /// Opens the OS share sheet with [text].
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Shares a single transaction's text body.
  Future<void> shareTransaction(
    Transaction transaction, {
    required String amountLabel,
    String? categoryName,
    String? accountName,
    String locale = 'en',
  }) {
    return shareText(
      buildTransactionShareText(
        transaction,
        amountLabel: amountLabel,
        categoryName: categoryName,
        accountName: accountName,
        locale: locale,
      ),
      subject: 'Pocket Flow transaction',
    );
  }

  /// Exports [events] as an .ics file and opens the share sheet so the user can
  /// hand it to any calendar app. Falls back to sharing the raw text when file
  /// sharing is unavailable (e.g. web).
  Future<void> shareUpcomingPaymentsIcs(
    List<PfCalendarEvent> events, {
    DateTime? now,
    String fileName = 'pocketflow-payments.ics',
  }) async {
    final ics = icsExporter.build(events, now: now);
    if (kIsWeb) {
      // No filesystem share on web — fall back to sharing the text body.
      await shareText(ics, subject: 'Pocket Flow — Upcoming payments');
      return;
    }
    final bytes = utf8.encode(ics);
    await Share.shareXFiles(
      <XFile>[
        XFile.fromData(
          Uint8List.fromList(bytes),
          name: fileName,
          mimeType: 'text/calendar',
        ),
      ],
      subject: 'Pocket Flow — Upcoming payments',
    );
  }
}
