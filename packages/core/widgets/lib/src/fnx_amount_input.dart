// Custom amount input with on-screen number pad.

import 'package:flutter/material.dart';

import 'fnx_amount_format.dart';
import 'fnx_button.dart';
import 'fnx_theme_ext.dart';

/// Big amount input with custom number pad — web-compatible.
class FnxAmountInput extends StatefulWidget {
  /// Creates an amount input.
  const FnxAmountInput({
    super.key,
    this.initialValue = 0,
    this.onChanged,
    this.onDone,
    this.locale = 'ru',
    this.quickAmounts = const [10000, 50000, 100000],
    this.currencySymbol = kFnxDefaultCurrencySymbol,
    this.doneLabel = 'Done',
  });

  /// Initial value in minor units (or whole units depending on caller).
  final int initialValue;

  /// Called whenever the amount changes.
  final ValueChanged<int>? onChanged;

  /// Called when the user taps Done.
  final ValueChanged<int>? onDone;

  /// Locale tag for number formatting.
  final String locale;

  /// Quick-add chips (e.g. +100, +500, +1000).
  final List<int> quickAmounts;

  /// Currency symbol shown next to the amount.
  final String currencySymbol;

  /// Label for the done button.
  final String doneLabel;

  @override
  State<FnxAmountInput> createState() => _FnxAmountInputState();
}

class _FnxAmountInputState extends State<FnxAmountInput> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _setValue(int next) {
    setState(() => _value = next.clamp(0, 999999999999));
    widget.onChanged?.call(_value);
  }

  void _appendDigit(int digit) {
    final candidate = _value * 10 + digit;
    if (candidate > 999999999999) {
      return;
    }
    _setValue(candidate);
  }

  void _backspace() {
    _setValue(_value ~/ 10);
  }

  void _add(int delta) {
    _setValue(_value + delta);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final spacing = context.fnxSpacing;

    return Semantics(
      label: 'Amount input',
      value: formatFnxAmount(
        _value,
        locale: widget.locale,
        currencySymbol: widget.currencySymbol,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(spacing.s6),
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: BorderRadius.circular(context.fnxRadii.r4),
            ),
            child: Center(
              child: FittedBox(
                child: Text(
                  formatFnxAmount(
                    _value,
                    locale: widget.locale,
                    currencySymbol: widget.currencySymbol,
                  ),
                  style: typo.displayMd,
                ),
              ),
            ),
          ),
          SizedBox(height: spacing.s4),
          if (widget.quickAmounts.isNotEmpty)
            Wrap(
              spacing: spacing.s3,
              children: [
                for (final q in widget.quickAmounts)
                  ActionChip(
                    label: Text('+${formatFnxAmount(q, locale: widget.locale, currencySymbol: null)}'),
                    onPressed: () => _add(q),
                  ),
              ],
            ),
          SizedBox(height: spacing.s4),
          _Pad(
            onDigit: _appendDigit,
            onBackspace: _backspace,
          ),
          SizedBox(height: spacing.s4),
          FnxButton(
            label: widget.doneLabel,
            fullWidth: true,
            onPressed: () => widget.onDone?.call(_value),
          ),
        ],
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.onDigit, required this.onBackspace});

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final typo = context.fnxTypography;

    Widget keyButton(Widget child, VoidCallback onTap, {String? semantic}) {
      return Semantics(
        button: true,
        label: semantic,
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(context.fnxRadii.r3),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(context.fnxRadii.r3),
            child: SizedBox(
              height: 56,
              child: Center(child: child),
            ),
          ),
        ),
      );
    }

    final rows = <List<Widget>>[
      [
        for (final d in [1, 2, 3])
          keyButton(Text('$d', style: typo.heading2), () => onDigit(d),
              semantic: '$d'),
      ],
      [
        for (final d in [4, 5, 6])
          keyButton(Text('$d', style: typo.heading2), () => onDigit(d),
              semantic: '$d'),
      ],
      [
        for (final d in [7, 8, 9])
          keyButton(Text('$d', style: typo.heading2), () => onDigit(d),
              semantic: '$d'),
      ],
      [
        keyButton(Text('.', style: typo.heading2), () {}, semantic: 'decimal'),
        keyButton(Text('0', style: typo.heading2), () => onDigit(0),
            semantic: '0'),
        keyButton(Icon(Icons.backspace_outlined, color: colors.textPrimary),
            onBackspace,
            semantic: 'Backspace'),
      ],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.s3),
            child: Row(
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  Expanded(child: row[i]),
                  if (i < row.length - 1) SizedBox(width: spacing.s3),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
