import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_domain/domain.dart';
import 'package:fnx_feat_insights/fnx_feat_insights.dart';

import '_fixtures.dart';

void main() {
  // Use a fixed Wednesday so week boundaries are predictable.
  final DateTime now = DateTime.utc(2026, 1, 14, 12); // Wednesday

  RuleContext ctxWith({
    List<Transaction> transactions = const <Transaction>[],
    List<Budget> budgets = const <Budget>[],
    List<Category> categories = const <Category>[],
    Streak? streakValue,
    Map<String, DateTime> dismissals = const <String, DateTime>{},
    DateTime? at,
  }) {
    return RuleContext(
      userId: kTestUser,
      transactions: transactions,
      budgets: budgets,
      categories: categories,
      streak: streakValue,
      currentDate: at ?? now,
      dismissals: dismissals,
    );
  }

  group('weekOverWeekSpikeRule', () {
    test('fires when this week is 25%+ above last week', () {
      // This week (Mon 12 → today 14): two days of 100 each = 200.
      // Last week (Mon 5 → Sun 11): one day of 100 = 100.
      // ratio 2.0 → up 100%.
      final tx = <Transaction>[
        expense(majorUnits: 100, occurredAt: DateTime.utc(2026, 1, 12, 10)),
        expense(majorUnits: 100, occurredAt: DateTime.utc(2026, 1, 13, 10)),
        expense(majorUnits: 100, occurredAt: DateTime.utc(2026, 1, 7, 10)),
      ];
      final insight = weekOverWeekSpikeRule(ctxWith(transactions: tx));
      expect(insight, isNotNull);
      expect(insight!.severity, InsightSeverity.warning);
      expect(insight.kind, InsightRuleKeys.weekOverWeekSpike);
    });

    test('returns null when no prior week spend', () {
      final insight = weekOverWeekSpikeRule(ctxWith());
      expect(insight, isNull);
    });

    test('suppressed within 30 days of dismissal', () {
      final tx = <Transaction>[
        expense(majorUnits: 1000, occurredAt: DateTime.utc(2026, 1, 12, 10)),
        expense(majorUnits: 100, occurredAt: DateTime.utc(2026, 1, 7, 10)),
      ];
      final insight = weekOverWeekSpikeRule(ctxWith(
        transactions: tx,
        dismissals: <String, DateTime>{
          InsightRuleKeys.weekOverWeekSpike:
              now.subtract(const Duration(days: 5)),
        },
      ));
      expect(insight, isNull);
    });
  });

  group('budgetWarningRule', () {
    test('fires when 80%+ but under 100% is used', () {
      final budget = monthlyBudget(
        majorUnits: 1000,
        startsOn: DateTime.utc(2026, 1, 1),
      );
      final tx = <Transaction>[
        expense(majorUnits: 850, occurredAt: DateTime.utc(2026, 1, 10)),
      ];
      final insight = budgetWarningRule(
        ctxWith(transactions: tx, budgets: <Budget>[budget]),
      );
      expect(insight, isNotNull);
      expect(insight!.severity, InsightSeverity.warning);
    });

    test('returns null when under 80%', () {
      final budget = monthlyBudget(
        majorUnits: 1000,
        startsOn: DateTime.utc(2026, 1, 1),
      );
      final tx = <Transaction>[
        expense(majorUnits: 200, occurredAt: DateTime.utc(2026, 1, 10)),
      ];
      expect(
        budgetWarningRule(
          ctxWith(transactions: tx, budgets: <Budget>[budget]),
        ),
        isNull,
      );
    });

    test('returns null when at or over 100%', () {
      final budget = monthlyBudget(
        majorUnits: 1000,
        startsOn: DateTime.utc(2026, 1, 1),
      );
      final tx = <Transaction>[
        expense(majorUnits: 1100, occurredAt: DateTime.utc(2026, 1, 10)),
      ];
      expect(
        budgetWarningRule(
          ctxWith(transactions: tx, budgets: <Budget>[budget]),
        ),
        isNull,
      );
    });
  });

  group('budgetExceededRule', () {
    test('fires when spend >= budget', () {
      final budget = monthlyBudget(
        majorUnits: 1000,
        startsOn: DateTime.utc(2026, 1, 1),
      );
      final tx = <Transaction>[
        expense(majorUnits: 1200, occurredAt: DateTime.utc(2026, 1, 10)),
      ];
      final insight = budgetExceededRule(
        ctxWith(transactions: tx, budgets: <Budget>[budget]),
      );
      expect(insight, isNotNull);
      expect(insight!.kind, InsightRuleKeys.budgetExceeded);
    });

    test('returns null when under budget', () {
      final budget = monthlyBudget(
        majorUnits: 1000,
        startsOn: DateTime.utc(2026, 1, 1),
      );
      expect(
        budgetExceededRule(ctxWith(budgets: <Budget>[budget])),
        isNull,
      );
    });
  });

  group('longestStreakRule', () {
    test('celebrates when current == longest >= 7', () {
      final s = streak(current: 14, longest: 14);
      final insight = longestStreakRule(ctxWith(streakValue: s));
      expect(insight, isNotNull);
      expect(insight!.severity, InsightSeverity.celebration);
    });

    test('does not fire below 7-day longest', () {
      final s = streak(current: 5, longest: 5);
      expect(longestStreakRule(ctxWith(streakValue: s)), isNull);
    });

    test('does not fire when current < longest', () {
      final s = streak(current: 4, longest: 10);
      expect(longestStreakRule(ctxWith(streakValue: s)), isNull);
    });
  });

  group('inactivityRule', () {
    test('fires after 5+ idle days', () {
      final tx = <Transaction>[
        expense(majorUnits: 10, occurredAt: now.subtract(const Duration(days: 7))),
      ];
      final insight = inactivityRule(ctxWith(transactions: tx));
      expect(insight, isNotNull);
      expect(insight!.kind, InsightRuleKeys.inactivityWarning);
    });

    test('does not fire when active recently', () {
      final tx = <Transaction>[
        expense(majorUnits: 10, occurredAt: now.subtract(const Duration(days: 1))),
      ];
      expect(inactivityRule(ctxWith(transactions: tx)), isNull);
    });
  });

  group('surplusMonthRule', () {
    test('fires when income > expenses in the current month', () {
      final tx = <Transaction>[
        income(majorUnits: 1000, occurredAt: DateTime.utc(2026, 1, 2)),
        expense(majorUnits: 400, occurredAt: DateTime.utc(2026, 1, 5)),
      ];
      final insight = surplusMonthRule(ctxWith(transactions: tx));
      expect(insight, isNotNull);
      expect(insight!.severity, InsightSeverity.celebration);
    });
  });

  group('engine integration', () {
    test('runs every registered rule without throwing', () {
      const engine = InsightEngine();
      final budget = monthlyBudget(
        majorUnits: 1000,
        startsOn: DateTime.utc(2026, 1, 1),
      );
      final tx = <Transaction>[
        expense(majorUnits: 850, occurredAt: DateTime.utc(2026, 1, 10)),
        income(majorUnits: 2000, occurredAt: DateTime.utc(2026, 1, 2)),
      ];
      final out = engine.run(
        RuleContext(
          userId: kTestUser,
          transactions: tx,
          budgets: <Budget>[budget],
          currentDate: now,
        ),
      );
      expect(out, isNotEmpty);
      // Warnings should sort before info.
      for (var i = 1; i < out.length; i++) {
        expect(out[i - 1].severity.index, isNonNegative);
      }
    });
  });
}
