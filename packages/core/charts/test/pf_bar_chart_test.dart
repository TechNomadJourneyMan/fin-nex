import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_charts/pf_core_charts.dart';

void main() {
  testWidgets('PfBarChart renders with grouped data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: PfBarChart(
              data: const <PfBarPoint>[
                PfBarPoint(label: 'Mon', income: 1000, expense: 200),
                PfBarPoint(label: 'Tue', income: 0, expense: 500),
                PfBarPoint(label: 'Wed', income: 800, expense: 100),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(PfBarChart), findsOneWidget);
  });

  testWidgets('PfBarChart shows empty state for no data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PfBarChart(data: <PfBarPoint>[])),
      ),
    );
    expect(find.byType(PfChartEmpty), findsOneWidget);
  });
}
