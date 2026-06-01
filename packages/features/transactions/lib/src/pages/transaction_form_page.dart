import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';
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
    final FeedbackService feedback = ref.read(feedbackServiceProvider);
    if (_amountMinor <= 0) {
      feedback.error();
      context.showPfSnack(l10n.qaAmountRequired, isError: true);
      return;
    }
    if (_accountId == null || _categoryId == null) {
      feedback.error();
      context.showPfSnack(l10n.errorValidation, isError: true);
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
      feedback.confirmAction();
      Navigator.of(context).maybePop(tx);
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      feedback.error();
      // Surface the real cause to the user instead of a generic message so
      // platform/database errors are debuggable. Truncate to fit a snack.
      final String detail = e.toString();
      final String msg = '${l10n.qaSaveErrorOffline}\n'
          '${detail.length > 160 ? '${detail.substring(0, 157)}...' : detail}';
      context.showPfSnack(msg, isError: true);
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
              const SizedBox(height: 24),
              // BIG amount display (number-only, calculator-style).
              Center(
                child: Text(
                  _formatAmount(_amountMinor, currency.symbol),
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                    color: Color(0xFFF2F2F3),
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Account / date / currency horizontal chip row.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _MetaPillAccount(
                      selectedId: _accountId,
                      onChanged: (Ulid id) =>
                          setState(() => _accountId = id),
                    ),
                    const SizedBox(width: 8),
                    _MetaPill(
                      icon: Icons.calendar_today,
                      label: dateFmt.format(_occurredAt.toLocal()),
                      onTap: () => _pickDate(),
                    ),
                    const SizedBox(width: 8),
                    _MetaPill(
                      icon: Icons.access_time,
                      label: timeFmt.format(_occurredAt.toLocal()),
                      onTap: () => _pickTime(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PfTextField(
                label: l10n.txFieldNote,
                hint: l10n.qaNotePlaceholder,
                controller: _noteCtrl,
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              // Inline horizontal category chips (matching the iOS reference).
              _CategoryStrip(
                type: _matchType(_type),
                selectedId: _categoryId,
                onChanged: (Ulid id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 16),
              // Calculator numpad with math operators.
              _CalculatorNumpad(
                amountMinor: _amountMinor,
                minorUnits: currency.minorUnit,
                onChanged: (int v) => setState(() => _amountMinor = v),
              ),
              const SizedBox(height: 16),
              PfButton(
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

  String _formatAmount(int minor, String symbol) {
    final int abs = minor.abs();
    final String major = (abs ~/ 100).toString();
    final String cents = (abs % 100).toString().padLeft(2, '0');
    final bool whole = abs % 100 == 0;
    return whole ? '$major $symbol' : '$major,$cents $symbol';
  }

  Future<void> _pickDate() async {
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
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt.toLocal()),
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
  }
}

// =============================================================================
// iOS-reference layout widgets (replaces old _CategorySelector / _AccountSelector).
// =============================================================================

/// Generic pill button: icon + label, glass-styled.
class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF14141A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: const Color(0xFF8A8A93)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF2F2F3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Account-picker pill: reads live accounts and shows a chooser bottom sheet.
class _MetaPillAccount extends ConsumerWidget {
  const _MetaPillAccount({
    required this.selectedId,
    required this.onChanged,
  });

  final Ulid? selectedId;
  final ValueChanged<Ulid> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Account>> accs = ref.watch(accountsStreamProvider);
    final List<Account> live = (accs.valueOrNull ?? <Account>[])
        .where((Account a) => !a.isArchived && a.deletedAt == null)
        .toList(growable: false);
    final Account? selected = live
        .where((Account a) => a.id == selectedId)
        .cast<Account?>()
        .firstOrNull;
    final String label = selected?.name ?? 'Счёт';

    return _MetaPill(
      icon: Icons.account_balance_wallet_outlined,
      label: label,
      onTap: () async {
        if (live.isEmpty) return;
        final Ulid? picked = await showModalBottomSheet<Ulid>(
          context: context,
          backgroundColor: const Color(0xFF14141A),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (BuildContext sheetCtx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final Account a in live)
                    ListTile(
                      leading: const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFFE5E5EA),
                      ),
                      title: Text(
                        a.name,
                        style: const TextStyle(color: Color(0xFFF2F2F3)),
                      ),
                      trailing: a.id == selectedId
                          ? const Icon(Icons.check, color: Color(0xFF24A148))
                          : null,
                      onTap: () => Navigator.of(sheetCtx).pop(a.id),
                    ),
                ],
              ),
            ),
          ),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// Horizontal-scroll category chip strip — icon-first, label below.
/// Matches the iOS reference where categories sit just above the numpad.
class _CategoryStrip extends ConsumerWidget {
  const _CategoryStrip({
    required this.type,
    required this.selectedId,
    required this.onChanged,
  });

  final CategoryType type;
  final Ulid? selectedId;
  final ValueChanged<Ulid> onChanged;

  IconData _iconFor(String key) {
    // Map known fnx category icon keys to Material icons. Falls back to a
    // neutral pin icon for unknown keys so nothing renders as a glyph code.
    switch (key) {
      case 'shopping_cart':
        return Icons.shopping_basket_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'delivery_dining':
        return Icons.delivery_dining;
      case 'local_gas_station':
        return Icons.local_gas_station_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      case 'local_taxi':
        return Icons.local_taxi_rounded;
      case 'build_circle':
        return Icons.build_circle_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'checkroom':
        return Icons.checkroom_rounded;
      case 'devices':
        return Icons.devices_rounded;
      case 'storefront':
        return Icons.storefront_rounded;
      case 'subscriptions':
        return Icons.subscriptions_rounded;
      case 'apps':
        return Icons.apps_rounded;
      case 'theater_comedy':
        return Icons.theater_comedy_rounded;
      case 'map':
        return Icons.map_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'medication':
        return Icons.medication_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'child_care':
        return Icons.child_care_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'gavel':
        return Icons.gavel_rounded;
      case 'swap_horiz':
        return Icons.swap_horiz_rounded;
      case 'send_to_mobile':
        return Icons.send_to_mobile_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'savings':
        return Icons.savings_rounded;
      case 'monitor_heart':
        return Icons.monitor_heart_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> cats =
        ref.watch(categoriesStreamProvider);
    final List<Category> visible = (cats.valueOrNull ?? <Category>[])
        .where((Category c) => c.type == type && !c.isArchived)
        .toList(growable: false);

    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: <Widget>[
          // Leading "no category" reset chip (matches the "🚫" icon in the
          // reference screenshot).
          _CategoryChip(
            icon: Icons.block_rounded,
            label: 'Нет',
            selected: selectedId == null,
            color: const Color(0xFF5C5C66),
            onTap: () {
              // Implementation note: requires the form to allow nullable
              // category to clear. For now: do nothing (form-level required
              // validation still asks for a category before save).
            },
          ),
          const SizedBox(width: 8),
          for (final Category c in visible) ...<Widget>[
            _CategoryChip(
              icon: _iconFor(c.iconKey),
              label: c.name,
              selected: selectedId == c.id,
              color: Color(int.parse(c.color.hex.substring(1), radix: 16) |
                  0xFF000000),
              onTap: () => onChanged(c.id),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg =
        selected ? color.withValues(alpha: 0.25) : const Color(0xFF14141A);
    final Color border =
        selected ? color : const Color(0xFF14141A);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 1.5),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? const Color(0xFFF2F2F3)
                    : const Color(0xFF8A8A93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calculator-style numpad with +/-/×/÷ on the 4th column.
///
/// Holds a tiny expression state internally (one operand + one operator).
/// On operator press the current input is "committed"; on `=` (or when
/// another number follows) the result is computed and shown as the new
/// amount. All math is integer-on-minor-units so no float drift.
class _CalculatorNumpad extends StatefulWidget {
  const _CalculatorNumpad({
    required this.amountMinor,
    required this.minorUnits,
    required this.onChanged,
  });

  /// Current amount displayed above the numpad, in minor units.
  final int amountMinor;

  /// Currency.minorUnit (typically 2).
  final int minorUnits;

  /// Fired whenever the user mutates the amount.
  final ValueChanged<int> onChanged;

  @override
  State<_CalculatorNumpad> createState() => _CalculatorNumpadState();
}

class _CalculatorNumpadState extends State<_CalculatorNumpad> {
  // Editing in MAJOR units as the user types digits — preserves cent input.
  // 0 means "fresh", a non-zero string accumulates digits.
  String _buffer = '';
  bool _hasDot = false;

  // Pending operator + left operand (in minor units).
  String? _pendingOp;
  int? _leftMinor;

  void _emit() {
    final int minor = _parseBuffer();
    widget.onChanged(minor);
  }

  int _parseBuffer() {
    if (_buffer.isEmpty) return 0;
    final List<String> parts = _buffer.split(',');
    final int major = int.tryParse(parts[0]) ?? 0;
    int cents = 0;
    if (parts.length == 2 && parts[1].isNotEmpty) {
      final String c = parts[1].padRight(widget.minorUnits, '0')
          .substring(0, widget.minorUnits);
      cents = int.tryParse(c) ?? 0;
    }
    final int scale = _intPow(10, widget.minorUnits);
    return major * scale + cents;
  }

  int _intPow(int base, int exp) {
    int r = 1;
    for (int i = 0; i < exp; i++) {
      r *= base;
    }
    return r;
  }

  void _onDigit(String d) {
    setState(() {
      if (_buffer == '0') {
        _buffer = d;
      } else {
        _buffer += d;
      }
      _emit();
    });
  }

  void _onDot() {
    if (_hasDot) return;
    setState(() {
      if (_buffer.isEmpty) _buffer = '0';
      _buffer += ',';
      _hasDot = true;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_buffer.isEmpty) return;
      final String removed = _buffer.substring(_buffer.length - 1);
      _buffer = _buffer.substring(0, _buffer.length - 1);
      if (removed == ',') _hasDot = false;
      _emit();
    });
  }

  void _onOperator(String op) {
    setState(() {
      _leftMinor = _parseBuffer();
      _pendingOp = op;
      _buffer = '';
      _hasDot = false;
    });
  }

  void _onEquals() {
    if (_pendingOp == null || _leftMinor == null) return;
    final int right = _parseBuffer();
    int result;
    switch (_pendingOp!) {
      case '+':
        result = _leftMinor! + right;
      case '-':
        result = _leftMinor! - right;
      case '×':
        // multiplying two minor amounts gives minor² — divide once by scale.
        result = (_leftMinor! * right) ~/ _intPow(10, widget.minorUnits);
      case '÷':
        if (right == 0) {
          result = _leftMinor!;
        } else {
          result = (_leftMinor! * _intPow(10, widget.minorUnits)) ~/ right;
        }
      default:
        result = right;
    }
    if (result < 0) result = 0;
    setState(() {
      _buffer = _formatMinor(result);
      _hasDot = _buffer.contains(',');
      _leftMinor = null;
      _pendingOp = null;
      _emit();
    });
  }

  String _formatMinor(int minor) {
    final int scale = _intPow(10, widget.minorUnits);
    final int major = minor ~/ scale;
    final int cents = minor % scale;
    if (cents == 0) return major.toString();
    return '$major,${cents.toString().padLeft(widget.minorUnits, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Widget btn(String label, VoidCallback onTap,
        {Color? bg, Color? fg, double size = 22}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: bg ?? const Color(0xFF1C1C24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: SizedBox(
                height: 56,
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: size,
                      fontWeight: FontWeight.w600,
                      color: fg ?? const Color(0xFFF2F2F3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget iconBtn(IconData icon, VoidCallback onTap, {Color? bg, Color? fg}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: bg ?? const Color(0xFF1C1C24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: SizedBox(
                height: 56,
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: fg ?? const Color(0xFFF2F2F3),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    const Color opColor = Color(0xFF1F2030);
    const Color opFg = Color(0xFFFFB840);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            btn('1', () => _onDigit('1')),
            btn('2', () => _onDigit('2')),
            btn('3', () => _onDigit('3')),
            btn('+', () => _onOperator('+'), bg: opColor, fg: opFg, size: 24),
          ],
        ),
        Row(
          children: <Widget>[
            btn('4', () => _onDigit('4')),
            btn('5', () => _onDigit('5')),
            btn('6', () => _onDigit('6')),
            btn('−', () => _onOperator('-'), bg: opColor, fg: opFg, size: 24),
          ],
        ),
        Row(
          children: <Widget>[
            btn('7', () => _onDigit('7')),
            btn('8', () => _onDigit('8')),
            btn('9', () => _onDigit('9')),
            btn('×', () => _onOperator('×'), bg: opColor, fg: opFg, size: 22),
          ],
        ),
        Row(
          children: <Widget>[
            btn(',', _onDot),
            btn('0', () => _onDigit('0')),
            iconBtn(Icons.backspace_outlined, _onBackspace),
            btn('÷', () => _onOperator('÷'), bg: opColor, fg: opFg, size: 22),
          ],
        ),
        if (_pendingOp != null) ...<Widget>[
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              btn(
                '=',
                _onEquals,
                bg: const Color(0xFF2E48E6),
                fg: const Color(0xFFFFFFFF),
                size: 22,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
