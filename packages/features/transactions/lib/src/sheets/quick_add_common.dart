import 'package:flutter/material.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';

import '../controllers/quick_add_controller.dart';
import '../providers.dart';

/// Shared body widget powering both expense and income quick-add sheets.
class QuickAddBody extends ConsumerWidget {
  /// Default ctor.
  const QuickAddBody({
    super.key,
    required this.title,
    required this.type,
    required this.onSaved,
  });

  /// Sheet title text (already localized).
  final String title;

  /// Transaction type controlling defaults & category list.
  final TransactionType type;

  /// Invoked after the transaction has been persisted.
  final ValueChanged<Transaction> onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final Currency currency = ref.watch(defaultCurrencyProvider);
    final QuickAddFormState form =
        ref.watch(quickAddControllerProvider(type));
    final QuickAddController ctrl =
        ref.read(quickAddControllerProvider(type).notifier);

    final AsyncValue<List<Account>> accounts =
        ref.watch(accountsStreamProvider);
    final AsyncValue<List<Category>> categories =
        ref.watch(categoriesStreamProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.commonClose,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _CategoryChips(
                categories: categories,
                selectedId: form.categoryId,
                type: type,
                onSelected: ctrl.setCategory,
              ),
              const SizedBox(height: 12),
              _AccountChips(
                accounts: accounts,
                selectedId: form.accountId,
                onSelected: ctrl.setAccount,
              ),
              const SizedBox(height: 16),
              FnxAmountInput(
                key: ValueKey<String>('quick-add-${type.code}-amount'),
                initialValue: form.amountMinor,
                currencySymbol: currency.symbol,
                doneLabel: l10n.commonSave,
                onChanged: ctrl.setAmount,
                onDone: (int value) async {
                  ctrl.setAmount(value);
                  if (!ref.read(quickAddControllerProvider(type)).isValid) {
                    context.showFnxSnack(
                      l10n.qaAmountRequired,
                      isError: true,
                    );
                    return;
                  }
                  try {
                    final Transaction tx = await ctrl.save();
                    final String amountText =
                        '${_majorString(value, currency)} ${currency.symbol}';
                    if (!context.mounted) {
                      return;
                    }
                    context.showFnxSnack(
                      type == TransactionType.expense
                          ? l10n.qaSavedExpense(amountText)
                          : l10n.qaSavedIncome(amountText),
                    );
                    onSaved(tx);
                  } on Object catch (_) {
                    if (!context.mounted) {
                      return;
                    }
                    context.showFnxSnack(
                      l10n.qaSaveErrorOffline,
                      isError: true,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _majorString(int minor, Currency currency) {
    final int scale = _pow10(currency.minorUnit);
    if (scale == 1) {
      return minor.toString();
    }
    final int whole = minor ~/ scale;
    final int frac = minor.remainder(scale).abs();
    final String fracStr = frac.toString().padLeft(currency.minorUnit, '0');
    return '$whole.$fracStr';
  }

  int _pow10(int n) {
    int r = 1;
    for (int i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.type,
    required this.onSelected,
  });

  final AsyncValue<List<Category>> categories;
  final Ulid? selectedId;
  final TransactionType type;
  final ValueChanged<Ulid> onSelected;

  CategoryType _matchType(TransactionType t) {
    switch (t) {
      case TransactionType.expense:
        return CategoryType.expense;
      case TransactionType.income:
        return CategoryType.income;
      case TransactionType.transfer:
        return CategoryType.transfer;
      case TransactionType.adjustment:
        return CategoryType.adjustment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return categories.when(
      data: (List<Category> all) {
        final CategoryType wanted = _matchType(type);
        final List<Category> visible = all
            .where((Category c) => c.type == wanted && !c.isArchived)
            .toList(growable: false);
        if (visible.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (BuildContext ctx, int i) {
              final Category c = visible[i];
              return FnxChip(
                label: c.name,
                selected: selectedId == c.id,
                onTap: () => onSelected(c.id),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AccountChips extends StatelessWidget {
  const _AccountChips({
    required this.accounts,
    required this.selectedId,
    required this.onSelected,
  });

  final AsyncValue<List<Account>> accounts;
  final Ulid? selectedId;
  final ValueChanged<Ulid> onSelected;

  @override
  Widget build(BuildContext context) {
    return accounts.when(
      data: (List<Account> all) {
        final List<Account> live = all
            .where((Account a) => !a.isArchived && a.deletedAt == null)
            .toList(growable: false);
        if (live.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: live.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (BuildContext ctx, int i) {
              final Account a = live[i];
              return FnxChip(
                label: a.name,
                selected: selectedId == a.id,
                onTap: () => onSelected(a.id),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
