// Budget progress bar for FinNex.

import 'package:flutter/material.dart';

import 'fnx_amount_format.dart';
import 'fnx_theme_ext.dart';

/// FinNex budget progress bar with threshold colors.
class FnxBudgetProgress extends StatelessWidget {
  /// Creates a budget progress bar.
  const FnxBudgetProgress({
    super.key,
    required this.label,
    required this.spentMinor,
    required this.limitMinor,
    this.locale = 'ru',
    this.currencySymbol = kFnxDefaultCurrencySymbol,
  });

  /// Label (e.g. "Cafe").
  final String label;

  /// Spent amount in minor units.
  final int spentMinor;

  /// Limit amount in minor units.
  final int limitMinor;

  /// Locale tag.
  final String locale;

  /// Currency symbol.
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final ratio = limitMinor <= 0 ? 0.0 : spentMinor / limitMinor;
    final clamped = ratio.clamp(0.0, 1.0).toDouble();

    Color fill;
    if (ratio >= 1.0) {
      fill = colors.error;
    } else if (ratio >= 0.8) {
      fill = colors.warning;
    } else if (ratio >= 0.5) {
      fill = colors.brand;
    } else {
      fill = colors.brand;
    }

    final spentLabel = formatFnxAmount(spentMinor,
        locale: locale, currencySymbol: null);
    final limitLabel = formatFnxAmount(limitMinor,
        locale: locale, currencySymbol: currencySymbol);
    final pct = (ratio * 100).round();

    return Semantics(
      label: label,
      value: '$spentLabel of $limitLabel ($pct%)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: typo.bodyMd
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
              Text(
                '$spentLabel / $limitLabel',
                style: typo.amountSm.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.fnxRadii.full),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 8,
              backgroundColor: colors.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(fill),
            ),
          ),
        ],
      ),
    );
  }
}
