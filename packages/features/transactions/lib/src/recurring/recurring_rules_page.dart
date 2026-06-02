// Lists the current user's recurring rules with edit / pause / delete and a
// manual "run now" action. Reached via /transactions/recurring.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';

import 'make_recurring_dialog.dart';
import 'recurring_calendar_sync.dart';
import 'recurring_providers.dart';

/// Page listing active recurring rules.
class RecurringRulesPage extends ConsumerWidget {
  /// Default constructor.
  const RecurringRulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final AsyncValue<List<RecurringRule>> rulesAsync =
        ref.watch(recurringRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurPageTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: l10n.recurRunNow,
            onPressed: () => _runNow(context, ref),
          ),
        ],
      ),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text(l10n.commonRetry)),
        data: (List<RecurringRule> rules) {
          if (rules.isEmpty) {
            return _Empty(l10n: l10n);
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: rules.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext ctx, int i) => _RuleTile(rule: rules[i]),
          );
        },
      ),
    );
  }

  Future<void> _runNow(BuildContext context, WidgetRef ref) async {
    final AppL10n l10n = AppL10n.of(context);
    ref.read(feedbackServiceProvider).selectTap();
    final RecurringRunResult result = await runRecurringEngine(ref);
    if (!context.mounted) {
      return;
    }
    context.showPfSnack(
      result.created.isEmpty
          ? l10n.recurNoneDue
          : l10n.recurMaterialised(result.created.length),
    );
  }
}

class _RuleTile extends ConsumerWidget {
  const _RuleTile({required this.rule});

  final RecurringRule rule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    final String amount = formatPfAmount(
      rule.amount.minor.toInt(),
      fractionDigits: 0,
      currencySymbol: rule.amount.currency.symbol,
    );
    final String subtitle =
        '${_cadenceSummary(l10n)} · ${l10n.recurNextRun(ml.formatMediumDate(rule.nextRunAt.toLocal()))}';

    return ListTile(
      leading: Icon(
        rule.paused ? Icons.pause_circle_outline : Icons.repeat,
        color: rule.paused ? Theme.of(context).disabledColor : null,
      ),
      title: Text(
        (rule.description?.trim().isNotEmpty ?? false)
            ? rule.description!.trim()
            : amount,
      ),
      subtitle: Text(subtitle),
      trailing: PopupMenuButton<String>(
        onSelected: (String v) => _onAction(context, ref, v),
        itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(value: 'edit', child: Text(l10n.commonEdit)),
          PopupMenuItem<String>(
            value: 'pause',
            child: Text(rule.paused ? l10n.recurResume : l10n.recurPause),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  String _cadenceSummary(AppL10n l10n) {
    final String c = cadenceLabel(l10n, rule.cadence);
    return rule.interval <= 1 ? c : l10n.recurEvery(rule.interval, c);
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final RecurringRulesRepository repo =
        ref.read(recurringRulesRepositoryProvider);
    final RecurringCalendarSync sync = ref.read(recurringCalendarSyncProvider);
    final FeedbackService feedback = ref.read(feedbackServiceProvider);

    switch (action) {
      case 'edit':
        // Reconstruct a minimal template from the rule to seed the editor.
        final Transaction template = _templateFrom(rule);
        await showMakeRecurringDialog(
          context,
          ref,
          template: template,
          existing: rule,
        );
      case 'pause':
        feedback.selectTap();
        final RecurringRule updated = rule.copyWith(
          paused: !rule.paused,
          updatedAt: DateTime.now().toUtc(),
        );
        await repo.upsert(updated);
        // Pausing removes the calendar reminder; resuming re-creates it.
        await sync.sync(updated, wantsSync: updated.calendarEventId != null);
      case 'delete':
        feedback.warn();
        await sync.remove(rule);
        await repo.delete(rule.id);
    }
  }

  Transaction _templateFrom(RecurringRule r) {
    final DateTime now = DateTime.now().toUtc();
    return Transaction(
      id: Ulid.now(),
      userId: r.userId,
      accountId: r.accountId,
      type: r.type,
      amount: r.amount,
      categoryId: r.categoryId,
      occurredAt: r.nextRunAt,
      description: r.description,
      source: r.source,
      attachmentIds: const <Ulid>[],
      tagIds: const <Ulid>[],
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l10n});

  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.repeat, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.recurEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.recurEmptyBody,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
