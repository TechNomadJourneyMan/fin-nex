import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_charts/fnx_core_charts.dart';

void main() {
  test('charts barrel exports public API', () {
    // Smoke check: ensure key symbols resolve through the barrel.
    expect(FnxChartPalette.indigo, isNotNull);
    expect(FnxChartPalette.at(99), isA<Color>());
    expect(const FnxDonutSlice(label: 'a', value: 1).label, 'a');
    expect(const FnxBarPoint(label: 'a').label, 'a');
    expect(const FnxLinePoint(x: 0, y: 0).x, 0);
    const FnxLineSeries series =
        FnxLineSeries(name: 's', points: <FnxLinePoint>[]);
    expect(series.points, isEmpty);
    expect(
      const FnxStackedBarPoint(
        label: 'm',
        values: <String, double>{},
      ).values,
      isEmpty,
    );
    expect(
      const FnxLegendEntry(
        label: 'l',
        color: FnxChartPalette.indigo,
      ).label,
      'l',
    );
  });
}
