// Small demo fixtures used by the in-memory previews of feature packages
// that don't yet have a real backend feed (e.g. Subscriptions before the
// detector job runs against real transaction data).
//
// These are deliberately tiny and obviously-fake so the UI has something to
// render in the preview build without depending on auth or sync.

import 'package:fnx_domain/fnx_domain.dart';
import 'package:fnx_feat_subscriptions/subscriptions.dart' as subs;

/// Returns a short list of [DetectedSubscription]s for the home preview.
List<subs.DetectedSubscription> buildDemoSubscriptions(Ulid userId) {
  final DateTime now = DateTime.now().toUtc();
  final DateTime nextWeek = now.add(const Duration(days: 7));
  final DateTime in3Days = now.add(const Duration(days: 3));
  final DateTime nextMonth = now.add(const Duration(days: 28));
  return <subs.DetectedSubscription>[
    subs.DetectedSubscription(
      id: Ulid.now(at: now),
      userId: userId,
      merchantName: 'Netflix',
      amount: Money(BigInt.from(599000), Currency.kzt), // 5 990 KZT
      period: subs.BillingPeriod.monthly,
      nextBillingDate: in3Days,
      brandIconKey: 'netflix',
      createdAt: now,
      updatedAt: now,
    ),
    subs.DetectedSubscription(
      id: Ulid.now(at: now.add(const Duration(milliseconds: 1))),
      userId: userId,
      merchantName: 'Яндекс Плюс',
      amount: Money(BigInt.from(150000), Currency.kzt),
      period: subs.BillingPeriod.monthly,
      nextBillingDate: nextWeek,
      brandIconKey: 'yandex',
      createdAt: now,
      updatedAt: now,
    ),
    subs.DetectedSubscription(
      id: Ulid.now(at: now.add(const Duration(milliseconds: 2))),
      userId: userId,
      merchantName: 'Spotify',
      amount: Money(BigInt.from(149900), Currency.kzt),
      period: subs.BillingPeriod.monthly,
      nextBillingDate: nextMonth,
      brandIconKey: 'spotify',
      createdAt: now,
      updatedAt: now,
    ),
    subs.DetectedSubscription(
      id: Ulid.now(at: now.add(const Duration(milliseconds: 3))),
      userId: userId,
      merchantName: 'iCloud 200GB',
      amount: Money(BigInt.from(39900), Currency.kzt),
      period: subs.BillingPeriod.monthly,
      nextBillingDate: nextWeek.add(const Duration(days: 5)),
      brandIconKey: 'icloud',
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
