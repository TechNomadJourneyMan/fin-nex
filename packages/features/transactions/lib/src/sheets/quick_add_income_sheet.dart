import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';

import 'quick_add_common.dart';

/// Opens the quick-add income sheet via [showFnxBottomSheet].
Future<void> showQuickAddIncomeSheet(BuildContext context) {
  return showFnxBottomSheet<void>(
    context: context,
    semanticLabel: AppL10n.of(context).qaIncomeTitle,
    builder: (BuildContext ctx) => const QuickAddIncomeSheet(),
  );
}

/// Bottom-sheet body for adding income.
class QuickAddIncomeSheet extends ConsumerWidget {
  /// Default ctor.
  const QuickAddIncomeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return QuickAddBody(
      title: l10n.qaIncomeTitle,
      type: TransactionType.income,
      onSaved: (Transaction tx) {
        Navigator.of(context).maybePop();
      },
    );
  }
}
