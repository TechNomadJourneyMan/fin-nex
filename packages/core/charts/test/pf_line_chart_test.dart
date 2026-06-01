import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_charts/pf_core_charts.dart';

void main() {
  testWidgets('PfLineChart renders with one series',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: PfLineChart(
              series: const <PfLineSeries>[
                PfLineSeries(
                  name: 'Balance',
                  points: <PfLinePoint>[
                    PfLinePoint(x: 0, y: 100, label: 'Mon'),
                    PfLinePoint(x: 1, y: 140),
                    PfLinePoint(x: 2, y: 120),
                    PfLinePoint(x: 3, y: 180, label: 'Thu'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(PfLineChart), findsOneWidget);
  });

  testWidgets('PfLineChart shows empty state when all series are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PfLineChart(
            series: <PfLineSeries>[
              PfLineSeries(name: 'a', points: <PfLinePoint>[]),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(PfChartEmpty), findsOneWidget);
  });
}
