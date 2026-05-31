import 'package:fnx_domain/domain.dart';

/// Test helpers shared by the insights test suite.

/// Synthetic but valid user id.
final Ulid kTestUser = Ulid.now();

/// Synthetic account id.
final Ulid kTestAccount = Ulid.now();

/// Builds a deterministic expense [Transaction].
Transaction expense({
  required int majorUnits,
  required DateTime occurredAt,
  Ulid? categoryId,
  String? description,
  Currency currency = Currency.kzt,
}) {
  return Transaction(
    id: Ulid.now(),
    userId: kTestUser,
    accountId: kTestAccount,
    type: TransactionType.expense,
    amount: Money.major(majorUnits, currency),
    categoryId: categoryId,
    occurredAt: occurredAt.toUtc(),
    description: description,
    source: 'test',
    attachmentIds: const <Ulid>[],
    tagIds: const <Ulid>[],
    createdAt: occurredAt.toUtc(),
    updatedAt: occurredAt.toUtc(),
  );
}

/// Builds a deterministic income [Transaction].
Transaction income({
  required int majorUnits,
  required DateTime occurredAt,
  Currency currency = Currency.kzt,
}) {
  return Transaction(
    id: Ulid.now(),
    userId: kTestUser,
    accountId: kTestAccount,
    type: TransactionType.income,
    amount: Money.major(majorUnits, currency),
    occurredAt: occurredAt.toUtc(),
    source: 'test',
    attachmentIds: const <Ulid>[],
    tagIds: const <Ulid>[],
    createdAt: occurredAt.toUtc(),
    updatedAt: occurredAt.toUtc(),
  );
}

/// Builds a deterministic monthly [Budget].
Budget monthlyBudget({
  required int majorUnits,
  required DateTime startsOn,
  String name = 'Monthly',
  List<Ulid> categoryIds = const <Ulid>[],
  Currency currency = Currency.kzt,
}) {
  return Budget(
    id: Ulid.now(),
    userId: kTestUser,
    name: name,
    period: BudgetPeriod.monthly,
    amount: Money.major(majorUnits, currency),
    categoryIds: categoryIds,
    startsOn: startsOn.toUtc(),
    alertThresholds: const <int>[50, 80, 100],
    rolloverUnspent: false,
    isActive: true,
    createdAt: startsOn.toUtc(),
    updatedAt: startsOn.toUtc(),
  );
}

/// Builds a deterministic [Category].
Category category(String name) {
  final now = DateTime.now().toUtc();
  return Category(
    id: Ulid.now(),
    type: CategoryType.expense,
    name: name,
    iconKey: 'shopping_bag',
    color: CategoryColor.neutral,
    isSystem: false,
    isArchived: false,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

/// Builds a deterministic [Streak].
Streak streak({
  required int current,
  required int longest,
}) {
  final now = DateTime.now().toUtc();
  return Streak(
    userId: kTestUser,
    currentStreakDays: current,
    longestStreakDays: longest,
    totalActiveDays: longest,
    updatedAt: now,
  );
}
