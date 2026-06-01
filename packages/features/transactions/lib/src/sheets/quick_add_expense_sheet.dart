import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';

import 'quick_add_common.dart';

/// Opens the quick-add expense sheet via [showPfBottomSheet].
Future<void> showQuickAddExpenseSheet(BuildContext context) {
  return showPfBottomSheet<void>(
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
