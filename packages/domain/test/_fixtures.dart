import 'package:fnx_domain/domain.dart';

/// Deterministic, hand-rolled fixtures for use-case tests.
class Fixtures {
  Fixtures._();

  /// A stable user ULID used across tests.
  static final Ulid userId = Ulid('01HXKVZ8R3M4N5P6Q7S8T9V0W1');

  /// A stable account ULID used across tests.
  static final Ulid accountId = Ulid('01HXKVZ8R3M4N5P6Q7S8T9V0W2');

  /// A stable category ULID used across tests.
  static final Ulid categoryId = Ulid('01HXKVZ8R3M4N5P6Q7S8T9V0W3');

  /// A KZT amount of [majorUnits] tenge.
  static Money kzt(int majorUnits) =>
      Money.major(majorUnits, Currency.kzt);

  /// Builds a sample expense [Transaction] with a given amount.
  static Transaction expense({
    required Ulid id,
    Money? amount,
    DateTime? at,
  }) =>
      Transaction(
        id: id,
        userId: userId,
        accountId: accountId,
        type: TransactionType.expense,
        amount: amount ?? kzt(1000),
        categoryId: categoryId,
        occurredAt: at ?? DateTime.utc(2026, 5, 31),
        createdAt: DateTime.utc(2026, 5, 31),
        updatedAt: DateTime.utc(2026, 5, 31),
        source: 'manual',
        attachmentIds: const <Ulid>[],
        tagIds: const <Ulid>[],
      );

  /// Builds a monthly category budget for testing alerts.
  static Budget budget({
    required Ulid id,
    Money? amount,
    List<int> alertThresholds = const <int>[80, 100],
  }) =>
      Budget(
        id: id,
        userId: userId,
        name: 'Food',
        period: BudgetPeriod.monthly,
        amount: amount ?? kzt(50000),
        startsOn: DateTime.utc(2026, 5, 1),
        alertThresholds: alertThresholds,
        rolloverUnspent: false,
        isActive: true,
        categoryIds: <Ulid>[categoryId],
        createdAt: DateTime.utc(2026, 5, 1),
        updatedAt: DateTime.utc(2026, 5, 1),
      );
}
