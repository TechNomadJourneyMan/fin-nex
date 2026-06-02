import '../entities/recurring_rule.dart';
import '../entities/transaction.dart';
import '../repositories/recurring_rules_repository.dart';
import '../repositories/transactions_repository.dart';
import '../values/ulid.dart';

/// Outcome of a single [RecurringEngine] run.
class RecurringRunResult {
  /// Creates a result.
  const RecurringRunResult({
    required this.created,
    required this.advancedRuleIds,
  });

  /// Transactions materialised on this run (already persisted).
  final List<Transaction> created;

  /// Ids of rules whose `nextRunAt` was advanced.
  final List<Ulid> advancedRuleIds;

  /// Whether anything changed.
  bool get isEmpty => created.isEmpty && advancedRuleIds.isEmpty;
}

/// Materialises any due [RecurringRule]s into real [Transaction]s.
///
/// For each rule that [RecurringRule.isDueAt] `now`, the engine produces one
/// transaction per missed occurrence (catching up if the app was closed for a
/// while), advancing `nextRunAt` each time until it lands in the future or
/// hits `endAt`.
///
/// Idempotency: each occurrence is stamped with a deterministic
/// [Transaction.externalRef] of the form `recurring:<ruleId>:<occurrenceIso>`.
/// Before creating an occurrence the engine checks the user's existing
/// transactions for that ref, so re-running over the same window never
/// duplicates — the engine can safely run on every app start and on manual
/// "sync now".
class RecurringEngine {
  /// Creates the engine over the rule + transaction repositories.
  const RecurringEngine({
    required RecurringRulesRepository rules,
    required TransactionsRepository transactions,
    Ulid Function()? idFactory,
  })  : _rules = rules,
        _transactions = transactions,
        _idFactory = idFactory;

  final RecurringRulesRepository _rules;
  final TransactionsRepository _transactions;
  final Ulid Function()? _idFactory;

  /// Safety cap on occurrences produced for a single rule in one run, so a
  /// far-past `nextRunAt` (or a misconfigured rule) can't spin forever.
  static const int _maxCatchUp = 366;

  /// Builds the idempotency ref for a rule occurrence.
  static String refFor(Ulid ruleId, DateTime occurrenceUtc) =>
      'recurring:${ruleId.value}:${occurrenceUtc.toUtc().toIso8601String()}';

  /// Runs the engine for [userId] at [now] (defaults to wall-clock UTC).
  Future<RecurringRunResult> run(Ulid userId, {DateTime? now}) async {
    final DateTime at = (now ?? DateTime.now()).toUtc();
    final List<RecurringRule> rules = await _rules.list(userId);

    // Snapshot existing externalRefs so we can dedupe without a round-trip per
    // occurrence. Filtered to this engine's namespace to keep it small.
    final List<Transaction> existing =
        await _transactions.list(userId, const TransactionFilter());
    final Set<String> seenRefs = <String>{
      for (final Transaction t in existing)
        if (t.externalRef != null && t.externalRef!.startsWith('recurring:'))
          t.externalRef!,
    };

    final List<Transaction> created = <Transaction>[];
    final List<Ulid> advanced = <Ulid>[];

    for (final RecurringRule rule in rules) {
      if (!rule.isDueAt(at)) {
        continue;
      }
      RecurringRule current = rule;
      var produced = 0;
      while (current.isDueAt(at) && produced < _maxCatchUp) {
        final DateTime occurrence = current.nextRunAt;
        final String ref = refFor(current.id, occurrence);
        if (!seenRefs.contains(ref)) {
          final Transaction tx = _materialise(current, occurrence, ref, at);
          await _transactions.upsert(tx);
          created.add(tx);
          seenRefs.add(ref);
        }
        current = current.copyWith(
          nextRunAt: current.advanceFrom(occurrence),
          updatedAt: at,
        );
        produced++;
      }
      if (current.nextRunAt != rule.nextRunAt) {
        await _rules.upsert(current);
        advanced.add(rule.id);
      }
    }

    return RecurringRunResult(created: created, advancedRuleIds: advanced);
  }

  Transaction _materialise(
    RecurringRule rule,
    DateTime occurrence,
    String ref,
    DateTime now,
  ) {
    final Ulid id = _idFactory?.call() ?? Ulid.now(at: now);
    return Transaction(
      id: id,
      userId: rule.userId,
      accountId: rule.accountId,
      type: rule.type,
      amount: rule.amount,
      categoryId: rule.categoryId,
      occurredAt: occurrence,
      description: rule.description,
      recurringRuleId: rule.id,
      source: rule.source,
      externalRef: ref,
      attachmentIds: const <Ulid>[],
      tagIds: const <Ulid>[],
      createdAt: now,
      updatedAt: now,
    );
  }
}
