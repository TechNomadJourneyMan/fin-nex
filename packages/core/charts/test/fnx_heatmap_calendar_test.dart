import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_charts/fnx_core_charts.dart';

void main() {
  testWidgets('FnxHeatmapCalendar renders a month grid',
      (WidgetTester tester) async {
    final DateTime from = DateTime(2026, 1, 1);
    final DateTime to = DateTime(2026, 1, 31);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FnxHeatmapCalendar(
            from: from,
            to: to,
            valueByDay: <DateTime, double>{
              DateTime(2026, 1, 5): 100,
              DateTime(2026, 1, 12): 50,
              DateTime(2026, 1, 19): 200,
            },
          ),
        ),
      ),
    );
    expect(find.byType(FnxHeatmapCalendar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
