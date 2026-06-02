// "Calendar" settings section.
//
// A connect button that requests calendar permission, lists the available
// calendars, and persists the chosen calendar id under `pf_calendar_id`.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

import '../providers.dart';

/// Settings section for connecting a device / Google calendar.
class CalendarSection extends ConsumerWidget {
  /// Const ctor.
  const CalendarSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final state = ref.watch(calendarControllerProvider);
    final controller = ref.read(calendarControllerProvider.notifier);
    final FeedbackService feedback = ref.read(feedbackServiceProvider);

    final String status = state.connected
        ? (state.selected != null
            ? l10n.calSelected(state.selected!.name)
            : l10n.calConnected)
        : l10n.calNotConnected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.setCalendar,
            style: typo.bodySm.copyWith(
              color: colors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        ListTile(
          key: const Key('settings.calendar.status'),
          leading: Icon(Icons.event_outlined, color: colors.textSecondary),
          title: Text(l10n.calConnect),
          subtitle: Text(
            state.permissionDenied ? l10n.calPermissionDenied : status,
            style: typo.bodySm.copyWith(
              color: state.permissionDenied
                  ? colors.error
                  : (state.connected ? colors.success : colors.textMuted),
            ),
          ),
          trailing: state.busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  key: const Key('settings.calendar.connect'),
                  onPressed: () {
                    feedback.confirmAction();
                    // ignore: discarded_futures
                    controller.connect();
                  },
                  child: Text(l10n.calConnect),
                ),
        ),
        if (state.calendars.isNotEmpty) ...<Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(
              l10n.calChooseCalendar,
              style: typo.bodySm.copyWith(color: colors.textMuted),
            ),
          ),
          for (final cal in state.calendars)
            ListTile(
              key: Key('settings.calendar.option.${cal.id}'),
              enabled: cal.isWritable,
              leading: Icon(
                state.selectedId == cal.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: state.selectedId == cal.id
                    ? colors.brand
                    : colors.textMuted,
              ),
              title: Text(cal.name),
              subtitle: cal.accountName == null ? null : Text(cal.accountName!),
              onTap: cal.isWritable
                  ? () {
                      feedback.selectTap();
                      // ignore: discarded_futures
                      controller.select(cal.id);
                    }
                  : null,
            ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            l10n.calConnectDesc,
            style: typo.bodySm.copyWith(color: colors.textMuted),
          ),
        ),
        // Local payment push reminders. Independent of the calendar (the
        // calendar event is the shared/system surface; this is the in-app
        // nudge). Hidden on web where local notifications are a no-op.
        if (!kIsWeb)
          Builder(
            builder: (context) {
              final prefs = ref.watch(notificationPrefsProvider);
              final ctrl = ref.read(notificationPrefsProvider.notifier);
              return SwitchListTile(
                key: const Key('settings.calendar.paymentPush'),
                title: Text(l10n.notifPaymentPush),
                subtitle: Text(
                  l10n.notifPaymentPushDesc,
                  style: typo.bodySm.copyWith(color: colors.textMuted),
                ),
                value: prefs.paymentPush,
                onChanged: (v) {
                  feedback.selectTap();
                  // ignore: discarded_futures
                  ctrl.setPaymentPush(v);
                },
              );
            },
          ),
        // Reminder toggles — only meaningful once a calendar is connected.
        if (state.connected) ...<Widget>[
          Builder(
            builder: (context) {
              final prefs = ref.watch(reminderPrefsProvider);
              final ctrl = ref.read(reminderPrefsProvider.notifier);
              return Column(
                children: <Widget>[
                  SwitchListTile(
                    key: const Key('settings.calendar.subscriptionReminders'),
                    title: Text(l10n.calSubscriptionReminders),
                    subtitle: Text(
                      l10n.calSubscriptionRemindersDesc,
                      style: typo.bodySm.copyWith(color: colors.textMuted),
                    ),
                    value: prefs.subscriptions,
                    onChanged: (v) {
                      feedback.selectTap();
                      // ignore: discarded_futures
                      ctrl.setSubscriptions(v);
                    },
                  ),
                  SwitchListTile(
                    key: const Key('settings.calendar.budgetReminders'),
                    title: Text(l10n.calBudgetReminders),
                    subtitle: Text(
                      l10n.calBudgetRemindersDesc,
                      style: typo.bodySm.copyWith(color: colors.textMuted),
                    ),
                    value: prefs.budgets,
                    onChanged: (v) {
                      feedback.selectTap();
                      // ignore: discarded_futures
                      ctrl.setBudgets(v);
                    },
                  ),
                ],
              );
            },
          ),
        ],
        Divider(
          height: 1,
          color: colors.divider,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
