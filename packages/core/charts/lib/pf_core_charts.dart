// Public API for PocketFlow chart primitives.
//
// Thin, opinionated wrappers around `fl_chart` plus a few custom-painted
// pieces (heatmap, sparkline) tuned to the PocketFlow design system.
//
// All charts:
//  * Respect `MediaQuery.disableAnimations` (reduced-motion).
//  * Use [intl] `NumberFormat` for axis/tooltip labels.
//  * Render on Flutter Web without native dependencies.

library pf_core_charts;

export 'src/pf_bar_chart.dart';
export 'src/pf_chart_empty.dart';
export 'src/pf_chart_legend.dart';
export 'src/pf_chart_palette.dart';
export 'src/pf_donut_chart.dart';
export 'src/pf_heatmap_calendar.dart';
export 'src/pf_line_chart.dart';
export 'src/pf_sparkline.dart';
export 'src/pf_stacked_bar_chart.dart';
