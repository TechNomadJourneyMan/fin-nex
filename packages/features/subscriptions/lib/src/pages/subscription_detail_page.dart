// Subscription detail page.
//
// Shows the subscription header (name, amount, period), the list of source
// transactions the detector clustered, and two actions:
//   * "Mark as cancelled" — stamps `cancelledAt = now` via repo.upsert.
//   * "How to unsubscribe" — opens a localized hint sheet with the merchant
//     name and a placeholder link.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/domain.dart';
import 'package:intl/intl.dart';

import '../domain/detected_subscription.dart';
import '../providers.dart';
import '../subscriptions_format.dart';
import '../widgets/brand_icon.dart';

/// Loads a single subscription by id and renders its detail.
class SubscriptionDetailPage extends ConsumerWidget {
  /// Creates the page for [subscriptionId].
  const SubscriptionDetailPage({required this.subscriptionId, super.key});

  /// Id of the subscription to display.
  final Ulid subscriptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    // Re-read from the live stream so the page reflects cancellations made
    // here without an extra fetch.
    final async = ref.watch(detectedSubscriptionsStreamProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.subsDetailTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: TextStyle(color: colors.error)),
        ),
        data: (subs) {
          DetectedSubscription? sub;
          for (final s in subs) {
            if (s.id == subscriptionId) {
              sub = s;
              break;
            }
          }
          if (sub == null) {
            return Center(child: Text(l10n.subsNotFound));
          }
          return _DetailBody(subscription: sub);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.subscription});

  final DetectedSubscription subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final typography = context.fnxTypography;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final amountText = formatFnxAmount(
      subscription.amount.minor.toInt(),
      locale: locale,
      fractionDigits: 0,
      currencySymbol: subscription.amount.currency.symbol,
    );
    final cancelled = subscription.cancelledAt != null;

    return ListView(
      padding: EdgeInsets.all(spacing.s5),
      children: [
        // Header.
        Row(
          children: [
            BrandIcon(
              merchantName: subscription.merchantName,
              brandIconKey: subscription.brandIconKey,
              size: 56,
            ),
            SizedBox(width: spacing.s5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.merchantName,
                    style: typography.heading2,
                  ),
                  SizedBox(height: spacing.s2),
                  Text(
                    '$amountText · '
                    '${billingPeriodLabel(l10n, subscription.period)}',
                    style:
                        typography.bodyMd.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.s4),
        Text(
          l10n.subsNextBilling(
            DateFormat.yMMMMd(locale)
                .format(subscription.nextBillingDate.toLocal()),
          ),
          style: typography.bodySm.copyWith(color: colors.textSecondary),
        ),
        SizedBox(height: spacing.s7),

        // Source transactions.
        Text(l10n.subsSourceTransactions, style: typography.heading3),
        SizedBox(height: spacing.s4),
        if (subscription.sourceTransactionIds.isEmpty)
          Text(
            l10n.subsNoSourceTransactions,
            style: typography.bodySm.copyWith(color: colors.textMuted),
          )
        else
          ...subscription.sourceTransactionIds.map(
            (id) => FnxListItem(
              leading: Icon(
                Icons.receipt_long_outlined,
                color: colors.textSecondary,
              ),
              title: subscription.merchantName,
              subtitle: id.value,
              trailing: Text(amountText, style: typography.amountSm),
            ),
          ),
        SizedBox(height: spacing.s7),

        // Actions.
        FnxButton(
          label: l10n.subsHowToUnsubscribe,
          variant: FnxButtonVariant.secondary,
          fullWidth: true,
          leadingIcon: Icons.help_outline,
          onPressed: () => _showUnsubscribeSheet(context, subscription),
        ),
        SizedBox(height: spacing.s4),
        FnxButton(
          label: cancelled ? l10n.subsAlreadyCancelled : l10n.subsMarkCancelled,
          variant: FnxButtonVariant.destructive,
          fullWidth: true,
          leadingIcon: Icons.cancel_outlined,
          onPressed: cancelled
              ? null
              : () => _markCancelled(context, ref, subscription),
        ),
      ],
    );
  }

  Future<void> _markCancelled(
    BuildContext context,
    WidgetRef ref,
    DetectedSubscription sub,
  ) async {
    final l10n = AppL10n.of(context);
    final repo = ref.read(detectedSubscriptionsRepositoryProvider);
    final now = DateTime.now().toUtc();
    await repo.upsert(sub.copyWith(cancelledAt: now, updatedAt: now));
    if (context.mounted) {
      context.showFnxSnack(l10n.subsMarkedCancelled(sub.merchantName));
    }
  }

  void _showUnsubscribeSheet(
    BuildContext context,
    DetectedSubscription sub,
  ) {
    showFnxBottomSheet<void>(
      context: context,
      builder: (ctx) => _UnsubscribeHint(subscription: sub),
    );
  }
}

class _UnsubscribeHint extends StatelessWidget {
  const _UnsubscribeHint({required this.subscription});

  final DetectedSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final typography = context.fnxTypography;
    final link = subscription.unsubscribeUrl ?? l10n.subsUnsubscribeNoLink;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.s5,
        spacing.s4,
        spacing.s5,
        spacing.s6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.subsHowToUnsubscribe, style: typography.heading3),
          SizedBox(height: spacing.s4),
          Text(
            l10n.subsUnsubscribeHint(subscription.merchantName),
            style: typography.bodyMd.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.s5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.s4),
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: BorderRadius.circular(context.fnxRadii.r3),
            ),
            child: Row(
              children: [
                Icon(Icons.link, size: 18, color: colors.brand),
                SizedBox(width: spacing.s3),
                Expanded(
                  child: Text(
                    link,
                    style: typography.bodySm.copyWith(color: colors.brand),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.s5),
          FnxButton(
            label: l10n.commonOk,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
