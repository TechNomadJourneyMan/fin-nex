import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:intl/intl.dart';

import '../controllers/transactions_controller.dart';
import '../providers.dart';
import '../state/transaction_filter_state.dart';
import 'transaction_form_page.dart';

/// Read-only transaction detail page with Edit & Delete actions.
class TransactionDetailsPage extends ConsumerWidget {
  /// Default ctor.
  const TransactionDetailsPage({super.key, required this.transactionId});

  /// ULID of the transaction to display.
  final Ulid transactionId;

  Future<Transaction?> _load(WidgetRef ref) async {
    final TransactionsRepository repo =
        ref.read(transactionsRepositoryProvider);
    return repo.getById(transactionId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTransactions)),
      body: FutureBuilder<Transaction?>(
        future: _load(ref),
        builder: (BuildContext ctx, AsyncSnapshot<Transaction?> snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final Transaction? tx = snap.data;
          if (tx == null) {
            return Center(
              child: Text(l10n.txNotFound),
            );
          }
          return _DetailsBody(tx: tx);
        },
      ),
    );
  }
}

class _DetailsBody extends ConsumerWidget {
  const _DetailsBody({required this.tx});

  final Transaction tx;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        content: Text(l10n.txDeleteConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    final TransactionsController ctrl = ref.read(
      transactionsControllerProvider(const TransactionFilterState()).notifier,
    );
    await ctrl.softDelete(tx.id);
    if (!context.mounted) {
      return;
    }
    context.showPfSnack(
      l10n.txDeleted,
      duration: const Duration(seconds: 5),
      action: PfSnackAction(
        label: l10n.txUndo,
        onPressed: () {
          // Restore best-effort; ignore errors.
          // ignore: discarded_futures
          ctrl.restore(tx);
        },
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final Currency currency = tx.amount.currency;
    final NumberFormat money = NumberFormat.decimalPattern(l10n.localeName);
    final String amountText =
        '${money.format(tx.amount.major.toDouble())} ${currency.symbol}';
    final DateFormat dateFmt = DateFormat.yMMMd(l10n.localeName)
        .add_Hm();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            amountText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          _Row(label: l10n.txFieldDate, value: dateFmt.format(tx.occurredAt.toLocal())),
          _Row(label: l10n.txFieldNote, value: tx.description ?? '—'),
          _Row(label: l10n.txFieldCategory, value: tx.categoryId?.value ?? '—'),
          _Row(label: l10n.txFieldAccount, value: tx.accountId.value),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: PfButton(
                  label: l10n.commonEdit,
                  variant: PfButtonVariant.secondary,
                  onPressed: () {
                    Navigator.of(context).push<Transaction>(
                      MaterialPageRoute<Transaction>(
                        builder: (BuildContext _) =>
                            TransactionFormPage(initial: tx),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PfButton(
                  label: l10n.commonDelete,
                  variant: PfButtonVariant.destructive,
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
