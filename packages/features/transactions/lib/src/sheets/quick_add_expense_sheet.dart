import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';

import 'quick_add_common.dart';

/// Opens the quick-add expense sheet via [showFnxBottomSheet].
Future<void> showQuickAddExpenseSheet(BuildContext context) {
  return showFnxBottomSheet<void>(
    context: context,
    semanticLabel: AppL10n.of(context).qaExpenseTitle,
    builder: (BuildContext ctx) => const QuickAddExpenseSheet(),
  );
}

/// Bottom-sheet body for adding an expense in <200ms.
class QuickAddExpenseSheet extends ConsumerWidget {
  /// Default ctor.
  const QuickAddExpenseSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return QuickAddBody(
      title: l10n.qaExpenseTitle,
      type: TransactionType.expense,
      onSaved: (Transaction tx) {
        Navigator.of(context).maybePop();
      },
    );
  }
}
