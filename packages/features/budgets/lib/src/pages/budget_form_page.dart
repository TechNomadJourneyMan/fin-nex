// Create / edit form for a budget.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/domain.dart';
import 'package:pf_feat_categories/pf_feat_categories.dart' as cats;
import 'package:go_router/go_router.dart';

import '../controllers/budgets_controller.dart';

/// Create / edit a budget. When [budgetId] is null the form creates a new
/// budget.
class BudgetFormPage extends ConsumerStatefulWidget {
  /// Creates a budget form page.
  const BudgetFormPage({super.key, this.budgetId});

  /// ULID string of the budget being edited, or null for create.
  final String? budgetId;

  @override
  ConsumerState<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends ConsumerState<BudgetFormPage> {
  final TextEditingController _name = TextEditingController();
  BudgetPeriod _period = BudgetPeriod.monthly;
  int _amount = 0;
  final Set<Ulid> _categoryIds = <Ulid>{};
  final Set<int> _thresholds = <int>{50, 80, 100};
  Budget? _editing;
  bool _initialised = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _hydrate(List<Budget> budgets) {
    if (_initialised || widget.budgetId == null) {
      _initialised = true;
      return;
    }
    Budget? match;
    for (final b in budgets) {
      if (b.id.value == widget.budgetId) {
        match = b;
        break;
      }
    }
    if (match != null) {
      _editing = match;
      _name.text = match.name;
      _period = match.period;
      _amount = match.amount.minor.toInt();
      _categoryIds
        ..clear()
        ..addAll(match.categoryIds);
      _thresholds
        ..clear()
        ..addAll(match.alertThresholds);
    }
    _initialised = true;
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _amount <= 0) {
      return;
    }
    final controller = ref.read(budgetsControllerProvider.notifier);
    // TODO(F-currency): replace with the user's settings-default currency
    // once the settings feature exposes a provider.
    final currency = _editing?.amount.currency ?? Currency.kzt;
    final money = Money(BigInt.from(_amount), currency);
    final thresholds = _thresholds.toList()..sort();

    if (_editing == null) {
      await controller.create(
        name: name,
        period: _period,
        amount: money,
        categoryIds: _categoryIds.toList(),
        alertThresholds: thresholds,
      );
    } else {
      await controller.upsert(
        _editing!.copyWith(
          name: name,
          period: _period,
          amount: money,
          categoryIds: _categoryIds.toList(),
          alertThresholds: thresholds,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _delete() async {
    final id = _editing?.id;
    if (id == null) {
      return;
    }
    await ref.read(budgetsControllerProvider.notifier).remove(id);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final state = ref.watch(budgetsControllerProvider);
    final budgets = state.valueOrNull;
    if (budgets != null && !_initialised) {
      _hydrate(budgets);
    }

    final categoriesAsync = ref.watch(cats.categoriesControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
            widget.budgetId == null ? l10n.budgetsCreate : l10n.commonEdit),
        actions: <Widget>[
          if (_editing != null)
            IconButton(
              tooltip: l10n.commonDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(spacing.s5),
          children: <Widget>[
            PfTextField(
              label: l10n.budgetFieldName,
              controller: _name,
            ),
            SizedBox(height: spacing.s5),
            Text(l10n.budgetFieldPeriod,
                style: context.fnxTypography.bodySm
                    .copyWith(color: colors.textSecondary)),
            SizedBox(height: spacing.s3),
            PfSegmentedControl<BudgetPeriod>(
              value: _period,
              segments: <BudgetPeriod, String>{
                BudgetPeriod.weekly: l10n.budgetPeriodWeek,
                BudgetPeriod.monthly: l10n.budgetPeriodMonth,
                // TODO(l10n): add an explicit "Custom" key; reusing yearly
                // for now to avoid blocking on l10n PR.
                BudgetPeriod.custom: l10n.budgetPeriodYear,
              },
              onChanged: (p) => setState(() => _period = p),
            ),
            SizedBox(height: spacing.s5),
            Text(l10n.budgetFieldLimit,
                style: context.fnxTypography.bodySm
                    .copyWith(color: colors.textSecondary)),
            SizedBox(height: spacing.s3),
            PfAmountInput(
              initialValue: _amount,
              onChanged: (v) => _amount = v,
              onDone: (v) {
                setState(() => _amount = v);
              },
              doneLabel: l10n.commonDone,
            ),
            SizedBox(height: spacing.s5),
            Text(l10n.budgetFieldCategory,
                style: context.fnxTypography.bodySm
                    .copyWith(color: colors.textSecondary)),
            SizedBox(height: spacing.s3),
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Text('$e', style: TextStyle(color: colors.error)),
              data: (list) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final c in list)
                    FilterChip(
                      label: Text(c.name),
                      selected: _categoryIds.contains(c.id),
                      onSelected: (sel) => setState(() {
                        if (sel) {
                          _categoryIds.add(c.id);
                        } else {
                          _categoryIds.remove(c.id);
                        }
                      }),
                    ),
                ],
              ),
            ),
            SizedBox(height: spacing.s6),
            Text(l10n.budgetAlertAt80,
                style: context.fnxTypography.bodySm
                    .copyWith(color: colors.textSecondary)),
            SizedBox(height: spacing.s3),
            Row(
              children: <Widget>[
                for (final pct in <int>[50, 80, 100]) ...<Widget>[
                  Expanded(
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text('$pct%'),
                      value: _thresholds.contains(pct),
                      onChanged: (v) => setState(() {
                        if (v) {
                          _thresholds.add(pct);
                        } else {
                          _thresholds.remove(pct);
                        }
                      }),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: spacing.s6),
            PfButton(
              label: l10n.commonSave,
              fullWidth: true,
              onPressed: _save,
            ),
            SizedBox(height: spacing.s3),
            PfButton(
              label: l10n.commonCancel,
              variant: PfButtonVariant.secondary,
              fullWidth: true,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
