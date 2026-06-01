import 'package:flutter/foundation.dart' hide Category;
import 'package:pf_domain/domain.dart';

/// Inputs handed to every insight rule.
@immutable
class RuleContext {
  /// Default constructor.
  const RuleContext({
    required this.userId,
    required this.transactions,
    required this.budgets,
    required this.currentDate,
    this.categories = const <Category>[],
    this.streak,
    this.dismissals = const <String, DateTime>{},
  });

  /// Owning user.
  final Ulid userId;

  /// All non-deleted transactions in scope (typically last 180 days).
  final List<Transaction> transactions;

  /// All active budgets.
  final List<Budget> budgets;

  /// Optional category lookup for naming.
  final List<Category> categories;

  /// Optional streak data.
  final Streak? streak;

  /// Map of `ruleKey -> dismissedAt` used to suppress regeneration for 30 days.
  final Map<String, DateTime> dismissals;

  /// "Now" for time-dependent rules (UTC).
  final DateTime currentDate;

  /// Looks up [Category.name] by id, falling back to a sensible default.
  String categoryName(Ulid? id) {
    if (id == null) {
      return 'Uncategorized';
    }
    for (final c in categories) {
      if (c.id == id) {
        return c.name;
      }
    }
    return 'Category';
  }

  /// Returns `true` when [ruleKey] has been dismissed within the last 30 days.
  bool isSuppressed(String ruleKey) {
    final dismissedAt = dismissals[ruleKey];
    if (dismissedAt == null) {
      return false;
    }
    final age = currentDate.difference(dismissedAt);
    return age.inDays < 30;
  }
}
