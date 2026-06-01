import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_charts/pf_core_charts.dart';

void main() {
  testWidgets('PfStackedBarChart renders with categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: PfStackedBarChart(
              categories: const <String>['Food', 'Transit', 'Fun'],
              data: const <PfStackedBarPoint>[
                PfStackedBarPoint(
                  label: 'Mon',
                  values: <String, double>{
                    'Food': 200,
                    'Transit': 50,
                    'Fun': 100,
                  },
                ),
                PfStackedBarPoint(
                  label: 'Tue',
                  values: <String, double>{'Food': 150, 'Transit': 30},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(PfStackedBarChart), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('PfStackedBarChart empty state for no data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PfStackedBarChart(
            categories: <String>['a'],
            data: <PfStackedBarPoint>[],
          ),
        ),
      ),
    );
    expect(find.byType(PfChartEmpty), findsOneWidget);
  });
}
