/// Public API for the PocketFlow insights feature module.
///
/// Exposes the insight engine, individual pure rules, the feed page widget,
/// and Riverpod providers used to wire the feature into the app shell.
library pf_feat_insights;

export 'src/controllers/insights_controller.dart';
export 'src/engine/insight_engine.dart';
export 'src/engine/insight_rules.dart';
export 'src/engine/rule_context.dart';
export 'src/pages/insights_feed_page.dart';
export 'src/providers.dart';
