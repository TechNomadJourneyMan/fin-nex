import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/domain.dart';

import '../providers.dart';

/// Insights feed — vertical list of [PfInsightCard]s.
class InsightsFeedPage extends ConsumerWidget {
  /// Default constructor.
  const InsightsFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(insightsControllerProvider);
    final controller = ref.read(insightsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.notifInsightReadyTitle ?? 'Insights'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.regenerate(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? const Center(
                  child: PfEmptyState(
                    icon: Icons.auto_awesome_outlined,
                    lottieAsset: 'assets/lottie/empty_insights.json',
                    title: 'No insights yet',
                    body:
                        'Log a few transactions and Pocket Flow will start finding patterns.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(PfSpacing.x4),
                  itemBuilder: (context, i) {
                    final insight = state.items[i];
                    return PfInsightCard(
                      title: insight.title,
                      body: insight.body,
                      icon: _iconFor(insight.severity),
                      onDismiss: () => controller.dismiss(insight),
                    );
                  },
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: PfSpacing.x3),
                  itemCount: state.items.length,
                ),
    );
  }

  IconData _iconFor(InsightSeverity s) {
    switch (s) {
      case InsightSeverity.warning:
        return Icons.warning_amber_rounded;
      case InsightSeverity.tip:
        return Icons.lightbulb_outline;
      case InsightSeverity.celebration:
        return Icons.celebration_outlined;
      case InsightSeverity.info:
        return Icons.auto_awesome;
    }
  }
}
