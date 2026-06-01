import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_charts/pf_core_charts.dart';

void main() {
  testWidgets('PfChartLegend renders entries and handles tap',
      (WidgetTester tester) async {
    String? tappedLabel;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PfChartLegend(
            entries: const <PfLegendEntry>[
              PfLegendEntry(
                  label: 'Food', color: PfChartPalette.indigo, value: '1 200'),
              PfLegendEntry(label: 'Rent', color: PfChartPalette.mint),
            ],
            highlightedLabel: 'Food',
            onTap: (PfLegendEntry e) => tappedLabel = e.label,
          ),
        ),
      ),
    );
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('1 200'), findsOneWidget);
    await tester.tap(find.text('Rent'));
    await tester.pump();
    expect(tappedLabel, 'Rent');
  });
}
