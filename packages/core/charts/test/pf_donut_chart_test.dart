import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_charts/pf_core_charts.dart';

void main() {
  testWidgets('PfDonutChart renders with data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PfDonutChart(
              semanticDescription: 'Expenses by category',
              data: <PfDonutSlice>[
                PfDonutSlice(label: 'Food', value: 1200),
                PfDonutSlice(label: 'Rent', value: 800),
                PfDonutSlice(label: 'Fun', value: 400),
              ],
              centerLabel: 'This month',
            ),
          ),
        ),
      ),
    );
    expect(find.byType(PfDonutChart), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
  });

  testWidgets('PfDonutChart shows empty state for no data',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PfDonutChart(
            data: <PfDonutSlice>[],
            semanticDescription: 'No data',
          ),
        ),
      ),
    );
    expect(find.byType(PfChartEmpty), findsOneWidget);
  });
}
