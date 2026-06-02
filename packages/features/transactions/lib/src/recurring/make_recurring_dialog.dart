// "Make recurring" dialog: choose cadence + interval + optional end date and
// an optional calendar-sync toggle, then create a RecurringRule from a
// template transaction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';

import 'recurring_calendar_sync.dart';
import 'recurring_providers.dart';

/// Localized label for a [RecurrenceCadence].
String cadenceLabel(AppL10n l10n, RecurrenceCadence c) {
  switch (c) {
    case RecurrenceCadence.daily:
      return l10n.recurCadenceDaily;
    case RecurrenceCadence.weekly:
      return l10n.recurCadenceWeekly;
    case RecurrenceCadence.biweekly:
      return l10n.recurCadenceBiweekly;
    case RecurrenceCadence.monthly:
      return l10n.recurCadenceMonthly;
    case RecurrenceCadence.yearly:
      return l10n.recurCadenceYearly;
  }
}

/// Shows the "Make recurring" dialog seeded from [template] and, on confirm,
/// creates a [RecurringRule] (optionally with calendar sync). Returns the new
/// rule, or null if cancelled.
Future<RecurringRule?> showMakeRecurringDialog(
  BuildContext context,
  WidgetRef ref, {
  required Transaction template,
  RecurringRule? existing,
}) async {
  final RecurringRule? result = await showDialog<RecurringRule>(
    context: context,
    builder: (BuildContext ctx) =>
        _MakeRecurringDialog(template: template, existing: existing),
  );
  if (result == null) {
    return null;
  }

  final RecurringRulesRepository repo =
      ref.read(recurringRulesRepositoryProvider);
  await repo.upsert(result);

  // Reconcile the calendar reminder per the toggle (calendarEventId non-null
  // is the opt-in flag; for a brand-new rule we pass wantsSync explicitly via
  // a sentinel stored on the rule by the dialog).
  final RecurringCalendarSync sync = ref.read(recurringCalendarSyncProvider);
  await sync.sync(result, wantsSync: result.calendarEventId == _kSyncSentinel);

  ref.read(feedbackServiceProvider).confirmAction();
  return result;
}

/// Sentinel stored transiently on `calendarEventId` to mean "the user asked
/// for calendar sync" before any real event id exists. The sync helper treats
/// any non-null value as opt-in and replaces it with the real id.
const String _kSyncSentinel = 'pending-sync';

class _MakeRecurringDialog extends ConsumerStatefulWidget {
  const _MakeRecurringDialog({required this.template, this.existing});

  final Transaction template;
  final RecurringRule? existing;

  @override
  ConsumerState<_MakeRecurringDialog> createState() =>
      _MakeRecurringDialogState();
}

class _MakeRecurringDialogState extends ConsumerState<_MakeRecurringDialog> {
  late RecurrenceCadence _cadence;
  late int _interval;
  DateTime? _endAt;
  late bool _calendarSync;

  @override
  void initState() {
    super.initState();
    final RecurringRule? e = widget.existing;
    _cadence = e?.cadence ?? RecurrenceCadence.monthly;
    _interval = e?.interval ?? 1;
    _endAt = e?.endAt;
    _calendarSync = e?.calendarEventId != null;
  }

  RecurringRule _build() {
    final DateTime now = DateTime.now().toUtc();
    final Transaction t = widget.template;
    final RecurringRule? e = widget.existing;
    // First occurrence: the template's date if in the future, else advance
    // from it so the engine doesn't immediately back-fill on creation.
    final DateTime first = e?.nextRunAt ?? t.occurredAt.toUtc();
    return RecurringRule(
      id: e?.id ?? Ulid.now(),
      userId: t.userId,
      accountId: t.accountId,
      type: t.type,
      amount: t.amount,
      categoryId: t.categoryId,
      description: t.description,
      cadence: _cadence,
      interval: _interval,
      nextRunAt: first,
      endAt: _endAt,
      paused: e?.paused ?? false,
      // Encode the sync intent: keep the real id when editing, else the
      // sentinel so the sync helper creates one; null when sync is off.
      calendarEventId: _calendarSync
          ? (e?.calendarEventId ?? _kSyncSentinel)
          : null,
      createdAt: e?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _pickEnd() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endAt ?? now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(
        () => _endAt = DateTime.utc(picked.year, picked.month, picked.day),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final MaterialLocalizations ml = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.existing == null ? l10n.recurMakeTitle : l10n.recurEditTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.recurCadenceLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final RecurrenceCadence c in RecurrenceCadence.values)
                  PfChip(
                    label: cadenceLabel(l10n, c),
                    selected: _cadence == c,
                    onTap: () => setState(() => _cadence = c),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(child: Text(l10n.recurEveryLabel)),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      _interval > 1 ? () => setState(() => _interval--) : null,
                ),
                Text(
                  '$_interval',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _interval < 99
                      ? () => setState(() => _interval++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.recurEndDateLabel),
              subtitle: Text(
                _endAt == null
                    ? l10n.recurNoEndDate
                    : ml.formatMediumDate(_endAt!),
              ),
              trailing: _endAt == null
                  ? TextButton(
                      onPressed: _pickEnd,
                      child: Text(l10n.recurSetEndDate),
                    )
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.commonClose,
                      onPressed: () => setState(() => _endAt = null),
                    ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.recurCalendarSync),
              subtitle: Text(l10n.recurCalendarSyncHint),
              value: _calendarSync,
              onChanged: (bool v) => setState(() => _calendarSync = v),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_build()),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
