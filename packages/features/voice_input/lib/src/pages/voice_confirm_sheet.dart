// Bottom sheet presenting a parsed voice transaction for review.
//
// Shows editable sum, type, suggested category and account, plus an optional
// note. Save emits the (possibly edited) [VoiceTranscriptionResult] through the
// host-provided [onConfirm] callback; the host owns the actual persistence.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/domain.dart';

import '../services/voice_transcription_service.dart';

/// Shows the confirm sheet. Returns `true` if the user saved.
Future<bool?> showVoiceConfirmSheet({
  required BuildContext context,
  required VoiceTranscriptionResult initial,
  required ValueChanged<VoiceTranscriptionResult> onConfirm,
}) {
  return showPfBottomSheet<bool>(
    context: context,
    semanticLabel: 'Confirm voice transaction',
    builder: (ctx) => VoiceConfirmSheet(initial: initial, onConfirm: onConfirm),
  );
}

/// Editable review form for a parsed voice transaction.
class VoiceConfirmSheet extends StatefulWidget {
  /// Creates the confirm sheet body.
  const VoiceConfirmSheet({
    super.key,
    required this.initial,
    required this.onConfirm,
  });

  /// The parsed draft to seed the form.
  final VoiceTranscriptionResult initial;

  /// Emits the edited draft when the user taps Save.
  final ValueChanged<VoiceTranscriptionResult> onConfirm;

  @override
  State<VoiceConfirmSheet> createState() => _VoiceConfirmSheetState();
}

class _VoiceConfirmSheetState extends State<VoiceConfirmSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late TransactionType _type;
  late Currency _currency;

  @override
  void initState() {
    super.initState();
    final amount = widget.initial.amount;
    _currency = amount?.currency ?? Currency.kzt;
    _amountCtrl = TextEditingController(
      text: amount == null ? '' : amount.major.toString(),
    );
    _noteCtrl = TextEditingController(
      text: widget.initial.note ?? widget.initial.transcript,
    );
    _type = widget.initial.type ?? TransactionType.expense;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Money? _parseAmount() {
    final raw = _amountCtrl.text.trim();
    if (raw.isEmpty) {
      return null;
    }
    final dec = Decimal.tryParse(raw);
    if (dec == null) {
      return null;
    }
    return Money.fromMajor(dec, _currency);
  }

  void _save() {
    final result = widget.initial.copyWith(
      amount: _parseAmount(),
      type: _type,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    widget.onConfirm(result);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.fnxTypography;
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final canSave = _parseAmount() != null;

    return Padding(
      padding: EdgeInsets.only(
        left: spacing.s6,
        right: spacing.s6,
        bottom: MediaQuery.of(context).viewInsets.bottom + spacing.s6,
        top: spacing.s4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Review transaction', style: typo.heading2),
          SizedBox(height: spacing.s2),
          Text(
            widget.initial.transcript.isEmpty
                ? 'Confirm the details below.'
                : '"${widget.initial.transcript}"',
            style: typo.bodySm.copyWith(color: colors.textMuted),
          ),
          SizedBox(height: spacing.s6),
          PfTextField(
            label: 'Amount (${_currency.code})',
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: spacing.s5),
          PfSelect<TransactionType>(
            label: 'Type',
            value: _type,
            options: const <PfSelectOption<TransactionType>>[
              PfSelectOption(
                value: TransactionType.expense,
                label: 'Expense',
              ),
              PfSelectOption(value: TransactionType.income, label: 'Income'),
              PfSelectOption(
                value: TransactionType.transfer,
                label: 'Transfer',
              ),
            ],
            onChanged: (v) =>
                setState(() => _type = v ?? TransactionType.expense),
          ),
          SizedBox(height: spacing.s5),
          _SuggestionRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: widget.initial.suggestedCategoryLabel ?? 'Uncategorized',
          ),
          SizedBox(height: spacing.s4),
          _SuggestionRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Account',
            value: widget.initial.suggestedAccountLabel ?? 'Default account',
          ),
          SizedBox(height: spacing.s5),
          PfTextField(
            label: 'Note',
            controller: _noteCtrl,
            maxLines: 2,
          ),
          SizedBox(height: spacing.s6),
          PfButton(
            label: 'Save',
            fullWidth: true,
            onPressed: canSave ? _save : null,
          ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final spacing = context.fnxSpacing;

    return Row(
      children: [
        Icon(icon, size: 20, color: colors.textMuted),
        SizedBox(width: spacing.s3),
        Text(label, style: typo.bodyMd.copyWith(color: colors.textSecondary)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: typo.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
