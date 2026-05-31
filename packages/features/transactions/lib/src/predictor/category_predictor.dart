import 'package:fnx_domain/fnx_domain.dart';

/// Naive smart-default category predictor.
///
/// Returns the [Ulid] of the most-frequent non-null category among the
/// caller-supplied transactions whose `occurredAt` falls within the
/// trailing [window] (defaults to 30 days). Falls back to `null` when no
/// suitable transaction is available.
///
/// Pure-Dart, no Flutter dependency — easy to unit-test.
class CategoryPredictor {
  /// Default ctor.
  const CategoryPredictor({this.window = const Duration(days: 30)});

  /// Lookback window for frequency counting.
  final Duration window;

  /// Predicts a category for [type] given recent [transactions].
  Ulid? predict({
    required Iterable<Transaction> transactions,
    required TransactionType type,
    DateTime? now,
  }) {
    final DateTime ref = (now ?? DateTime.now().toUtc());
    final DateTime cutoff = ref.subtract(window);
    final Map<String, int> counts = <String, int>{};
    final Map<String, Ulid> originals = <String, Ulid>{};

    for (final Transaction tx in transactions) {
      if (tx.deletedAt != null) {
        continue;
      }
      if (tx.type != type) {
        continue;
      }
      final Ulid? cat = tx.categoryId;
      if (cat == null) {
        continue;
      }
      if (tx.occurredAt.isBefore(cutoff)) {
        continue;
      }
      final String key = cat.value;
      counts[key] = (counts[key] ?? 0) + 1;
      originals[key] ??= cat;
    }

    if (counts.isEmpty) {
      return null;
    }
    String bestKey = counts.keys.first;
    int bestCount = counts[bestKey]!;
    counts.forEach((String k, int v) {
      if (v > bestCount) {
        bestKey = k;
        bestCount = v;
      }
    });
    return originals[bestKey];
  }

  /// Predicts the account most-recently used for [type], used as a smart
  /// default when the user has not selected one explicitly.
  Ulid? predictAccount({
    required Iterable<Transaction> transactions,
    required TransactionType type,
  }) {
    Transaction? newest;
    for (final Transaction tx in transactions) {
      if (tx.deletedAt != null) {
        continue;
      }
      if (tx.type != type) {
        continue;
      }
      if (newest == null || tx.occurredAt.isAfter(newest.occurredAt)) {
        newest = tx;
      }
    }
    return newest?.accountId;
  }
}
