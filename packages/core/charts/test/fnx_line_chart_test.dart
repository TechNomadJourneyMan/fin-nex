import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_charts/fnx_core_charts.dart';

void main() {
  testWidgets('FnxLineChart renders with one series',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: FnxLineChart(
              series: const <FnxLineSeries>[
                FnxLineSeries(
                  name: 'Balance',
                  points: <FnxLinePoint>[
                    FnxLinePoint(x: 0, y: 100, label: 'Mon'),
                    FnxLinePoint(x: 1, y: 140),
                    FnxLinePoint(x: 2, y: 120),
                    FnxLinePoint(x: 3, y: 180, label: 'Thu'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(FnxLineChart), findsOneWidget);
  });

  testWidgets('FnxLineChart shows empty state when all series are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FnxLineChart(
            series: <FnxLineSeries>[
              FnxLineSeries(name: 'a', points: <FnxLinePoint>[]),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(FnxChartEmpty), findsOneWidget);
  });
}
