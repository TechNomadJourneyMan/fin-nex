import 'package:flutter/material.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';

/// Empty-state placeholder shown when a chart has no data for the
/// selected period.
///
/// Keep this widget intentionally minimal — the calling screen is
/// responsible for layout/padding around it.
class PfChartEmpty extends StatelessWidget {
  /// Default constructor.
  const PfChartEmpty({
    super.key,
    this.message,
    this.icon = Icons.bar_chart_outlined,
    this.height = 200,
  });

  /// Localized message; if null a generic fallback is used.
  final String? message;

  /// Leading icon.
  final IconData icon;

  /// Reserved height so layouts do not jump when data arrives.
  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurface.withValues(alpha: 0.45);
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 40, color: muted),
            const SizedBox(height: PfTokens.space2),
            Text(
              message ?? 'No data for this period',
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
