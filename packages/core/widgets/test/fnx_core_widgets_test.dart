// Smoke test for the FinNex shared widget library.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('FnxButton renders all variants without exception',
      (tester) async {
    await tester.pumpWidget(_host(
      Column(
        children: [
          FnxButton(label: 'Primary', onPressed: () {}),
          FnxButton(
            label: 'Secondary',
            variant: FnxButtonVariant.secondary,
            onPressed: () {},
          ),
          FnxButton(
            label: 'Ghost',
            variant: FnxButtonVariant.ghost,
            onPressed: () {},
          ),
          FnxButton(
            label: 'Destructive',
            variant: FnxButtonVariant.destructive,
            onPressed: () {},
          ),
        ],
      ),
    ));
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Destructive'), findsOneWidget);
  });

  testWidgets('Core widgets pump cleanly', (tester) async {
    await tester.pumpWidget(_host(
      Column(
        children: [
          FnxIconButton(icon: Icons.add, onPressed: () {}, tooltip: 'Add'),
          const FnxTextField(label: 'Email', hint: 'you@example.com'),
          FnxNumericField(label: 'Amount', onChanged: (_) {}),
          const FnxChip(label: 'Filter'),
          const FnxCard(child: Text('Card body')),
          const FnxListItem(title: 'Row', subtitle: 'Subtitle'),
          const FnxAvatar(initials: 'AN'),
          const FnxBadge(count: 3),
          FnxSwitch(value: true, onChanged: (_) {}),
          FnxSlider(value: 0.4, onChanged: (_) {}),
          FnxTabs(
            tabs: const ['Day', 'Week', 'Month'],
            selectedIndex: 0,
            onChanged: (_) {},
          ),
          FnxSegmentedControl<String>(
            segments: const {'D': 'Day', 'W': 'Week'},
            value: 'D',
            onChanged: (_) {},
          ),
          const FnxBanner(message: 'Saved locally'),
          const FnxInsightCard(
            title: 'Tip',
            body: 'You spent 12% less on Cafe',
          ),
          const FnxBudgetProgress(
            label: 'Cafe',
            spentMinor: 4200,
            limitMinor: 25000,
          ),
          FnxTransactionItem(
            category: 'Coffee',
            amountMinor: -1500,
            date: DateTime(2026, 5, 31, 10, 30),
          ),
          const FnxSkeleton(height: 16),
          const FnxEmptyState(
            title: 'Nothing here',
            body: 'Add your first transaction',
          ),
          FnxSelect<String>(
            value: 'a',
            options: const [
              FnxSelectOption(value: 'a', label: 'Alpha'),
              FnxSelectOption(value: 'b', label: 'Beta'),
            ],
            onChanged: (_) {},
          ),
          FnxCategoryPicker(
            categories: const [
              FnxCategoryOption(
                id: 'food',
                label: 'Food',
                icon: Icons.fastfood,
                color: Color(0xFF3D5AFE),
              ),
            ],
            selectedId: 'food',
            onSelected: (_) {},
          ),
        ],
      ),
    ));

    expect(find.text('Row'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Cafe'), findsOneWidget);
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('Amount input pumps without exception', (tester) async {
    await tester.pumpWidget(_host(
      FnxAmountInput(
        onChanged: (_) {},
        onDone: (_) {},
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  test('formatFnxSignedAmount renders minus with unicode minus', () {
    final result = formatFnxSignedAmount(-1234, locale: 'en');
    expect(result.startsWith('−'), isTrue);
  });

  testWidgets('Bottom sheet, dialog, snackbar helpers do not throw',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => showFnxBottomSheet<void>(
                    context: ctx,
                    builder: (_) => const SizedBox(height: 80),
                  ),
                  child: const Text('sheet'),
                ),
                TextButton(
                  onPressed: () => showFnxDialog(
                    context: ctx,
                    title: 'Hi',
                    message: 'msg',
                  ),
                  child: const Text('dialog'),
                ),
                TextButton(
                  onPressed: () => ctx.showFnxSnack('hello'),
                  child: const Text('snack'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('sheet'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('snack'));
    await tester.pump();
    expect(find.text('hello'), findsOneWidget);
  });
}
