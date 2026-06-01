import 'package:flutter/material.dart';
import 'package:pf_core_charts/pf_core_charts.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

import '../entities/widget_spec.dart';

/// Renders an inline AI [WidgetSpec] as the matching PocketFlow chart, wrapped in
/// a card. Switches on the sealed [WidgetSpec] subtype.
class InlineWidgetRenderer extends StatelessWidget {
  /// Default constructor.
  const InlineWidgetRenderer({super.key, required this.spec});

  /// The widget spec to render.
  final WidgetSpec spec;

  @override
  Widget build(BuildContext context) {
    final typo = context.fnxTypography;
    final Widget chart = switch (spec) {
      final BarChartSpec s => PfBarChart(
          height: 180,
          semanticDescription: '${spec.title ?? 'Bar chart'}: '
              '${s.bars.map((BarChartBar b) => '${b.label} '
                  '${b.value.round()}').join(', ')}',
          data: <PfBarPoint>[
            for (final BarChartBar b in s.bars)
              PfBarPoint(label: b.label, expense: b.value),
          ],
        ),
      final LineChartSpec s => PfLineChart(
          height: 180,
          semanticDescription: '${spec.title ?? s.seriesName}: '
              '${s.points.map((LineChartPoint p) => '${p.label ?? p.x} '
                  '${p.y.round()}').join(', ')}',
          series: <PfLineSeries>[
            PfLineSeries(
              name: s.seriesName,
              points: <PfLinePoint>[
                for (final LineChartPoint p in s.points)
                  PfLinePoint(x: p.x, y: p.y, label: p.label),
              ],
            ),
          ],
        ),
      final ProgressBarSpec s => _ProgressBar(spec: s),
    };

    return Padding(
      padding: const EdgeInsets.only(top: PfSpacing.x2),
      child: PfCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (spec.title != null) ...<Widget>[
              Text(spec.title!, style: typo.bodyMd),
              const SizedBox(height: PfSpacing.x2),
            ],
            chart,
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.spec});

  final ProgressBarSpec spec;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final percent = (spec.fraction * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(PfTokens.radiusSm),
          child: LinearProgressIndicator(
            value: spec.fraction,
            minHeight: 10,
            backgroundColor: colors.surfaceSunken,
            valueColor: AlwaysStoppedAnimation<Color>(colors.brand),
          ),
        ),
        const SizedBox(height: PfSpacing.x1),
        Text(
          spec.label == null ? '$percent%' : '$percent% · ${spec.label}',
          style: typo.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
