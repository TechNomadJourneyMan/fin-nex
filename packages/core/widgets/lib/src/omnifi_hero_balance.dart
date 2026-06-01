// OmniFi OS — HeroBalance
//
// The single most important number on the canvas. See
// docs/DESIGN_SYSTEM_OMNIFI.md §2.2 for the full spec.

import 'package:flutter/material.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:intl/intl.dart';

/// Shared Hero tag used to fly the balance from the dashboard to the
/// transaction-details page (and back). Kept as a constant so test code and
/// the transactions feature can match it.
const String kPfBalanceHeroTag = 'pf-balance-hero';

/// Premium balance hero. Overline label, huge number, growth chip.
class HeroBalance extends StatelessWidget {
  /// Default constructor.
  const HeroBalance({
    super.key,
    required this.amount,
    this.label = 'TOTAL BALANCE',
    this.delta,
    this.period = 'this month',
    this.loading = false,
    this.onTap,
    this.heroTag = kPfBalanceHeroTag,
  });

  /// Money value to display.
  final Money amount;

  /// Overline label above the number (will be uppercased).
  final String label;

  /// Optional period delta (renders the growth chip).
  final Money? delta;

  /// Sub-text for the chip ("this month", "ytd", ...).
  final String period;

  /// Renders a shimmer placeholder when true.
  final bool loading;

  /// Optional drill-down handler.
  final VoidCallback? onTap;

  /// Hero tag used to morph the amount into the transaction-details header.
  /// Pass `null` to opt out of the Hero wrap (e.g. when two HeroBalances
  /// might appear on screen simultaneously during a transition).
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final NumberFormat money = NumberFormat.currency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: amount.currency.symbol,
      decimalDigits: 0,
    );
    final String formatted = money.format(amount.major.toDouble());

    final Widget overline = Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 4,
        color: Color(0xFF8A8A93),
      ),
    );

    final Widget hero = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.96, // ≈ -2 % at 48 px
        color: Color(0xFFF2F2F3),
        height: 1.05,
        fontFamilyFallback: <String>[
          'Satoshi',
          'SF Pro Display',
          '-apple-system',
          'BlinkMacSystemFont',
          'Inter',
        ],
      ),
      child: Text(loading ? '— — —' : formatted),
    );

    final Widget? chip = (delta != null && !delta!.isZero)
        ? _DeltaChip(delta: delta!, period: period, currency: amount.currency)
        : null;

    final String semanticsLabel = loading
        ? 'Balance loading'
        : 'Total balance: $formatted'
            '${delta != null ? ', delta ${money.format(delta!.major.toDouble())} $period' : ''}';

    Widget col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        overline,
        const SizedBox(height: 16),
        hero,
        if (chip != null) ...<Widget>[
          const SizedBox(height: 12),
          chip,
        ],
      ],
    );

    col = Semantics(label: semanticsLabel, container: true, child: col);

    Widget result;
    if (onTap != null) {
      result = InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: col,
      );
    } else {
      result = col;
    }

    // Wrap in a Hero so the dashboard balance morphs into the transaction
    // details amount header. Uses MaterialRectArcTween for the curved flight
    // path and a flightShuttleBuilder that preserves the source text style.
    if (heroTag != null) {
      result = Hero(
        tag: heroTag!,
        createRectTween: (Rect? begin, Rect? end) =>
            MaterialRectArcTween(begin: begin, end: end),
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          // Re-host the *source* subtree during the flight so the typography
          // and color do not snap mid-flight on either end.
          final BuildContext source = flightDirection == HeroFlightDirection.push
              ? fromHeroContext
              : toHeroContext;
          return DefaultTextStyle(
            style: DefaultTextStyle.of(source).style,
            child: Material(
              type: MaterialType.transparency,
              child: source.widget,
            ),
          );
        },
        child: Material(
          type: MaterialType.transparency,
          child: result,
        ),
      );
    }
    return result;
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({
    required this.delta,
    required this.period,
    required this.currency,
  });

  final Money delta;
  final String period;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final bool positive = !delta.isNegative;
    final Color tint = positive
        ? const Color(0xFF24A148)
        : const Color(0xFFFF453A);
    final Color subtleTint = positive
        ? const Color(0x2624A148)
        : const Color(0x26FF453A);
    final NumberFormat money = NumberFormat.currency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: currency.symbol,
      decimalDigits: 0,
    );
    final String absText =
        money.format(delta.abs().major.toDouble());

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: subtleTint,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: tint.withValues(alpha: 0.35), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                positive ? Icons.arrow_upward : Icons.arrow_downward,
                color: tint,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                absText,
                style: TextStyle(
                  color: tint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          period,
          style: const TextStyle(
            color: Color(0xFF8A8A93),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
