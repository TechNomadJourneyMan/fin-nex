import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/domain.dart';

import '../controllers/notifications_controller.dart';
import '../providers.dart';

/// Notifications Center — list of received notifications grouped by date.
class NotificationsCenterPage extends ConsumerWidget {
  /// Default constructor.
  const NotificationsCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(notificationsControllerProvider);
    final colors = context.fnxColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.notifTitle ?? 'Notifications'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? Center(
                  child: PfEmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: l10n?.notifEmpty ?? 'All caught up',
                    body: '',
                  ),
                )
              : _NotificationsList(state: state, colors: colors),
    );
  }
}

class _NotificationsList extends ConsumerWidget {
  const _NotificationsList({
    required this.state,
    required this.colors,
  });

  final NotificationsState state;
  final PfSemanticColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = _groupByDate(state.items);
    final controller = ref.read(notificationsControllerProvider.notifier);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: PfSpacing.x2),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PfSpacing.x4,
                PfSpacing.x3,
                PfSpacing.x4,
                PfSpacing.x2,
              ),
              child: Text(
                group.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            for (final n in group.items)
              _NotificationTile(
                notification: n,
                onTap: () => controller.markRead(n.id),
                onLongPress: () => _confirmDelete(context, controller, n.id),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    NotificationsController controller,
    Ulid id,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (result == true) {
      await controller.dismiss(id);
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onLongPress,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final unread = notification.isUnread;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PfSpacing.x4,
          vertical: PfSpacing.x3,
        ),
        color: unread ? colors.brandSubtle.withValues(alpha: 0.5) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconFor(notification.kind),
              color: unread ? colors.brand : colors.textSecondary,
            ),
            const SizedBox(width: PfSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: typo.bodyMd.copyWith(
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: typo.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.brand,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.limitWarning:
      case NotificationKind.limitExceeded:
      case NotificationKind.budgetAlert:
        return Icons.warning_amber_rounded;
      case NotificationKind.recurringDue:
        return Icons.event_repeat;
      case NotificationKind.dailyReminder:
        return Icons.today;
      case NotificationKind.weeklySummary:
        return Icons.insights;
      case NotificationKind.insight:
        return Icons.auto_awesome;
      case NotificationKind.streak:
        return Icons.local_fire_department;
      case NotificationKind.referral:
        return Icons.card_giftcard;
      case NotificationKind.system:
      case NotificationKind.marketing:
        return Icons.notifications_none;
    }
  }
}

class _NotificationGroup {
  const _NotificationGroup(this.label, this.items);
  final String label;
  final List<AppNotification> items;
}

List<_NotificationGroup> _groupByDate(List<AppNotification> items) {
  if (items.isEmpty) {
    return const <_NotificationGroup>[];
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final earlier = <AppNotification>[];
  final yesterdays = <AppNotification>[];
  final todays = <AppNotification>[];

  for (final n in items) {
    final local = n.createdAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) {
      todays.add(n);
    } else if (day == yesterday) {
      yesterdays.add(n);
    } else {
      earlier.add(n);
    }
  }

  return [
    if (todays.isNotEmpty) _NotificationGroup('Today', todays),
    if (yesterdays.isNotEmpty) _NotificationGroup('Yesterday', yesterdays),
    if (earlier.isNotEmpty) _NotificationGroup('Earlier', earlier),
  ];
}
