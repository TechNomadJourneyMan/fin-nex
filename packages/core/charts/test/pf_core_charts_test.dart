import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_charts/pf_core_charts.dart';

void main() {
  test('charts barrel exports public API', () {
    // Smoke check: ensure key symbols resolve through the barrel.
    expect(PfChartPalette.indigo, isNotNull);
    expect(PfChartPalette.at(99), isA<Color>());
    expect(const PfDonutSlice(label: 'a', value: 1).label, 'a');
    expect(const PfBarPoint(label: 'a').label, 'a');
    expect(const PfLinePoint(x: 0, y: 0).x, 0);
    const PfLineSeries series =
        PfLineSeries(name: 's', points: <PfLinePoint>[]);
    expect(series.points, isEmpty);
    expect(
      const PfStackedBarPoint(
        label: 'm',
        values: <String, double>{},
      ).values,
      isEmpty,
    );
    expect(
      const PfLegendEntry(
        label: 'l',
        color: PfChartPalette.indigo,
      ).label,
      'l',
    );
  });
}
