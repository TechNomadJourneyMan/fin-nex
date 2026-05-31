// Subscriptions Manager — the main F-04 screen.
//
// Layout, top to bottom:
//   1. Horizontal calendar strip of upcoming charges this month.
//   2. A progress card with the total monthly spend on subscriptions.
//   3. A list of detected-subscription cards; tapping one opens the detail.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/domain.dart';
import 'package:intl/intl.dart';

import '../domain/detected_subscription.dart';
import '../providers.dart';
import '../widgets/subscription_card.dart';
import '../widgets/upcoming_calendar_strip.dart';
import 'subscription_detail_page.dart';

/// The subscriptions manager page.
class SubscriptionsManagerPage extends ConsumerWidget {
  /// Creates the page.
  const SubscriptionsManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final async = ref.watch(detectedSubscriptionsStreamProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.subsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: TextStyle(color: colors.error)),
        ),
        data: (subs) {
          final active =
              subs.where((s) => s.cancelledAt == null).toList(growable: false);
          if (subs.isEmpty) {
            return FnxEmptyState(
              icon: Icons.subscriptions_outlined,
              title: l10n.subsEmptyTitle,
              body: l10n.subsEmptyBody,
            );
          }
          return ListView(
            padding: EdgeInsets.symmetric(vertical: spacing.s5),
            children: [
              UpcomingCalendarStrip(subscriptions: active, locale: locale),
              SizedBox(height: spacing.s6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s5),
                child: _MonthlyTotalCard(active: active, locale: locale),
              ),
              SizedBox(height: spacing.s6),
              ...subs.map(
                (s) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.s5,
                    0,
                    spacing.s5,
                    spacing.s4,
                  ),
                  child: SubscriptionCard(
                    subscription: s,
                    locale: locale,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            SubscriptionDetailPage(subscriptionId: s.id),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Summary card: "Всего на подписки в <месяц>: X ₸".
class _MonthlyTotalCard extends StatelessWidget {
  const _MonthlyTotalCard({required this.active, required this.locale});

  final List<DetectedSubscription> active;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final typography = context.fnxTypography;

    final currency =
        active.isEmpty ? Currency.kzt : active.first.amount.currency;
    final totalMinor = active.fold<BigInt>(
      BigInt.zero,
      (sum, s) => sum + s.monthlyEquivalent.minor,
    );
    final monthName = toBeginningOfSentenceCase(
      DateFormat.MMMM(locale).format(DateTime.now()),
    );
    final amountText = formatFnxAmount(
      totalMinor.toInt(),
      locale: locale,
      fractionDigits: 0,
      currencySymbol: currency.symbol,
    );

    return Container(
      padding: EdgeInsets.all(spacing.s5),
      decoration: BoxDecoration(
        color: colors.brandSubtle,
        borderRadius: BorderRadius.circular(context.fnxRadii.r4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.subsMonthlyTotalLabel(monthName),
            style: typography.bodySm.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.s2),
          Text(amountText, style: typography.amountLg),
          SizedBox(height: spacing.s3),
          Text(
            l10n.subsActiveCount(active.length),
            style: typography.caption.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
