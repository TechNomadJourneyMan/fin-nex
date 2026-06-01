// Smoke test for the PocketFlow shared widget library.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

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
  testWidgets('PfButton renders all variants without exception',
      (tester) async {
    await tester.pumpWidget(_host(
      Column(
        children: [
          PfButton(label: 'Primary', onPressed: () {}),
          PfButton(
            label: 'Secondary',
            variant: PfButtonVariant.secondary,
            onPressed: () {},
          ),
          PfButton(
            label: 'Ghost',
            variant: PfButtonVariant.ghost,
            onPressed: () {},
          ),
          PfButton(
            label: 'Destructive',
            variant: PfButtonVariant.destructive,
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
          PfIconButton(icon: Icons.add, onPressed: () {}, tooltip: 'Add'),
          const PfTextField(label: 'Email', hint: 'you@example.com'),
          PfNumericField(label: 'Amount', onChanged: (_) {}),
          const PfChip(label: 'Filter'),
          const PfCard(child: Text('Card body')),
          const PfListItem(title: 'Row', subtitle: 'Subtitle'),
          const PfAvatar(initials: 'AN'),
          const PfBadge(count: 3),
          PfSwitch(value: true, onChanged: (_) {}),
          PfSlider(value: 0.4, onChanged: (_) {}),
          PfTabs(
            tabs: const ['Day', 'Week', 'Month'],
            selectedIndex: 0,
            onChanged: (_) {},
          ),
          PfSegmentedControl<String>(
            segments: const {'D': 'Day', 'W': 'Week'},
            value: 'D',
            onChanged: (_) {},
          ),
          const PfBanner(message: 'Saved locally'),
          const PfInsightCard(
            title: 'Tip',
            body: 'You spent 12% less on Cafe',
          ),
          const PfBudgetProgress(
            label: 'Cafe',
            spentMinor: 4200,
            limitMinor: 25000,
          ),
          PfTransactionItem(
            category: 'Coffee',
            amountMinor: -1500,
            date: DateTime(2026, 5, 31, 10, 30),
          ),
          const PfSkeleton(height: 16),
          const PfEmptyState(
            title: 'Nothing here',
            body: 'Add your first transaction',
          ),
          PfSelect<String>(
            value: 'a',
            options: const [
              PfSelectOption(value: 'a', label: 'Alpha'),
              PfSelectOption(value: 'b', label: 'Beta'),
            ],
            onChanged: (_) {},
          ),
          PfCategoryPicker(
            categories: const [
              PfCategoryOption(
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
      PfAmountInput(
        onChanged: (_) {},
        onDone: (_) {},
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  test('formatPfSignedAmount renders minus with unicode minus', () {
    final result = formatPfSignedAmount(-1234, locale: 'en');
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
                  onPressed: () => showPfBottomSheet<void>(
                    context: ctx,
                    builder: (_) => const SizedBox(height: 80),
                  ),
                  child: const Text('sheet'),
                ),
                TextButton(
                  onPressed: () => showPfDialog(
                    context: ctx,
                    title: 'Hi',
                    message: 'msg',
                  ),
                  child: const Text('dialog'),
                ),
                TextButton(
                  onPressed: () => ctx.showPfSnack('hello'),
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
