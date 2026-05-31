import 'package:flutter/material.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:intl/intl.dart';

import '../controllers/transactions_controller.dart';
import '../providers.dart';
import '../state/transaction_filter_state.dart';

/// Full-detail transaction editor (create or edit).
class TransactionFormPage extends ConsumerStatefulWidget {
  /// Default ctor. Pass [initial] for edit mode.
  const TransactionFormPage({super.key, this.initial});

  /// Transaction being edited; `null` means create.
  final Transaction? initial;

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  late TransactionType _type;
  late int _amountMinor;
  Ulid? _accountId;
  Ulid? _categoryId;
  late DateTime _occurredAt;
  late TextEditingController _noteCtrl;
  // TODO(F-301): tags + attachments pickers — stubbed for now.
  final List<Ulid> _tagIds = <Ulid>[];
  final List<Ulid> _attachmentIds = <Ulid>[];

  @override
  void initState() {
    super.initState();
    final Transaction? init = widget.initial;
    _type = init?.type ?? TransactionType.expense;
    _amountMinor = init == null ? 0 : init.amount.minor.toInt();
    _accountId = init?.accountId;
    _categoryId = init?.categoryId;
    _occurredAt = init?.occurredAt ?? DateTime.now().toUtc();
    _noteCtrl = TextEditingController(text: init?.description ?? '');
    if (init != null) {
      _tagIds.addAll(init.tagIds);
      _attachmentIds.addAll(init.attachmentIds);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    if (_amountMinor <= 0) {
      context.showFnxSnack(l10n.qaAmountRequired, isError: true);
      return;
    }
    if (_accountId == null || _categoryId == null) {
      context.showFnxSnack(l10n.errorValidation, isError: true);
      return;
    }
    final Currency currency = ref.read(defaultCurrencyProvider);
    final Ulid userId = ref.read(currentUserIdProvider);
    final DateTime nowUtc = DateTime.now().toUtc();
    final Transaction tx = Transaction(
      id: widget.initial?.id ?? Ulid.now(at: nowUtc),
      userId: widget.initial?.userId ?? userId,
      accountId: _accountId!,
      type: _type,
      amount: Money(BigInt.from(_amountMinor), currency),
      categoryId: _categoryId,
      occurredAt: _occurredAt,
      description: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      createdAt: widget.initial?.createdAt ?? nowUtc,
      updatedAt: nowUtc,
      source: widget.initial?.source ?? 'manual',
      attachmentIds: List<Ulid>.unmodifiable(_attachmentIds),
      tagIds: List<Ulid>.unmodifiable(_tagIds),
    );
    final TransactionsController ctrl = ref.read(
      transactionsControllerProvider(const TransactionFilterState()).notifier,
    );
    try {
      await ctrl.save(tx);
      if (!mounted) {
        return;
      }
      Navigator.of(context).maybePop(tx);
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      // Surface the real cause to the user instead of a generic message so
      // platform/database errors are debuggable. Truncate to fit a snack.
      final String detail = e.toString();
      final String msg = '${l10n.qaSaveErrorOffline}\n'
          '${detail.length > 160 ? '${detail.substring(0, 157)}...' : detail}';
      context.showFnxSnack(msg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final Currency currency = ref.watch(defaultCurrencyProvider);
    final bool isEdit = widget.initial != null;
    final DateFormat dateFmt = DateFormat.yMMMd(l10n.localeName);
    final DateFormat timeFmt = DateFormat.Hm(l10n.localeName);

    // Auto-fill account and category from streams once they hydrate.
    // Without this, async repos that finish loading AFTER the form mounted
    // leave the user with null defaults → "Please check highlighted fields"
    // error on save even when their visible input looks complete.
    ref.listen<AsyncValue<List<Account>>>(
      accountsStreamProvider,
      (AsyncValue<List<Account>>? prev, AsyncValue<List<Account>> next) {
        if (_accountId != null) return;
        final List<Account>? list = next.valueOrNull;
        if (list == null || list.isEmpty) return;
        setState(() => _accountId = list.first.id);
      },
    );
    ref.listen<AsyncValue<List<Category>>>(
      categoriesStreamProvider,
      (AsyncValue<List<Category>>? prev, AsyncValue<List<Category>> next) {
        if (_categoryId != null) return;
        final List<Category>? list = next.valueOrNull;
        if (list == null || list.isEmpty) return;
        final CategoryType wanted = _matchType(_type);
        final Iterable<Category> matching = list.where(
          (Category c) => c.type == wanted && !c.isArchived,
        );
        if (matching.isNotEmpty) {
          setState(() => _categoryId = matching.first.id);
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        title: Text(isEdit ? l10n.txTitleEditExpense : l10n.txTitleNewExpense),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: l10n.commonSave,
            onPressed: _save,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SegmentedButton<TransactionType>(
                segments: <ButtonSegment<TransactionType>>[
                  ButtonSegment<TransactionType>(
                    value: TransactionType.expense,
                    label: Text(l10n.qaExpenseTitle),
                  ),
                  ButtonSegment<TransactionType>(
                    value: TransactionType.income,
                    label: Text(l10n.qaIncomeTitle),
                  ),
                  ButtonSegment<TransactionType>(
                    value: TransactionType.transfer,
                    label: Text(l10n.qaTransferTitle),
                  ),
                ],
                selected: <TransactionType>{_type},
                onSelectionChanged: (Set<TransactionType> sel) {
                  setState(() {
                    _type = sel.first;
                    _categoryId = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              FnxAmountInput(
                key: ValueKey<String>('form-amount-${widget.initial?.id ?? 'new'}'),
                initialValue: _amountMinor,
                currencySymbol: currency.symbol,
                doneLabel: l10n.commonSave,
                onChanged: (int v) => _amountMinor = v,
                onDone: (int v) {
                  _amountMinor = v;
                  _save();
                },
              ),
              const SizedBox(height: 16),
              _CategorySelector(
                type: _matchType(_type),
                selectedId: _categoryId,
                onChanged: (Ulid id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 16),
              _AccountSelector(
                selectedId: _accountId,
                onChanged: (Ulid id) => setState(() => _accountId = id),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text('${l10n.txFieldDate}: '
                          '${dateFmt.format(_occurredAt.toLocal())}'),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _occurredAt.toLocal(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _occurredAt = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              _occurredAt.hour,
                              _occurredAt.minute,
                            ).toUtc();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text('${l10n.txFieldTime}: '
                          '${timeFmt.format(_occurredAt.toLocal())}'),
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime:
                              TimeOfDay.fromDateTime(_occurredAt.toLocal()),
                        );
                        if (picked != null) {
                          final DateTime local = _occurredAt.toLocal();
                          setState(() {
                            _occurredAt = DateTime(
                              local.year,
                              local.month,
                              local.day,
                              picked.hour,
                              picked.minute,
                            ).toUtc();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FnxTextField(
                label: l10n.txFieldNote,
                hint: l10n.qaNotePlaceholder,
                controller: _noteCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FnxButton(
                label: l10n.commonSave,
                fullWidth: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySelector extends ConsumerWidget {
  const _CategorySelector({
    required this.type,
    required this.selectedId,
    required this.onChanged,
  });

  final CategoryType type;
  final Ulid? selectedId;
  final ValueChanged<Ulid> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final AsyncValue<List<Category>> cats =
        ref.watch(categoriesStreamProvider);
    return cats.when(
      data: (List<Category> all) {
        final List<Category> visible = all
            .where((Category c) => c.type == type && !c.isArchived)
            .toList(growable: false);
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final Category c in visible)
              FnxChip(
                label: c.name,
                selected: selectedId == c.id,
                onTap: () => onChanged(c.id),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Text(l10n.errorUnknown),
    );
  }
}

class _AccountSelector extends ConsumerWidget {
  const _AccountSelector({
    required this.selectedId,
    required this.onChanged,
  });

  final Ulid? selectedId;
  final ValueChanged<Ulid> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final AsyncValue<List<Account>> accs = ref.watch(accountsStreamProvider);
    return accs.when(
      data: (List<Account> all) {
        final List<Account> live = all
            .where((Account a) => !a.isArchived && a.deletedAt == null)
            .toList(growable: false);
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final Account a in live)
              FnxChip(
                label: a.name,
                selected: selectedId == a.id,
                onTap: () => onChanged(a.id),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Text(l10n.errorUnknown),
    );
  }
}
