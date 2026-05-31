// Transaction list item for FinNex.

import 'package:flutter/material.dart';

import 'fnx_amount_format.dart';
import 'fnx_avatar.dart';
import 'fnx_theme_ext.dart';

/// FinNex transaction row.
class FnxTransactionItem extends StatelessWidget {
  /// Creates a transaction row.
  const FnxTransactionItem({
    super.key,
    required this.category,
    required this.amountMinor,
    required this.date,
    this.icon,
    this.categoryColor,
    this.description,
    this.onTap,
    this.onLongPress,
    this.locale = 'ru',
    this.pendingSync = false,
    this.currencySymbol = kFnxDefaultCurrencySymbol,
  });

  /// Category label (used as title).
  final String category;

  /// Signed minor-units amount (negative for expense, positive for income).
  final int amountMinor;

  /// Transaction date/time.
  final DateTime date;

  /// Category icon glyph.
  final IconData? icon;

  /// Category accent color.
  final Color? categoryColor;

  /// Optional description / note.
  final String? description;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Long-press callback.
  final VoidCallback? onLongPress;

  /// Locale tag for number formatting.
  final String locale;

  /// Whether the row is awaiting sync.
  final bool pendingSync;

  /// Currency symbol.
  final String currencySymbol;

  String _formatTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final accent = categoryColor ?? colors.brand;
    final income = amountMinor > 0;
    final amountColor = income ? colors.income : colors.textPrimary;
    final amountText = formatFnxSignedAmount(
      amountMinor,
      locale: locale,
      currencySymbol: currencySymbol,
    );

    return Semantics(
      button: onTap != null,
      label: '$category ${income ? 'income' : 'expense'} $amountText',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                FnxAvatar(icon: icon ?? Icons.category, color: accent, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category,
                              style: typo.bodyMd
                                  .copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (pendingSync)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          Text(amountText,
                              style: typo.amountMd
                                  .copyWith(color: amountColor)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              description ?? '',
                              style: typo.bodySm
                                  .copyWith(color: colors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(date),
                            style: typo.caption
                                .copyWith(color: colors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
