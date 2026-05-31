import 'package:flutter/material.dart';
import 'package:fnx_core_charts/fnx_core_charts.dart';
import 'package:fnx_core_tokens/fnx_core_tokens.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

import '../entities/widget_spec.dart';

/// Renders an inline AI [WidgetSpec] as the matching FinNex chart, wrapped in
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
      final BarChartSpec s => FnxBarChart(
          height: 180,
          data: <FnxBarPoint>[
            for (final BarChartBar b in s.bars)
              FnxBarPoint(label: b.label, expense: b.value),
          ],
        ),
      final LineChartSpec s => FnxLineChart(
          height: 180,
          series: <FnxLineSeries>[
            FnxLineSeries(
              name: s.seriesName,
              points: <FnxLinePoint>[
                for (final LineChartPoint p in s.points)
                  FnxLinePoint(x: p.x, y: p.y, label: p.label),
              ],
            ),
          ],
        ),
      final ProgressBarSpec s => _ProgressBar(spec: s),
    };

    return Padding(
      padding: const EdgeInsets.only(top: FnxSpacing.x2),
      child: FnxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (spec.title != null) ...<Widget>[
              Text(spec.title!, style: typo.bodyMd),
              const SizedBox(height: FnxSpacing.x2),
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
          borderRadius: BorderRadius.circular(FnxTokens.radiusSm),
          child: LinearProgressIndicator(
            value: spec.fraction,
            minHeight: 10,
            backgroundColor: colors.surfaceSunken,
            valueColor: AlwaysStoppedAnimation<Color>(colors.brand),
          ),
        ),
        const SizedBox(height: FnxSpacing.x1),
        Text(
          spec.label == null ? '$percent%' : '$percent% · ${spec.label}',
          style: typo.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
