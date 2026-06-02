import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pocketflow/services/share_service.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  group('buildDaySummaryShareText', () {
    test('includes brand, total, count and line items', () {
      final text = buildDaySummaryShareText(
        day: DateTime(2026, 6, 2),
        totalLabel: '₸ 3 200',
        transactionCount: 2,
        lineItems: const ['Coffee — ₸ 1 200', 'Lunch — ₸ 2 000'],
      );
      expect(text, contains('Pocket Flow'));
      expect(text, contains('₸ 3 200'));
      expect(text, contains('(2)'));
      expect(text, contains('• Coffee — ₸ 1 200'));
      expect(text, contains('• Lunch — ₸ 2 000'));
    });

    test('omits the items block when there are none', () {
      final text = buildDaySummaryShareText(
        day: DateTime(2026, 6, 2),
        totalLabel: '₸ 0',
        transactionCount: 0,
        lineItems: const [],
      );
      expect(text, isNot(contains('•')));
    });
  });
}
