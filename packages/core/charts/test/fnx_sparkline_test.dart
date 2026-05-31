import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_charts/fnx_core_charts.dart';

void main() {
  testWidgets('FnxSparkline renders without exceptions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: FnxSparkline(
              values: <double>[1, 4, 2, 6, 3, 5, 7],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(FnxSparkline), findsOneWidget);
  });

  testWidgets('FnxSparkline handles too-few points gracefully',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FnxSparkline(values: <double>[1]),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
