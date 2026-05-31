// go_router route table for the budgets feature.

import 'package:go_router/go_router.dart';

import 'pages/budget_form_page.dart';
import 'pages/budgets_list_page.dart';
import 'pages/limits_list_page.dart';

/// Route path: budgets list.
const String kBudgetsListPath = '/budgets';

/// Route path: new budget.
const String kBudgetNewPath = '/budgets/new';

/// Route path: edit budget (`:id`).
const String kBudgetEditPath = '/budgets/:id/edit';

/// Route path: limits list.
const String kLimitsListPath = '/budgets/limits';

/// Returns the go_router routes for the budgets feature.
List<RouteBase> budgetsRoutes() {
  return <RouteBase>[
    GoRoute(
      path: kBudgetsListPath,
      name: 'budgetsList',
      builder: (context, state) => const BudgetsListPage(),
    ),
    GoRoute(
      path: kBudgetNewPath,
      name: 'budgetNew',
      builder: (context, state) => const BudgetFormPage(),
    ),
    GoRoute(
      path: kBudgetEditPath,
      name: 'budgetEdit',
      builder: (context, state) =>
          BudgetFormPage(budgetId: state.pathParameters['id']),
    ),
    GoRoute(
      path: kLimitsListPath,
      name: 'limitsList',
      builder: (context, state) => const LimitsListPage(),
    ),
  ];
}
