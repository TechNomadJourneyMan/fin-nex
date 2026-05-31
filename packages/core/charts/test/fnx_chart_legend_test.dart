import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_charts/fnx_core_charts.dart';

void main() {
  testWidgets('FnxChartLegend renders entries and handles tap',
      (WidgetTester tester) async {
    String? tappedLabel;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FnxChartLegend(
            entries: const <FnxLegendEntry>[
              FnxLegendEntry(
                  label: 'Food', color: FnxChartPalette.indigo, value: '1 200'),
              FnxLegendEntry(label: 'Rent', color: FnxChartPalette.mint),
            ],
            highlightedLabel: 'Food',
            onTap: (FnxLegendEntry e) => tappedLabel = e.label,
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
