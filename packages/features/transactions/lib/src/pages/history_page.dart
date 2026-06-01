import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Category;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../controllers/transactions_controller.dart';
import '../providers.dart';
import '../sheets/quick_add_expense_sheet.dart';
import '../state/transaction_filter_state.dart';
import 'transaction_details_page.dart';

/// History list page with sticky date sections, search, and filters.
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
  TransactionFilterState _filter = const TransactionFilterState();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final TransactionFilterState? next =
        await showPfBottomSheet<TransactionFilterState>(
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
    // Briefly delay so the RefreshIndicator spinner is visible even when
    // the underlying provider is essentially instant (cached / fake repo).
    await Future.wait<void>(<Future<void>>[
      ref.read(transactionsControllerProvider(_filter).future),
      Future<void>.delayed(const Duration(milliseconds: 300)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final AsyncValue<List<Transaction>> async = ref.watch(
      transactionsControllerProvider(_filter),
    );

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
            child: PfTextField(
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: async.when(
          data: (List<Transaction> txs) {
            if (txs.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  const SizedBox(height: 80),
                  PfEmptyState(
                    title: l10n.dashEmptyTitle,
                    body: l10n.qaNotePlaceholder,
                    icon: Icons.receipt_long_outlined,
                    lottieAsset: 'assets/lottie/empty_transactions.json',
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
                // Selection-class haptic + (optional) tap sound on every row
                // tap. Replaces the legacy direct HapticFeedback call so all
                // feedback flows through the same on/off toggle in Settings.
                ref.read(feedbackServiceProvider).selectTap();
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) =>
                        TransactionDetailsPage(transactionId: t.id),
                  ),
                );
              },
              onLongPress: (Transaction t) {
                // Long-press is the entry point for the swipe-edit shortcut.
                ref.read(feedbackServiceProvider).longPress();
              },
              onSwipeEdit: (Transaction t) {
                context.push('/transactions/${t.id.value}/edit', extra: t);
              },
              onSwipeDelete: (Transaction t) async {
                final TransactionsController ctrl = ref.read(
                  transactionsControllerProvider(_filter).notifier,
                );
                final FeedbackService feedback =
                    ref.read(feedbackServiceProvider);
                // Confirm-class haptic (mediumImpact) on the actual delete.
                feedback.confirmAction();
                await ctrl.softDelete(t.id);
                if (!context.mounted) {
                  return;
                }
                bool undone = false;
                context.showPfSnack(
                  l10n.txDeleted,
                  // 5 s undo window; restoring re-inserts at the original
                  // position because the transaction keeps its occurredAt and
                  // the list re-groups by date.
                  duration: const Duration(seconds: 5),
                  action: PfSnackAction(
                    label: l10n.txUndo,
                    onPressed: () {
                      undone = true;
                      // ignore: discarded_futures
                      ctrl.restore(t);
                    },
                  ),
                );
                // Error-class haptic if the window elapses without an undo
                // (the delete is now permanent for this session).
                Future<void>.delayed(const Duration(seconds: 5), () {
                  if (!undone) {
                    feedback.error();
                  }
                });
              },
            );
          },
          loading: () => const _HistorySkeleton(),
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

/// Shimmer placeholder shown while the transaction list loads. Mimics a few
/// date-sectioned rows so the layout doesn't jump when data arrives.
class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
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

class _SectionedList extends StatefulWidget {
  const _SectionedList({
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
  final ValueChanged<Transaction> onSwipeDelete;

  @override
  State<_SectionedList> createState() => _SectionedListState();
}

class _SectionedListState extends State<_SectionedList> {
  /// Stable per-section animated-list state keys, keyed by the section's
  /// `yyyy-MM-dd` date string so the same key survives across rebuilds and
  /// only animates additions/removals.
  final Map<String, GlobalKey<SliverAnimatedListState>> _listKeys =
      <String, GlobalKey<SliverAnimatedListState>>{};

  /// Snapshot of the items we last rendered, keyed by section date. Mutating
  /// this map drives [SliverAnimatedListState.insertItem] /
  /// [SliverAnimatedListState.removeItem] calls.
  final Map<String, List<Transaction>> _current = <String, List<Transaction>>{};

  /// Insertion order of sections; recomputed from `widget.transactions` on
  /// each rebuild.
  List<String> _sectionOrder = <String>[];

  static final DateFormat _keyFmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void didUpdateWidget(covariant _SectionedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reconcile();
  }

  /// First-time fill — no animations are scheduled because the SliverAnimatedList
  /// builds with its initial item count.
  void _seed() {
    _current.clear();
    final Map<String, List<Transaction>> grouped = _group(widget.transactions);
    _sectionOrder = grouped.keys.toList(growable: false);
    grouped.forEach((String key, List<Transaction> items) {
      _current[key] = items;
      _listKeys.putIfAbsent(key, () => GlobalKey<SliverAnimatedListState>());
    });
  }

  /// Diff new `widget.transactions` against `_current` per section and call
  /// insertItem/removeItem to drive animations.
  void _reconcile() {
    final Map<String, List<Transaction>> grouped = _group(widget.transactions);
    _sectionOrder = grouped.keys.toList(growable: false);

    // Sections that disappeared entirely — drop their keys.
    final Set<String> nextSectionSet = grouped.keys.toSet();
    _current.keys
        .where((String k) => !nextSectionSet.contains(k))
        .toList(growable: false)
        .forEach(_current.remove);

    for (final String section in _sectionOrder) {
      final List<Transaction> next = grouped[section]!;
      final List<Transaction> prev = _current[section] ?? <Transaction>[];
      final GlobalKey<SliverAnimatedListState> key =
          _listKeys.putIfAbsent(section, () => GlobalKey<SliverAnimatedListState>());
      final SliverAnimatedListState? listState = key.currentState;
      if (listState == null) {
        // The list hasn't mounted yet (new section first render). Seed in place
        // and let it build with the right initial item count.
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

    // Remove anything no longer present, working from highest index down so
    // earlier indices stay valid.
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

    // Insert anything new at its target position. We use the target list's
    // index for stable ordering.
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
    // Section keys descending (newest first).
    final List<String> keys = bucket.keys.toList(growable: false)
      ..sort((String a, String b) => b.compareTo(a));
    return <String, List<Transaction>>{
      for (final String k in keys) k: bucket[k]!,
    };
  }

  /// Used by the remove animation so the disappearing row keeps its layout
  /// during the size-collapse animation. Pulls live data from the removed
  /// model so we don't reference a stale list index.
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
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        for (final String section in _sectionOrder)
          SliverMainAxisGroup(
            slivers: <Widget>[
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
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
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

/// Fires a light haptic tap. Silently no-ops on platforms (e.g. web) where the
/// haptic channel isn't available.
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
          Text(l10n.commonAll, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final TransactionType t in <TransactionType>[
                TransactionType.expense,
                TransactionType.income,
                TransactionType.transfer,
              ])
                PfChip(
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
                PfChip(
                  label: c.name,
                  selected: _draft.categoryIds.any(
                    (Ulid u) => u.value == c.id.value,
                  ),
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
                PfChip(
                  label: a.name,
                  selected: _draft.accountIds.any(
                    (Ulid u) => u.value == a.id.value,
                  ),
                  onTap: () => _toggleAccount(a.id),
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
                  onPressed: () =>
                      Navigator.of(context).pop(const TransactionFilterState()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PfButton(
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
