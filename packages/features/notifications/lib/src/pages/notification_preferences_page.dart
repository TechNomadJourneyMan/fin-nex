import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

import '../models/notification_type.dart';
import '../providers.dart';

/// Granular per-type toggle page for notification preferences.
class NotificationPreferencesPage extends ConsumerWidget {
  /// Default constructor.
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(notificationPreferencesProvider);
    final controller = ref.read(notificationPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.notifTitle ?? 'Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: PfSpacing.x2),
        children: [
          for (final type in NotificationPreferenceType.values)
            _PreferenceTile(
              type: type,
              enabled: prefs.isEnabled(type),
              onChanged: (v) => controller.setEnabled(type, v),
              label: _labelFor(type, l10n),
              description: _descriptionFor(type, l10n),
            ),
        ],
      ),
    );
  }

  String _labelFor(NotificationPreferenceType type, AppLocalizations? l10n) {
    switch (type) {
      case NotificationPreferenceType.dailyReminder:
        return l10n?.notifDailyReminderTitle ?? 'Daily reminder';
      case NotificationPreferenceType.weeklyRecap:
        return l10n?.notifWeeklyRecapTitle ?? 'Weekly recap';
      case NotificationPreferenceType.monthlyReport:
        return 'Monthly report';
      case NotificationPreferenceType.limitWarning:
        return l10n?.notifLimitWarningTitle ?? 'Budget alert';
      case NotificationPreferenceType.insight:
        return l10n?.notifInsightReadyTitle ?? 'New insight';
      case NotificationPreferenceType.syncError:
        return 'Sync errors';
    }
  }

  String _descriptionFor(
    NotificationPreferenceType type,
    AppLocalizations? l10n,
  ) {
    switch (type) {
      case NotificationPreferenceType.dailyReminder:
        return l10n?.notifDailyReminderBody ?? "Takes 3 seconds. Tap to add.";
      case NotificationPreferenceType.weeklyRecap:
        return 'Summary of your week, every Monday.';
      case NotificationPreferenceType.monthlyReport:
        return 'A detailed look at the past month.';
      case NotificationPreferenceType.limitWarning:
        return 'Warn me when I approach a budget limit.';
      case NotificationPreferenceType.insight:
        return l10n?.notifInsightReadyBody ??
            'Open PocketFlow to see what changed.';
      case NotificationPreferenceType.syncError:
        return "Tell me when something can't sync.";
    }
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.type,
    required this.enabled,
    required this.onChanged,
    required this.label,
    required this.description,
  });

  final NotificationPreferenceType type;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PfSpacing.x4,
        vertical: PfSpacing.x2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: typo.bodyMd.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: typo.bodySm.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: PfSpacing.x3),
          Semantics(
            label: label,
            toggled: enabled,
            child: Switch.adaptive(
              value: enabled,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
