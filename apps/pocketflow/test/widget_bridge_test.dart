import 'package:flutter_test/flutter_test.dart';
import 'package:pocketflow/services/widget_bridge.dart';

void main() {
  group('WidgetPayload', () {
    test('serializes to the native string map with the expected keys', () {
      const payload = WidgetPayload(
        balance: '₸ 482 300',
        nextPaymentLabel: 'Netflix · ₸ 4 990',
        nextPaymentDate: '2026-06-10',
        todaySpend: '₸ 3 200',
      );

      final map = payload.toMap();
      expect(
        map.keys,
        containsAll(<String>[
          'balance',
          'nextPaymentLabel',
          'nextPaymentDate',
          'todaySpend',
        ]),
      );
      expect(map['balance'], '₸ 482 300');
      expect(map['nextPaymentLabel'], 'Netflix · ₸ 4 990');
      expect(map['nextPaymentDate'], '2026-06-10');
      expect(map['todaySpend'], '₸ 3 200');
      // Every value is a String (native store contract).
      expect(map.values, everyElement(isA<String>()));
    });

    test('value equality holds', () {
      const a = WidgetPayload(
        balance: '1',
        nextPaymentLabel: 'x',
        nextPaymentDate: '2026-01-01',
        todaySpend: '0',
      );
      const b = WidgetPayload(
        balance: '1',
        nextPaymentLabel: 'x',
        nextPaymentDate: '2026-01-01',
        todaySpend: '0',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('empty next-payment fields serialize as empty strings', () {
      const payload = WidgetPayload(
        balance: '0',
        nextPaymentLabel: '',
        nextPaymentDate: '',
        todaySpend: '0',
      );
      expect(payload.toMap()['nextPaymentLabel'], '');
      expect(payload.toMap()['nextPaymentDate'], '');
    });
  });
}
