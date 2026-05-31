/// Public API for the FinNex dashboard feature.
///
/// Re-exports the page, controller, providers and supporting widgets so
/// the app can wire routes with a single import.
library fnx_feat_dashboard;

export 'src/controllers/dashboard_controller.dart';
export 'src/pages/dashboard_page.dart';
export 'src/providers.dart';
export 'src/widgets/balance_card.dart';
export 'src/widgets/insight_banner.dart';
export 'src/widgets/quick_stats_card.dart';
export 'src/widgets/recent_transactions_list.dart';
export 'src/widgets/top_categories_pie.dart';
