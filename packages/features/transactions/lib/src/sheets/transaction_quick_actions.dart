import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';

import '../providers.dart';

/// Outcome the caller may surface to the user (e.g. a snackbar) after a quick
/// action completes.
enum QuickActionResult {
  /// A transaction was duplicated.
  duplicated,

  /// A transaction's category was changed.
  recategorized,

  /// A transaction was split into N parts.
  split,

  /// A transaction was deleted (caller already shows undo).
  deleted,
}

/// Shows the long-press quick-actions sheet for [tx].
///
/// Edit/Delete are wired through go_router and the controller so they mirror
/// the swipe gestures. Duplicate, Recategorize and Split mutate via the
/// repository directly. The [onDelete] callback lets the History page reuse its
/// existing soft-delete + undo snackbar flow.
Future<void> showTransactionQuickActions(
  BuildContext context,
  WidgetRef ref, {
  required Transaction tx,
  required Future<void> Function(Transaction tx) onDelete,
}) async {
  final AppL10n l10n = AppL10n.of(context);
  final FeedbackService feedback = ref.read(feedbackServiceProvider);
  feedback.longPress();

  await showPfBottomSheet<void>(
    context: context,
    semanticLabel: l10n.navTransactions,
    builder: (BuildContext sheetCtx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ActionTile(
              icon: Icons.edit_outlined,
              label: l10n.txEdit,
              onTap: () {
                Navigator.of(sheetCtx).pop();
                context.push('/transactions/${tx.id.value}/edit', extra: tx);
              },
            ),
            _ActionTile(
              icon: Icons.copy_outlined,
              label: l10n.txDuplicate,
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                await _duplicate(ref, tx);
              },
            ),
            _ActionTile(
              icon: Icons.category_outlined,
              label: l10n.txRecategorize,
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                await _recategorize(context, ref, tx);
              },
            ),
            _ActionTile(
              icon: Icons.call_split,
              label: l10n.txSplit,
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                await _split(context, ref, tx);
              },
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              label: l10n.commonDelete,
              destructive: true,
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                await onDelete(tx);
              },
            ),
          ],
        ),
      );
    },
  );
}

/// Persists a copy of [tx] with a fresh id, today's date, and the current
/// timestamps. Returns once the upsert resolves.
Future<void> _duplicate(WidgetRef ref, Transaction tx) async {
  final DateTime now = DateTime.now().toUtc();
  final Transaction copy = tx.copyWith(
    id: Ulid.now(),
    occurredAt: now,
    createdAt: now,
    updatedAt: now,
  );
  final TransactionsRepository repo = ref.read(transactionsRepositoryProvider);
  await repo.upsert(copy);
}

/// Opens a category multi-select-style picker (single pick here) and updates
/// [tx]'s category.
Future<void> _recategorize(
  BuildContext context,
  WidgetRef ref,
  Transaction tx,
) async {
  final List<Category> cats =
      ref.read(categoriesStreamProvider).valueOrNull ?? <Category>[];
  final Ulid? picked = await showPfBottomSheet<Ulid>(
    context: context,
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                AppL10n.of(ctx).txRecategorize,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final Category c
                      in cats.where((Category c) => !c.isArchived))
                    PfChip(
                      label: c.name,
                      selected: tx.categoryId?.value == c.id.value,
                      onTap: () => Navigator.of(ctx).pop(c.id),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  if (picked == null) {
    return;
  }
  final TransactionsRepository repo = ref.read(transactionsRepositoryProvider);
  await repo.upsert(
    tx.copyWith(categoryId: picked, updatedAt: DateTime.now().toUtc()),
  );
}

/// Prompts for a part count (default 2), divides [tx]'s amount evenly across N
/// new transactions, and persists them. The original is soft-deleted so the
/// ledger total is preserved. Any rounding remainder is added to the first
/// part so the parts sum back to the original.
Future<void> _split(
  BuildContext context,
  WidgetRef ref,
  Transaction tx,
) async {
  final int? parts = await showDialog<int>(
    context: context,
    builder: (BuildContext ctx) => _SplitDialog(),
  );
  if (parts == null || parts < 2) {
    return;
  }

  final BigInt total = tx.amount.minor;
  final BigInt n = BigInt.from(parts);
  final BigInt base = total ~/ n;
  final BigInt remainder = total - base * n;

  final TransactionsRepository repo = ref.read(transactionsRepositoryProvider);
  final DateTime now = DateTime.now().toUtc();
  for (int i = 0; i < parts; i++) {
    final BigInt amount = i == 0 ? base + remainder : base;
    await repo.upsert(
      tx.copyWith(
        id: Ulid.now(),
        amount: Money(amount, tx.amount.currency),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
  // Remove the original so totals are preserved.
  await repo.softDelete(tx.id);
}

/// Dialog asking for the number of parts to split a transaction into.
class _SplitDialog extends StatefulWidget {
  @override
  State<_SplitDialog> createState() => _SplitDialogState();
}

class _SplitDialogState extends State<_SplitDialog> {
  int _parts = 2;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    return AlertDialog(
      title: Text(l10n.txSplitTitle),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(l10n.txSplitParts),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _parts > 2 ? () => setState(() => _parts--) : null,
              ),
              Text('$_parts', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _parts < 20 ? () => setState(() => _parts++) : null,
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_parts),
          child: Text(l10n.txSplit),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final Color? color =
        destructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
