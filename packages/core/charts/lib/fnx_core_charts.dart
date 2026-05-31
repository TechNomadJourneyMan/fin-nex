// Public API for FinNex chart primitives.
//
// Thin, opinionated wrappers around `fl_chart` plus a few custom-painted
// pieces (heatmap, sparkline) tuned to the FinNex design system.
//
// All charts:
//  * Respect `MediaQuery.disableAnimations` (reduced-motion).
//  * Use [intl] `NumberFormat` for axis/tooltip labels.
//  * Render on Flutter Web without native dependencies.

library fnx_core_charts;

export 'src/fnx_bar_chart.dart';
export 'src/fnx_chart_empty.dart';
export 'src/fnx_chart_legend.dart';
export 'src/fnx_chart_palette.dart';
export 'src/fnx_donut_chart.dart';
export 'src/fnx_heatmap_calendar.dart';
export 'src/fnx_line_chart.dart';
export 'src/fnx_sparkline.dart';
export 'src/fnx_stacked_bar_chart.dart';
