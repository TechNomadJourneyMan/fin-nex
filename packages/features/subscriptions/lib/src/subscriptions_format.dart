// Shared formatting helpers for the subscriptions feature.

import 'package:fnx_core_l10n/fnx_core_l10n.dart';

import 'domain/detected_subscription.dart';

/// Localized label for a [BillingPeriod] (e.g. "Monthly" / "Ежемесячно").
String billingPeriodLabel(AppL10n l10n, BillingPeriod period) =>
    switch (period) {
      BillingPeriod.weekly => l10n.subsPeriodWeekly,
      BillingPeriod.monthly => l10n.subsPeriodMonthly,
      BillingPeriod.quarterly => l10n.subsPeriodQuarterly,
      BillingPeriod.yearly => l10n.subsPeriodYearly,
    };
