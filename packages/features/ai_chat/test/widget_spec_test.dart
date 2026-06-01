// Unit tests for WidgetSpec JSON round-tripping + disclaimer regex.

import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_ai_chat/pf_feat_ai_chat.dart';

void main() {
  group('WidgetSpec.fromJson', () {
    test('dispatches to BarChartSpec', () {
      final spec = WidgetSpec.fromJson(<String, dynamic>{
        'type': 'bar_chart',
        'title': 'Топ',
        'bars': <dynamic>[
          <String, dynamic>{'label': 'Еда', 'value': 84000},
        ],
      });
      expect(spec, isA<BarChartSpec>());
      expect((spec! as BarChartSpec).bars.single.label, 'Еда');
      expect(spec.toJson()['type'], 'bar_chart');
    });

    test('dispatches to LineChartSpec and ProgressBarSpec', () {
      expect(
        WidgetSpec.fromJson(<String, dynamic>{
          'type': 'line_chart',
          'points': <dynamic>[
            <String, dynamic>{'x': 0, 'y': 1},
          ],
        }),
        isA<LineChartSpec>(),
      );
      expect(
        WidgetSpec.fromJson(<String, dynamic>{
          'type': 'progress_bar',
          'value': 3,
          'max': 7,
        }),
        isA<ProgressBarSpec>(),
      );
    });

    test('returns null for unknown types', () {
      expect(
        WidgetSpec.fromJson(<String, dynamic>{'type': 'pie_chart'}),
        isNull,
      );
    });

    test('ProgressBarSpec.fraction is clamped to [0,1]', () {
      const over = ProgressBarSpec(value: 10, max: 4);
      expect(over.fraction, 1.0);
      const zeroMax = ProgressBarSpec(value: 5, max: 0);
      expect(zeroMax.fraction, 0.0);
    });
  });

  group('mentionsInvestment', () {
    test('matches Russian and English investing terms', () {
      expect(mentionsInvestment('Стоит ли инвестировать?'), isTrue);
      expect(mentionsInvestment('Купить акции Apple'), isTrue);
      expect(mentionsInvestment('Where should I invest?'), isTrue);
      expect(mentionsInvestment('buy some STOCKS'), isTrue);
    });

    test('does not match unrelated text', () {
      expect(mentionsInvestment('Сколько я потратил на еду?'), isFalse);
      expect(mentionsInvestment('How much did I spend?'), isFalse);
    });
  });
}
