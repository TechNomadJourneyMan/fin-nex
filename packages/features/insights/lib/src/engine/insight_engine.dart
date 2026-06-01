import 'package:pf_domain/domain.dart';

import 'insight_rules.dart';
import 'rule_context.dart';

/// Pure Dart engine that runs every registered rule and returns the resulting
/// insights, ordered by severity. Safe to call from any isolate.
class InsightEngine {
  /// Default constructor — accepts an optional override of the rule set.
  const InsightEngine({List<InsightRule>? rules})
      : _rules = rules ?? kAllInsightRules;

  final List<InsightRule> _rules;

  /// Runs every rule and returns the non-null results, sorted with warnings
  /// first.
  List<Insight> run(RuleContext context) {
    final out = <Insight>[];
    for (final rule in _rules) {
      final insight = rule(context);
      if (insight != null) {
        out.add(insight);
      }
    }
    out.sort((a, b) => _severityRank(b.severity).compareTo(
          _severityRank(a.severity),
        ));
    return out;
  }

  int _severityRank(InsightSeverity s) {
    switch (s) {
      case InsightSeverity.warning:
        return 3;
      case InsightSeverity.tip:
        return 2;
      case InsightSeverity.celebration:
        return 1;
      case InsightSeverity.info:
        return 0;
    }
  }
}
