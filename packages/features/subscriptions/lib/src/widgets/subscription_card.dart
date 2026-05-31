// Reusable card for a single detected subscription.
//
// Shows the brand icon, merchant name, recurring amount, billing period and
// the next billing date. Tapping invokes [onTap] (used to open the detail).

import 'package:flutter/material.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:intl/intl.dart';

import '../domain/detected_subscription.dart';
import '../subscriptions_format.dart';
import 'brand_icon.dart';

/// A tappable card summarizing one [DetectedSubscription].
class SubscriptionCard extends StatelessWidget {
  /// Creates the card.
  const SubscriptionCard({
    required this.subscription,
    required this.locale,
    this.onTap,
    super.key,
  });

  /// The subscription rendered.
  final DetectedSubscription subscription;

  /// BCP-47 locale string used for number/date formatting.
  final String locale;

  /// Invoked when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final typography = context.fnxTypography;
    final radii = context.fnxRadii;

    final cancelled = subscription.cancelledAt != null;
    final dateLabel = DateFormat.MMMd(locale).format(
      subscription.nextBillingDate.toLocal(),
    );

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(radii.r4),
      child: InkWell(
        borderRadius: BorderRadius.circular(radii.r4),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(spacing.s5),
          child: Row(
            children: [
              BrandIcon(
                merchantName: subscription.merchantName,
                brandIconKey: subscription.brandIconKey,
              ),
              SizedBox(width: spacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subscription.merchantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.bodyLg.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (cancelled) ...[
                          SizedBox(width: spacing.s3),
                          _CancelledPill(label: l10n.subsCancelledBadge),
                        ],
                      ],
                    ),
                    SizedBox(height: spacing.s2),
                    Text(
                      '${billingPeriodLabel(l10n, subscription.period)}'
                      ' · ${l10n.subsNextBilling(dateLabel)}',
                      style: typography.bodySm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.s4),
              Text(
                formatFnxAmount(
                  subscription.amount.minor.toInt(),
                  locale: locale,
                  fractionDigits: 0,
                  currencySymbol: subscription.amount.currency.symbol,
                ),
                style: typography.amountSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small neutral pill marking a cancelled subscription.
class _CancelledPill extends StatelessWidget {
  const _CancelledPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typography = context.fnxTypography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(context.fnxRadii.full),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(color: colors.textMuted),
      ),
    );
  }
}
