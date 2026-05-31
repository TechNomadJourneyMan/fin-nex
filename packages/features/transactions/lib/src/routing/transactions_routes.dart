import 'package:flutter/material.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:go_router/go_router.dart';

import '../pages/history_page.dart';
import '../pages/transaction_details_page.dart';
import '../pages/transaction_form_page.dart';
import '../sheets/quick_add_expense_sheet.dart';
import '../sheets/quick_add_income_sheet.dart';

/// Path constants for the transactions feature.
abstract final class TransactionsRoutePaths {
  /// History/list root.
  static const String list = '/transactions';

  /// Full-form quick-add expense.
  static const String addExpense = '/transactions/add';

  /// Full-form quick-add income.
  static const String addIncome = '/transactions/income';

  /// Detail page (replace `:id` with the ULID).
  static const String details = '/transactions/:id';

  /// Edit page.
  static const String edit = '/transactions/:id/edit';
}

/// Returns the [GoRoute]s contributed by this feature.
///
/// Mount these on the app's root [GoRouter] in `main()`.
List<GoRoute> buildTransactionsRoutes() {
  return <GoRoute>[
    GoRoute(
      path: TransactionsRoutePaths.list,
      builder: (BuildContext ctx, GoRouterState state) => const HistoryPage(),
      routes: <GoRoute>[
        GoRoute(
          path: 'add',
          builder: (BuildContext ctx, GoRouterState state) =>
              const TransactionFormPage(),
        ),
        GoRoute(
          path: 'income',
          builder: (BuildContext ctx, GoRouterState state) =>
              const TransactionFormPage(),
        ),
        GoRoute(
          path: ':id',
          builder: (BuildContext ctx, GoRouterState state) {
            final String raw = state.pathParameters['id'] ?? '';
            return TransactionDetailsPage(transactionId: Ulid(raw));
          },
          routes: <GoRoute>[
            GoRoute(
              path: 'edit',
              builder: (BuildContext ctx, GoRouterState state) {
                // The edit page expects a `Transaction`; the parent details
                // page is the canonical entry. Falling back to a blank form
                // when accessed directly via deep link is acceptable until
                // a proper repo lookup wires through GoRouter `extra`.
                final Object? extra = state.extra;
                return TransactionFormPage(
                  initial: extra is Transaction ? extra : null,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ];
}

/// Convenience launcher for the quick-add expense bottom sheet.
Future<void> openQuickAddExpense(BuildContext context) =>
    showQuickAddExpenseSheet(context);

/// Convenience launcher for the quick-add income bottom sheet.
Future<void> openQuickAddIncome(BuildContext context) =>
    showQuickAddIncomeSheet(context);
