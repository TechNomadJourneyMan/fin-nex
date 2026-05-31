// First-run demo seeding.
//
// On the very first launch Pocket Flow drops four obviously-fake demo
// transactions into the ledger so the dashboard, history, and analytics
// screens have something to show before the user has typed anything. A
// dismissable banner (see the dashboard page) lets the user wipe the demo
// data with one tap.
//
// State is tracked in [SharedPreferences] under [kDemoSeededKey] so seeding
// happens exactly once per install. [seedIfNeeded] is idempotent: calling it
// repeatedly after the flag is set is a no-op.
//
// The service only depends on the domain [TransactionsRepository] contract so
// it works against the real sqflite-backed repo, the in-memory fallback, and
// the test fake interchangeably.

import 'package:fnx_domain/fnx_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key recording that the first-run demo data has been
/// seeded. Bumping the `_vN` suffix re-seeds on the next launch.
const String kDemoSeededKey = 'pf.demo_seeded_v1';

/// SharedPreferences key recording that the user dismissed the demo banner.
const String kDemoBannerDismissedKey = 'pf.demo_banner_dismissed';

/// `source` tag stamped on every demo transaction so [clearDemo] can find and
/// soft-delete exactly the rows it created.
const String kDemoSource = 'demo';

/// Deterministic account ULID the demo transactions are booked against. It is
/// intentionally distinct from the real seeded "Кошелёк" account; demo rows
/// still surface in income/expense totals and the recent list, which is all
/// the first-run experience needs.
final Ulid kDemoAccountId = Ulid('000000000000000000000000D0');

/// Seeds (and later clears) the first-run demo transactions.
class DemoSeedService {
  /// Creates a service bound to [txRepo] for the given [userId] and
  /// [defaultCurrency].
  DemoSeedService(this.txRepo, this.userId, this.defaultCurrency);

  /// Repository the demo transactions are written to / read from.
  final TransactionsRepository txRepo;

  /// Owning user for the seeded transactions.
  final Ulid userId;

  /// Currency the seeded amounts are denominated in.
  final Currency defaultCurrency;

  /// Returns `true` when the demo data has already been seeded.
  Future<bool> hasSeeded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kDemoSeededKey) ?? false;
  }

  /// Inserts the four demo transactions the first time it runs, then records
  /// the seeded flag. A no-op on every subsequent call (idempotent).
  Future<void> seedIfNeeded() async {
    if (await hasSeeded()) {
      return;
    }

    final DateTime now = DateTime.now().toUtc();
    final DateTime today = now;
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    final DateTime threeDaysAgo = now.subtract(const Duration(days: 3));

    final List<Transaction> demo = <Transaction>[
      _tx(
        seq: 0,
        type: TransactionType.expense,
        description: 'Coffee Locale',
        majorUnits: 450,
        occurredAt: today,
      ),
      _tx(
        seq: 1,
        type: TransactionType.expense,
        description: 'Magnum Cash & Carry',
        majorUnits: 8200,
        occurredAt: yesterday,
      ),
      _tx(
        seq: 2,
        type: TransactionType.expense,
        description: 'Yandex Go',
        majorUnits: 2100,
        occurredAt: threeDaysAgo,
      ),
      _tx(
        seq: 3,
        type: TransactionType.income,
        description: 'Зарплата',
        majorUnits: 350000,
        occurredAt: threeDaysAgo,
      ),
    ];

    for (final Transaction tx in demo) {
      await txRepo.upsert(tx);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kDemoSeededKey, true);
  }

  /// Soft-deletes every demo transaction (those tagged with [kDemoSource])
  /// and resets the seeded + banner-dismissed flags so the install behaves
  /// like a fresh one.
  Future<void> clearDemo() async {
    final List<Transaction> all = await txRepo.list(
      userId,
      const TransactionFilter(),
    );
    for (final Transaction tx in all) {
      if (tx.source == kDemoSource && tx.deletedAt == null) {
        await txRepo.softDelete(tx.id);
      }
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(kDemoSeededKey);
    await prefs.remove(kDemoBannerDismissedKey);
  }

  Transaction _tx({
    required int seq,
    required TransactionType type,
    required String description,
    required int majorUnits,
    required DateTime occurredAt,
  }) {
    // Stable, collision-free ULIDs anchored at a fixed instant so re-seeding
    // (after a flag bump) overwrites rather than duplicates.
    final DateTime stamp = occurredAt.add(Duration(milliseconds: seq));
    final Ulid id = Ulid.now(at: stamp);
    return Transaction(
      id: id,
      userId: userId,
      accountId: kDemoAccountId,
      type: type,
      amount: Money.major(majorUnits, defaultCurrency),
      description: description,
      occurredAt: occurredAt,
      createdAt: occurredAt,
      updatedAt: occurredAt,
      source: kDemoSource,
      attachmentIds: const <Ulid>[],
      tagIds: const <Ulid>[],
    );
  }
}
