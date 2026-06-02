/// Public API for the PocketFlow analytics feature module.
///
/// Exposes:
///  * [AnalyticsPeriod] — selectable Day/Week/Month/Year/Custom range.
///  * [AnalyticsSummary] — value type holding totals + chart data.
///  * Providers and the [AnalyticsController] AsyncNotifier.
///  * Pages — [AnalyticsPage], [CategoryDetailPage], [CalendarViewPage].
///  * [analyticsRoutes] for go_router composition.
library pf_feat_analytics;

export 'src/analytics_summary.dart';
export 'src/controllers/analytics_controller.dart';
export 'src/pages/analytics_page.dart';
export 'src/pages/calendar_view_page.dart';
export 'src/pages/category_detail_page.dart';
export 'src/pages/spending_calendar_page.dart';
export 'src/providers.dart';
export 'src/routes/analytics_routes.dart';
export 'src/state/analytics_period.dart';
