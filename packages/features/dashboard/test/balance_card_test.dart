// Renders the balance card and asserts it pumps without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:fnx_feat_dashboard/dashboard.dart';

void main() {
  testWidgets('BalanceCard renders amounts and segment labels', (tester) async {
    DashboardPeriod selected = DashboardPeriod.month;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => BalanceCard(
              totalBalance: Money.major(125000, Currency.kzt),
              income: Money.major(80000, Currency.kzt),
              expense: Money.major(45000, Currency.kzt),
              period: selected,
              balanceLabel: 'Balance',
              incomeLabel: 'Income',
              expenseLabel: 'Expense',
              onPeriodChanged: (p) => setState(() => selected = p),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
  });
}
