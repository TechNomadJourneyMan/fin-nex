// Verifies that the HeroBalance widget mounts a `Hero` with the shared
// `pf-balance-hero` tag on the dashboard page, so the morph into the
// transaction-details amount header is wired up.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';

void main() {
  testWidgets('HeroBalance mounts a Hero with kPfBalanceHeroTag', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeroBalance(
            amount: Money.major(125000, Currency.kzt),
          ),
        ),
      ),
    );

    // Hero is mounted with the shared tag.
    final Finder hero = find.byWidgetPredicate(
      (Widget w) => w is Hero && w.tag == kPfBalanceHeroTag,
    );
    expect(hero, findsOneWidget);

    // And it uses MaterialRectArcTween for a curved flight path.
    final Hero h = tester.widget<Hero>(hero);
    expect(h.createRectTween, isNotNull);
    final Tween<Rect?> t = h.createRectTween!(
      const Rect.fromLTWH(0, 0, 1, 1),
      const Rect.fromLTWH(1, 1, 1, 1),
    );
    expect(t, isA<MaterialRectArcTween>());
  });

  testWidgets('Passing heroTag: null opts out of the Hero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeroBalance(
            amount: Money.major(125000, Currency.kzt),
            heroTag: null,
          ),
        ),
      ),
    );
    expect(find.byType(Hero), findsNothing);
  });
}
