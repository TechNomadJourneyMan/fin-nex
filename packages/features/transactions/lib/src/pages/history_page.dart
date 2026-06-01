import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers.dart';
import '../sheets/quick_add_expense_sheet.dart';
import '../sheets/transaction_quick_actions.dart';
import '../state/transaction_filter_state.dart';
import '../state/transaction_filters_notifier.dart';
import 'transaction_details_page.dart';

/// History list page with a large search-bar app bar, horizontally-scrollable
/// filter chips, sticky date sections, swipe gestures, and long-press quick
/// actions.
///
/// No in-page Add FAB: the Dynamic Island's "+" owns the "new transaction"
/// action app-wide. The empty-state inline CTA remains as a separate entry.
class HistoryPage extends ConsumerStatefulWidget {
  /// Default ctor.
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  int _lastFocusRequest = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(transactionsStreamProvider);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _onDelete(Transaction t) async {
    final AppL10n l10n = AppL10n.of(context);
    final TransactionsRepository repo =
        ref.read(transactionsRepositoryProvider);
    final FeedbackService feedback = ref.read(feedbackServiceProvider);
    feedback.confirmAction();
    await repo.softDelete(t.id);
    if (!mounted) {
      return;
    }
    bool undone = false;
    context.showPfSnack(
      l10n.txDeleted,
      duration: const Duration(seconds: 5),
      action: PfSnackAction(
        label: l10n.txUndo,
        onPressed: () {
          undone = true;
          // ignore: discarded_futures
          _restore(t);
        },
      ),
    );
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (!undone) {
        feedback.error();
      }
    });
  }

  Future<void> _restore(Transaction t) async {
    final TransactionsRepository repo =
        ref.read(transactionsRepositoryProvider);
    // Reconstruct without deletedAt (copyWith can't null it back out).
    await repo.upsert(
      Transaction(
        id: t.id,
        userId: t.userId,
        accountId: t.accountId,
        type: t.type,
        amount: t.amount,
        occurredAt: t.occurredAt,
        createdAt: t.createdAt,
        updatedAt: DateTime.now().toUtc(),
        source: t.source,
        attachmentIds: t.attachmentIds,
        tagIds: t.tagIds,
        categoryId: t.categoryId,
        description: t.description,
        transferAccountId: t.transferAccountId,
        transferGroupId: t.transferGroupId,
        recurringRuleId: t.recurringRuleId,
        externalRef: t.externalRef,
        lat: t.lat,
        lng: t.lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    // Honor focus requests coming from the command palette.
    final int focusRequest = ref.watch(searchFocusRequestProvider);
    if (focusRequest != _lastFocusRequest) {
      _lastFocusRequest = focusRequest;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocus.requestFocus();
        }
      });
    }

    final TransactionFilterState filter =
        ref.watch(transactionFiltersProvider);
    final AsyncValue<List<Transaction>> async =
        ref.watch(filteredTransactionsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar.large(
              pinned: true,
              title: Text(l10n.navTransactions),
              flexibleSpace: _SearchFlexibleSpace(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (String v) => ref
                    .read(transactionFiltersProvider.notifier)
                    .setQuery(v),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: _FilterChipsRow(filter: filter),
              ),
            ),
            ...async.when(
              data: (List<Transaction> txs) {
                if (txs.isEmpty) {
                  return <Widget>[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: filter.isEmpty
                          ? PfEmptyState(
                              title: l10n.dashEmptyTitle,
                              body: l10n.qaNotePlaceholder,
                              icon: Icons.receipt_long_outlined,
                              lottieAsset:
                                  'assets/lottie/empty_transactions.json',
                              ctaLabel: l10n.dashEmptyCta,
                              onCta: () => showQuickAddExpenseSheet(context),
                            )
                          : PfEmptyState(
                              title: l10n.filterNothingMatches,
                              body: l10n.filterNothingMatchesBody,
                              icon: Icons.search_off_outlined,
                              ctaLabel: l10n.filterClear,
                              onCta: () {
                                _searchCtrl.clear();
                                ref
                                    .read(transactionFiltersProvider.notifier)
                                    .clear();
                              },
                            ),
                    ),
                  ];
                }
                return <Widget>[
                  _SectionedListSliver(
                    transactions: txs,
                    locale: l10n.localeName,
                    onTap: (Transaction t) {
                      ref.read(feedbackServiceProvider).selectTap();
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext _) =>
                              TransactionDetailsPage(transactionId: t.id),
                        ),
                      );
                    },
                    onLongPress: (Transaction t) {
                      // ignore: discarded_futures
                      showTransactionQuickActions(
                        context,
                        ref,
                        tx: t,
                        onDelete: _onDelete,
                      );
                    },
                    onSwipeEdit: (Transaction t) {
                      context.push(
                        '/transactions/${t.id.value}/edit',
                        extra: t,
                      );
                    },
                    onSwipeDelete: _onDelete,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ];
              },
              loading: () => <Widget>[
                const SliverToBoxAdapter(child: _HistorySkeleton()),
              ],
              error: (Object e, _) => <Widget>[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.errorUnknown),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Search field rendered inside the [SliverAppBar.large]'s flexible space.
class _SearchFlexibleSpace extends StatelessWidget {
  const _SearchFlexibleSpace({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    return FlexibleSpaceBar(
      background: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
            child: PfTextField(
              controller: controller,
              focusNode: focusNode,
              hint: l10n.commonSearch,
              prefixIcon: Icons.search,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally-scrollable row of filter chips below the search field.
class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow({required this.filter});

  final TransactionFilterState filter;

  TransactionType? get _activeKind =>
      filter.types.length == 1 ? filter.types.first : null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n.of(context);
    final TransactionFiltersNotifier notifier =
        ref.read(transactionFiltersProvider.notifier);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: <Widget>[
          PfChip(
            label: l10n.commonAll,
            selected: _activeKind == null,
            onTap: () => notifier.setKind(null),
          ),
          const SizedBox(width: 8),
          PfChip(
            label: l10n.filterIncome,
            selected: _activeKind == TransactionType.income,
            onTap: () => notifier.setKind(
              _activeKind == TransactionType.income
                  ? null
                  : TransactionType.income,
            ),
          ),
          const SizedBox(width: 8),
          PfChip(
            label: l10n.filterExpense,
            selected: _activeKind == TransactionType.expense,
            onTap: () => notifier.setKind(
              _activeKind == TransactionType.expense
                  ? null
                  : TransactionType.expense,
            ),
          ),
          const SizedBox(width: 8),
          PfChip(
            label: l10n.filterCategory,
            icon: Icons.category_outlined,
            selected: filter.categoryIds.isNotEmpty,
            onTap: () => _openCategorySheet(context, ref),
          ),
          const SizedBox(width: 8),
          PfChip(
            label: l10n.filterDateRange,
            icon: Icons.date_range_outlined,
            selected: filter.from != null || filter.to != null,
            onTap: () => _openDateRange(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _openCategorySheet(BuildContext context, WidgetRef ref) async {
    final List<Category> cats =
        ref.read(categoriesStreamProvider).valueOrNull ?? <Category>[];
    final Set<Ulid>? result = await showPfBottomSheet<Set<Ulid>>(
      context: context,
      builder: (BuildContext ctx) => _CategoryMultiSelectSheet(
        categories: cats.where((Category c) => !c.isArchived).toList(),
        initial: filter.categoryIds.toSet(),
      ),
    );
    if (result != null) {
      ref.read(transactionFiltersProvider.notifier).setCategoryIds(result);
    }
  }

  Future<void> _openDateRange(BuildContext context, WidgetRef ref) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: filter.from != null && filter.to != null
          ? DateTimeRange(start: filter.from!, end: filter.to!)
          : null,
    );
    if (range != null) {
      ref.read(transactionFiltersProvider.notifier).setDateRange(
            from: range.start,
            // make the upper bound inclusive of the end day
            to: range.end.add(const Duration(days: 1)),
          );
    }
  }
}

/// Multi-select category picker returned as a [Set] of [Ulid] on confirm.
class _CategoryMultiSelectSheet extends StatefulWidget {
  const _CategoryMultiSelectSheet({
    required this.categories,
    required this.initial,
  });

  final List<Category> categories;
  final Set<Ulid> initial;

  @override
  State<_CategoryMultiSelectSheet> createState() =>
      _CategoryMultiSelectSheetState();
}

class _CategoryMultiSelectSheetState extends State<_CategoryMultiSelectSheet> {
  late final Set<String> _selected =
      widget.initial.map((Ulid u) => u.value).toSet();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.filterCategory,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final Category c in widget.categories)
                  PfChip(
                    label: c.name,
                    selected: _selected.contains(c.id.value),
                    onTap: () => setState(() {
                      if (_selected.contains(c.id.value)) {
                        _selected.remove(c.id.value);
                      } else {
                        _selected.add(c.id.value);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: PfButton(
                    label: l10n.commonNone,
                    variant: PfButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(<Ulid>{}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PfButton(
                    label: l10n.commonDone,
                    onPressed: () => Navigator.of(context).pop(
                      widget.categories
                          .where(
                            (Category c) => _selected.contains(c.id.value),
                          )
                          .map((Category c) => c.id)
                          .toSet(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder shown while the transaction list loads.
class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      children: <Widget>[
        for (int section = 0; section < 3; section++) ...<Widget>[
          const PfSkeleton(
            shape: PfSkeletonShape.text,
            width: 120,
            height: 14,
          ),
          const SizedBox(height: 16),
          for (int row = 0; row < 3; row++) ...<Widget>[
            const Row(
              children: <Widget>[
                PfSkeletonCircle(size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: PfSkeletonText(lines: 2, lineHeight: 12),
                ),
                SizedBox(width: 12),
                PfSkeleton(
                  shape: PfSkeletonShape.text,
                  width: 64,
                  height: 14,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ],
      ],
    );
  }
}

/// Brand-blue tint used behind a swipe-right (edit) action.
const Color _kSwipeEditColor = Color(0xFF2E48E6);

/// Error-red tint used behind a swipe-left (delete) action.
const Color _kSwipeDeleteColor = Color(0xFFFF453A);

/// Date-sectioned, animated transaction list rendered as a single sliver group
/// so it composes inside the History page's [CustomScrollView].
class _SectionedListSliver extends StatefulWidget {
  const _SectionedListSliver({
    required this.transactions,
    required this.locale,
    required this.onTap,
    required this.onLongPress,
    required this.onSwipeEdit,
    required this.onSwipeDelete,
  });

  final List<Transaction> transactions;
  final String locale;
  final ValueChanged<Transaction> onTap;
  final ValueChanged<Transaction> onLongPress;
  final ValueChanged<Transaction> onSwipeEdit;
  final Future<void> Function(Transaction) onSwipeDelete;

  @override
  State<_SectionedListSliver> createState() => _SectionedListSliverState();
}

class _SectionedListSliverState extends State<_SectionedListSliver> {
  final Map<String, GlobalKey<SliverAnimatedListState>> _listKeys =
      <String, GlobalKey<SliverAnimatedListState>>{};
  final Map<String, List<Transaction>> _current = <String, List<Transaction>>{};
  List<String> _sectionOrder = <String>[];

  static final DateFormat _keyFmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void didUpdateWidget(covariant _SectionedListSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reconcile();
  }

  void _seed() {
    _current.clear();
    final Map<String, List<Transaction>> grouped = _group(widget.transactions);
    _sectionOrder = grouped.keys.toList(growable: false);
    grouped.forEach((String key, List<Transaction> items) {
      _current[key] = items;
      _listKeys.putIfAbsent(key, () => GlobalKey<SliverAnimatedListState>());
    });
  }

  void _reconcile() {
    final Map<String, List<Transaction>> grouped = _group(widget.transactions);
    _sectionOrder = grouped.keys.toList(growable: false);

    final Set<String> nextSectionSet = grouped.keys.toSet();
    _current.keys
        .where((String k) => !nextSectionSet.contains(k))
        .toList(growable: false)
        .forEach(_current.remove);

    for (final String section in _sectionOrder) {
      final List<Transaction> next = grouped[section]!;
      final List<Transaction> prev = _current[section] ?? <Transaction>[];
      final GlobalKey<SliverAnimatedListState> key = _listKeys.putIfAbsent(
        section,
        () => GlobalKey<SliverAnimatedListState>(),
      );
      final SliverAnimatedListState? listState = key.currentState;
      if (listState == null) {
        _current[section] = next;
        continue;
      }
      _applyDiff(listState, prev, next, section);
      _current[section] = next;
    }
  }

  void _applyDiff(
    SliverAnimatedListState state,
    List<Transaction> prev,
    List<Transaction> next,
    String section,
  ) {
    final Map<String, int> prevIndex = <String, int>{};
    for (int i = 0; i < prev.length; i++) {
      prevIndex[prev[i].id.value] = i;
    }
    final Set<String> nextIds = next.map((Transaction t) => t.id.value).toSet();

    final List<int> removeAt = <int>[];
    for (int i = 0; i < prev.length; i++) {
      if (!nextIds.contains(prev[i].id.value)) removeAt.add(i);
    }
    removeAt.sort((int a, int b) => b.compareTo(a));
    for (final int idx in removeAt) {
      final Transaction removed = prev[idx];
      state.removeItem(
        idx,
        (BuildContext ctx, Animation<double> anim) => SizeTransition(
          sizeFactor: anim,
          child: FadeTransition(
            opacity: anim,
            child: _txRowDummy(removed),
          ),
        ),
        duration: PfMotion.effective(context, PfMotion.fast),
      );
    }

    for (int i = 0; i < next.length; i++) {
      if (!prevIndex.containsKey(next[i].id.value)) {
        state.insertItem(
          i,
          duration: PfMotion.effective(context, PfMotion.fast),
        );
      }
    }
  }

  Map<String, List<Transaction>> _group(List<Transaction> all) {
    final Map<String, List<Transaction>> bucket = <String, List<Transaction>>{};
    for (final Transaction t in all) {
      final String key = _keyFmt.format(t.occurredAt.toLocal());
      bucket.putIfAbsent(key, () => <Transaction>[]).add(t);
    }
    final List<String> keys = bucket.keys.toList(growable: false)
      ..sort((String a, String b) => b.compareTo(a));
    return <String, List<Transaction>>{
      for (final String k in keys) k: bucket[k]!,
    };
  }

  Widget _txRowDummy(Transaction t) {
    final int signed = t.type == TransactionType.expense
        ? -t.amount.minor.toInt()
        : t.amount.minor.toInt();
    return IgnorePointer(
      child: PfTransactionItem(
        category: t.categoryId?.value ?? '—',
        amountMinor: signed,
        date: t.occurredAt.toLocal(),
        description: t.description,
        currencySymbol: t.amount.currency.symbol,
        locale: widget.locale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat headerFmt = DateFormat.yMMMMEEEEd(widget.locale);
    return SliverMainAxisGroup(
      slivers: <Widget>[
        for (final String section in _sectionOrder) ...<Widget>[
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              text: headerFmt.format(DateTime.parse(section)),
            ),
          ),
          SliverAnimatedList(
            key: _listKeys[section],
            initialItemCount: _current[section]?.length ?? 0,
            itemBuilder: (
              BuildContext ctx,
              int index,
              Animation<double> animation,
            ) {
              final List<Transaction> items =
                  _current[section] ?? const <Transaction>[];
              if (index >= items.length) {
                return const SizedBox.shrink();
              }
              final Transaction t = items[index];
              return SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: animation,
                  curve: PfEasing.standard,
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: _buildRow(ctx, t),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRow(BuildContext ctx, Transaction t) {
    final int signed = t.type == TransactionType.expense
        ? -t.amount.minor.toInt()
        : t.amount.minor.toInt();
    final AppL10n l10n = AppL10n.of(ctx);
    return Dismissible(
      key: Key('tx-${t.id.value}'),
      direction: DismissDirection.horizontal,
      background: _SwipeBackground(
        color: _kSwipeEditColor,
        icon: Icons.edit_outlined,
        label: l10n.txEdit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeBackground(
        color: _kSwipeDeleteColor,
        icon: Icons.delete_outline,
        label: l10n.commonDelete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (DismissDirection dir) async {
        _lightImpact();
        if (dir == DismissDirection.startToEnd) {
          widget.onSwipeEdit(t);
          return false;
        }
        return _confirmDelete(ctx, l10n);
      },
      onDismissed: (DismissDirection dir) {
        if (dir == DismissDirection.endToStart) {
          // ignore: discarded_futures
          widget.onSwipeDelete(t);
        }
      },
      child: PfTransactionItem(
        category: t.categoryId?.value ?? '—',
        amountMinor: signed,
        date: t.occurredAt.toLocal(),
        description: t.description,
        currencySymbol: t.amount.currency.symbol,
        locale: widget.locale,
        leadingHeroTag: 'tx-icon-${t.id.value}',
        onTap: () => widget.onTap(t),
        onLongPress: () => widget.onLongPress(t),
      ),
    );
  }
}

/// Fires a light haptic tap. Silently no-ops where unavailable (e.g. web).
void _lightImpact() {
  try {
    // ignore: discarded_futures
    HapticFeedback.lightImpact();
  } catch (_) {
    // No haptics on this platform; ignore.
  }
}

/// Cupertino-style destructive confirmation for deleting a transaction.
Future<bool> _confirmDelete(BuildContext context, AppL10n l10n) async {
  final bool? ok = await showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext ctx) => CupertinoAlertDialog(
      title: Text(l10n.txDeleteConfirm),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.commonCancel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.commonDelete),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Colored swipe affordance shown behind a [Dismissible] row.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final bool leading = alignment == Alignment.centerLeft;
    final List<Widget> content = <Widget>[
      Icon(icon, color: Colors.white),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: leading ? content : content.reversed.toList(),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({required this.text});
  final String text;

  @override
  double get minExtent => 36;

  @override
  double get maxExtent => 36;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
