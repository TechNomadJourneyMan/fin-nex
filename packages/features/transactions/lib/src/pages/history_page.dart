import 'package:flutter/material.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:intl/intl.dart';

import '../controllers/transactions_controller.dart';
import '../providers.dart';
import '../sheets/quick_add_expense_sheet.dart';
import '../state/transaction_filter_state.dart';
import 'transaction_details_page.dart';

/// History list page with sticky date sections, search, filters, and FAB.
class HistoryPage extends ConsumerStatefulWidget {
  /// Default ctor.
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  TransactionFilterState _filter = const TransactionFilterState();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final TransactionFilterState? next = await showFnxBottomSheet<TransactionFilterState>(
      context: context,
      builder: (BuildContext ctx) => _FilterSheet(initial: _filter),
    );
    if (next != null) {
      setState(() => _filter = next);
    }
  }

  Future<void> _refresh() async {
    // Trigger a rebuild of the family; AsyncNotifier re-runs build().
    ref.invalidate(transactionsControllerProvider(_filter));
    await ref.read(transactionsControllerProvider(_filter).future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final AsyncValue<List<Transaction>> async =
        ref.watch(transactionsControllerProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTransactions),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.commonOptional,
            onPressed: _openFilters,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: FnxTextField(
              controller: _searchCtrl,
              hint: l10n.commonSearch,
              prefixIcon: Icons.search,
              onChanged: (String v) {
                setState(() {
                  _filter = _filter.copyWith(
                    searchText: v.trim().isEmpty ? null : v,
                    clearSearch: v.trim().isEmpty,
                  );
                });
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showQuickAddExpenseSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.dashFab),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: async.when(
          data: (List<Transaction> txs) {
            if (txs.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  const SizedBox(height: 80),
                  FnxEmptyState(
                    title: l10n.dashEmptyTitle,
                    body: l10n.qaNotePlaceholder,
                    icon: Icons.receipt_long_outlined,
                    ctaLabel: l10n.dashEmptyCta,
                    onCta: () => showQuickAddExpenseSheet(context),
                  ),
                ],
              );
            }
            return _SectionedList(
              transactions: txs,
              locale: l10n.localeName,
              onTap: (Transaction t) {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) =>
                        TransactionDetailsPage(transactionId: t.id),
                  ),
                );
              },
              onSwipeDelete: (Transaction t) async {
                final TransactionsController ctrl = ref.read(
                  transactionsControllerProvider(_filter).notifier,
                );
                await ctrl.softDelete(t.id);
                if (!context.mounted) {
                  return;
                }
                context.showFnxSnack(
                  l10n.txDeleted,
                  duration: const Duration(seconds: 5),
                  action: FnxSnackAction(
                    label: l10n.txUndo,
                    onPressed: () {
                      // ignore: discarded_futures
                      ctrl.restore(t);
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.errorUnknown),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionedList extends StatelessWidget {
  const _SectionedList({
    required this.transactions,
    required this.locale,
    required this.onTap,
    required this.onSwipeDelete,
  });

  final List<Transaction> transactions;
  final String locale;
  final ValueChanged<Transaction> onTap;
  final ValueChanged<Transaction> onSwipeDelete;

  List<_Section> _group() {
    final Map<String, List<Transaction>> bucket =
        <String, List<Transaction>>{};
    final DateFormat keyFmt = DateFormat('yyyy-MM-dd');
    for (final Transaction t in transactions) {
      final DateTime local = t.occurredAt.toLocal();
      final String key = keyFmt.format(local);
      bucket.putIfAbsent(key, () => <Transaction>[]).add(t);
    }
    final List<String> keys = bucket.keys.toList(growable: false)
      ..sort((String a, String b) => b.compareTo(a));
    return <_Section>[
      for (final String k in keys)
        _Section(
          date: DateTime.parse(k),
          items: bucket[k]!,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<_Section> sections = _group();
    final DateFormat headerFmt = DateFormat.yMMMMEEEEd(locale);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        for (final _Section sec in sections)
          SliverMainAxisGroup(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeaderDelegate(
                  text: headerFmt.format(sec.date),
                ),
              ),
              SliverList.builder(
                itemCount: sec.items.length,
                itemBuilder: (BuildContext ctx, int i) {
                  final Transaction t = sec.items[i];
                  final int signed = t.type == TransactionType.expense
                      ? -t.amount.minor.toInt()
                      : t.amount.minor.toInt();
                  return Dismissible(
                    key: ValueKey<String>('tx-${t.id.value}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Theme.of(ctx).colorScheme.error,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => onSwipeDelete(t),
                    child: FnxTransactionItem(
                      category: t.categoryId?.value ?? '—',
                      amountMinor: signed,
                      date: t.occurredAt.toLocal(),
                      description: t.description,
                      currencySymbol: t.amount.currency.symbol,
                      locale: locale,
                      onTap: () => onTap(t),
                    ),
                  );
                },
              ),
            ],
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _Section {
  const _Section({required this.date, required this.items});
  final DateTime date;
  final List<Transaction> items;
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({required this.text});
  final String text;

  @override
  double get minExtent => 36;

  @override
  double get maxExtent => 36;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) =>
      oldDelegate.text != text;
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initial});
  final TransactionFilterState initial;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late TransactionFilterState _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
  }

  void _toggleType(TransactionType t) {
    final List<TransactionType> next = List<TransactionType>.of(_draft.types);
    if (next.contains(t)) {
      next.remove(t);
    } else {
      next.add(t);
    }
    setState(() => _draft = _draft.copyWith(types: next));
  }

  void _toggleCategory(Ulid id) {
    final List<Ulid> next = List<Ulid>.of(_draft.categoryIds);
    if (next.any((Ulid u) => u.value == id.value)) {
      next.removeWhere((Ulid u) => u.value == id.value);
    } else {
      next.add(id);
    }
    setState(() => _draft = _draft.copyWith(categoryIds: next));
  }

  void _toggleAccount(Ulid id) {
    final List<Ulid> next = List<Ulid>.of(_draft.accountIds);
    if (next.any((Ulid u) => u.value == id.value)) {
      next.removeWhere((Ulid u) => u.value == id.value);
    } else {
      next.add(id);
    }
    setState(() => _draft = _draft.copyWith(accountIds: next));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final List<Category> cats =
        ref.watch(categoriesStreamProvider).valueOrNull ?? <Category>[];
    final List<Account> accs =
        ref.watch(accountsStreamProvider).valueOrNull ?? <Account>[];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.commonAll,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final TransactionType t in <TransactionType>[
                TransactionType.expense,
                TransactionType.income,
                TransactionType.transfer,
              ])
                FnxChip(
                  label: t.code,
                  selected: _draft.types.contains(t),
                  onTap: () => _toggleType(t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.txFieldCategory),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final Category c in cats.where(
                (Category c) => !c.isArchived,
              ))
                FnxChip(
                  label: c.name,
                  selected: _draft.categoryIds
                      .any((Ulid u) => u.value == c.id.value),
                  onTap: () => _toggleCategory(c.id),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.txFieldAccount),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final Account a in accs.where(
                (Account a) => !a.isArchived && a.deletedAt == null,
              ))
                FnxChip(
                  label: a.name,
                  selected: _draft.accountIds
                      .any((Ulid u) => u.value == a.id.value),
                  onTap: () => _toggleAccount(a.id),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: FnxButton(
                  label: l10n.commonNone,
                  variant: FnxButtonVariant.secondary,
                  onPressed: () => Navigator.of(context)
                      .pop(const TransactionFilterState()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FnxButton(
                  label: l10n.commonDone,
                  onPressed: () => Navigator.of(context).pop(_draft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
