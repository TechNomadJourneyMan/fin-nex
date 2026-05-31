// Widget test for the subscriptions manager page.
//
// Overrides the repository + user-id providers with an in-memory stub seeded
// with two subscriptions and asserts the sub-cards render.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_domain/domain.dart';
import 'package:fnx_feat_subscriptions/fnx_feat_subscriptions.dart';

void main() {
  // 26-char Crockford base-32 ids (alphabet excludes I, L, O, U).
  final userId = Ulid('00000000000000000000000SER');
  final netflixId = Ulid('0000000000000000000NETFXAA');
  final spotifyId = Ulid('00000000000000000SP0TYFY01');

  DetectedSubscription mk({
    required Ulid id,
    required String merchant,
    required int minor,
    BillingPeriod period = BillingPeriod.monthly,
  }) {
    final now = DateTime.utc(2026, 5, 31);
    return DetectedSubscription(
      id: id,
      userId: userId,
      merchantName: merchant,
      amount: Money(BigInt.from(minor), Currency.kzt),
      period: period,
      nextBillingDate: DateTime.utc(2026, 6, 5),
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget harness(DetectedSubscriptionsRepository repo) {
    return ProviderScope(
      overrides: [
        detectedSubscriptionsRepositoryProvider.overrideWithValue(repo),
        subscriptionsUserIdProvider.overrideWithValue(userId),
      ],
      child: const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: FnxLocales.all,
        home: SubscriptionsManagerPage(),
      ),
    );
  }

  testWidgets('renders a card per detected subscription', (tester) async {
    final repo = InMemoryDetectedSubscriptionsRepository(<DetectedSubscription>[
      mk(id: netflixId, merchant: 'Netflix', minor: 459000),
      mk(
        id: spotifyId,
        merchant: 'Spotify',
        minor: 169000,
        period: BillingPeriod.yearly,
      ),
    ]);

    await tester.pumpWidget(harness(repo));
    await tester.pumpAndSettle();

    expect(find.byType(SubscriptionCard), findsNWidgets(2));
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);
    // Calendar strip and total card are present.
    expect(find.byType(UpcomingCalendarStrip), findsOneWidget);
  });

  testWidgets('shows empty state when there are no subscriptions',
      (tester) async {
    final repo = InMemoryDetectedSubscriptionsRepository();

    await tester.pumpWidget(harness(repo));
    await tester.pumpAndSettle();

    expect(find.byType(SubscriptionCard), findsNothing);
  });
}
