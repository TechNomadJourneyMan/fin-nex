import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_charts/fnx_core_charts.dart';

void main() {
  testWidgets('FnxBarChart renders with grouped data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: FnxBarChart(
              data: const <FnxBarPoint>[
                FnxBarPoint(label: 'Mon', income: 1000, expense: 200),
                FnxBarPoint(label: 'Tue', income: 0, expense: 500),
                FnxBarPoint(label: 'Wed', income: 800, expense: 100),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(FnxBarChart), findsOneWidget);
  });

  testWidgets('FnxBarChart shows empty state for no data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: FnxBarChart(data: <FnxBarPoint>[])),
      ),
    );
    expect(find.byType(FnxChartEmpty), findsOneWidget);
  });
}
