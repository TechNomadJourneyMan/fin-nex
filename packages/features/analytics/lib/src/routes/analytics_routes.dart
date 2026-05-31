import 'package:flutter/widgets.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:go_router/go_router.dart';

import '../pages/analytics_page.dart';
import '../pages/calendar_view_page.dart';
import '../pages/category_detail_page.dart';

/// Named-route constants for the analytics feature.
abstract final class AnalyticsRouteNames {
  /// Root analytics screen.
  static const String analytics = 'analytics';

  /// Drill-down into a single category for the active period.
  static const String analyticsCategory = 'analytics-category';

  /// Calendar / heatmap variant of analytics.
  static const String analyticsCalendar = 'analytics-calendar';
}

/// Path constants — handy when composing deep links.
abstract final class AnalyticsRoutePaths {
  /// `/analytics`.
  static const String analytics = '/analytics';

  /// `/analytics/category/:id`.
  static const String analyticsCategory = '/analytics/category/:id';

  /// `/analytics/calendar`.
  static const String analyticsCalendar = '/analytics/calendar';

  /// Builds a concrete `/analytics/category/<id>` path.
  static String categoryFor(Ulid id) => '/analytics/category/${id.value}';
}

/// go_router routes contributed by the analytics feature.
///
/// Compose into the app router with:
/// ```dart
/// GoRouter(routes: [...analyticsRoutes, ...]);
/// ```
final List<RouteBase> analyticsRoutes = <RouteBase>[
  GoRoute(
    path: AnalyticsRoutePaths.analytics,
    name: AnalyticsRouteNames.analytics,
    builder: (BuildContext context, GoRouterState state) =>
        const AnalyticsPage(),
    routes: <RouteBase>[
      GoRoute(
        path: 'category/:id',
        name: AnalyticsRouteNames.analyticsCategory,
        builder: (BuildContext context, GoRouterState state) {
          final String? raw = state.pathParameters['id'];
          final Ulid? id = raw == null ? null : Ulid(raw);
          return CategoryDetailPage(categoryId: id);
        },
      ),
      GoRoute(
        path: 'calendar',
        name: AnalyticsRouteNames.analyticsCalendar,
        builder: (BuildContext context, GoRouterState state) =>
            const CalendarViewPage(),
      ),
    ],
  ),
];
