import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_charts/fnx_core_charts.dart';

void main() {
  testWidgets('FnxStackedBarChart renders with categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: FnxStackedBarChart(
              categories: const <String>['Food', 'Transit', 'Fun'],
              data: const <FnxStackedBarPoint>[
                FnxStackedBarPoint(
                  label: 'Mon',
                  values: <String, double>{
                    'Food': 200,
                    'Transit': 50,
                    'Fun': 100,
                  },
                ),
                FnxStackedBarPoint(
                  label: 'Tue',
                  values: <String, double>{'Food': 150, 'Transit': 30},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(FnxStackedBarChart), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('FnxStackedBarChart empty state for no data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FnxStackedBarChart(
            categories: <String>['a'],
            data: <FnxStackedBarPoint>[],
          ),
        ),
      ),
    );
    expect(find.byType(FnxChartEmpty), findsOneWidget);
  });
}
