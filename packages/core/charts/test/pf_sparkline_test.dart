import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_charts/pf_core_charts.dart';

void main() {
  testWidgets('PfSparkline renders without exceptions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PfSparkline(
              values: <double>[1, 4, 2, 6, 3, 5, 7],
              semanticDescription: 'Upward trend',
            ),
          ),
        ),
      ),
    );
    expect(find.byType(PfSparkline), findsOneWidget);
  });

  testWidgets('PfSparkline handles too-few points gracefully',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PfSparkline(
            values: <double>[1],
            semanticDescription: 'Flat trend',
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
