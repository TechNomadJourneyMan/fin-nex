import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_feat_transactions/transactions.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('TransactionsRoutePaths', () {
    test('list is /transactions', () {
      expect(TransactionsRoutePaths.list, '/transactions');
    });
    test('addExpense is /transactions/add', () {
      expect(TransactionsRoutePaths.addExpense, '/transactions/add');
    });
    test('addIncome is /transactions/income', () {
      expect(TransactionsRoutePaths.addIncome, '/transactions/income');
    });
  });

  test('buildTransactionsRoutes returns at least one GoRoute', () {
    final List<GoRoute> routes = buildTransactionsRoutes();
    expect(routes, isNotEmpty);
    expect(routes.first.path, '/transactions');
  });
}
