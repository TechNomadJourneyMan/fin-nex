import 'package:pf_domain/pf_domain.dart';

/// Stable calendar `sourceId` for a recurring [rule], so reminder events stay
/// idempotent across re-syncs (mirrors `subscription:<id>`).
String recurringSourceId(Ulid ruleId) => 'recurring-rule:${ruleId.value}';
