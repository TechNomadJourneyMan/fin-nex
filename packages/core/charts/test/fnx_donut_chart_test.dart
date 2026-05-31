import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_charts/fnx_core_charts.dart';

void main() {
  testWidgets('FnxDonutChart renders with data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: FnxDonutChart(
              data: <FnxDonutSlice>[
                FnxDonutSlice(label: 'Food', value: 1200),
                FnxDonutSlice(label: 'Rent', value: 800),
                FnxDonutSlice(label: 'Fun', value: 400),
              ],
              centerLabel: 'This month',
            ),
          ),
        ),
      ),
    );
    expect(find.byType(FnxDonutChart), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
  });

  testWidgets('FnxDonutChart shows empty state for no data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FnxDonutChart(data: <FnxDonutSlice>[]),
        ),
      ),
    );
    expect(find.byType(FnxChartEmpty), findsOneWidget);
  });
}
