/// Feature-local presentation entities describing inline data-visualisation
/// widgets the AI can attach to a reply.
///
/// These intentionally live inside the feature package (not `fnx_domain`)
/// because they describe *presentation* contracts between the backend AI
/// service and this page, not core business entities.
library;

import 'package:flutter/foundation.dart';

/// A serialisable description of an inline widget the AI attaches to a reply.
///
/// The backend returns a discriminated-union JSON object with a `type` field;
/// [WidgetSpec.fromJson] dispatches to the matching subtype.
@immutable
sealed class WidgetSpec {
  /// Const base constructor.
  const WidgetSpec({this.title});

  /// Optional caption rendered above the widget.
  final String? title;

  /// Deserialises a widget spec from its discriminated-union JSON form.
  ///
  /// Returns `null` for unknown/malformed specs so a single bad widget never
  /// breaks an otherwise-valid AI reply.
  static WidgetSpec? fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'bar_chart':
        return BarChartSpec.fromJson(json);
      case 'line_chart':
        return LineChartSpec.fromJson(json);
      case 'progress_bar':
        return ProgressBarSpec.fromJson(json);
      default:
        return null;
    }
  }

  /// Serialises this spec back to its discriminated-union JSON form.
  Map<String, dynamic> toJson();
}

/// A single labelled value in a [BarChartSpec].
@immutable
class BarChartBar {
  /// Default constructor.
  const BarChartBar({required this.label, required this.value});

  /// Builds a bar from JSON.
  factory BarChartBar.fromJson(Map<String, dynamic> json) => BarChartBar(
        label: json['label'] as String? ?? '',
        value: (json['value'] as num?)?.toDouble() ?? 0,
      );

  /// X-axis label.
  final String label;

  /// Bar height (display units, e.g. major currency units).
  final double value;

  /// JSON form.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'label': label,
        'value': value,
      };

  @override
  bool operator ==(Object other) =>
      other is BarChartBar && other.label == label && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);
}

/// An inline grouped/simple bar chart.
@immutable
class BarChartSpec extends WidgetSpec {
  /// Default constructor.
  const BarChartSpec({required this.bars, super.title});

  /// Builds from JSON.
  factory BarChartSpec.fromJson(Map<String, dynamic> json) => BarChartSpec(
        title: json['title'] as String?,
        bars: <BarChartBar>[
          for (final dynamic b in (json['bars'] as List<dynamic>? ?? const []))
            BarChartBar.fromJson(b as Map<String, dynamic>),
        ],
      );

  /// Ordered bars.
  final List<BarChartBar> bars;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': 'bar_chart',
        if (title != null) 'title': title,
        'bars': <Map<String, dynamic>>[
          for (final BarChartBar b in bars) b.toJson(),
        ],
      };

  @override
  bool operator ==(Object other) =>
      other is BarChartSpec &&
      other.title == title &&
      listEquals(other.bars, bars);

  @override
  int get hashCode => Object.hash(title, Object.hashAll(bars));
}

/// A single point in a [LineChartSpec].
@immutable
class LineChartPoint {
  /// Default constructor.
  const LineChartPoint({required this.x, required this.y, this.label});

  /// Builds a point from JSON.
  factory LineChartPoint.fromJson(Map<String, dynamic> json) => LineChartPoint(
        x: (json['x'] as num?)?.toDouble() ?? 0,
        y: (json['y'] as num?)?.toDouble() ?? 0,
        label: json['label'] as String?,
      );

  /// X coordinate.
  final double x;

  /// Y value.
  final double y;

  /// Optional X-axis label.
  final String? label;

  /// JSON form.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'x': x,
        'y': y,
        if (label != null) 'label': label,
      };

  @override
  bool operator ==(Object other) =>
      other is LineChartPoint &&
      other.x == x &&
      other.y == y &&
      other.label == label;

  @override
  int get hashCode => Object.hash(x, y, label);
}

/// An inline single-series line chart.
@immutable
class LineChartSpec extends WidgetSpec {
  /// Default constructor.
  const LineChartSpec({
    required this.points,
    this.seriesName = '',
    super.title,
  });

  /// Builds from JSON.
  factory LineChartSpec.fromJson(Map<String, dynamic> json) => LineChartSpec(
        title: json['title'] as String?,
        seriesName: json['series_name'] as String? ?? '',
        points: <LineChartPoint>[
          for (final dynamic p
              in (json['points'] as List<dynamic>? ?? const []))
            LineChartPoint.fromJson(p as Map<String, dynamic>),
        ],
      );

  /// Series legend name.
  final String seriesName;

  /// Ordered points.
  final List<LineChartPoint> points;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': 'line_chart',
        if (title != null) 'title': title,
        'series_name': seriesName,
        'points': <Map<String, dynamic>>[
          for (final LineChartPoint p in points) p.toJson(),
        ],
      };

  @override
  bool operator ==(Object other) =>
      other is LineChartSpec &&
      other.title == title &&
      other.seriesName == seriesName &&
      listEquals(other.points, points);

  @override
  int get hashCode => Object.hash(title, seriesName, Object.hashAll(points));
}

/// An inline labelled progress bar (e.g. "budget used 70%").
@immutable
class ProgressBarSpec extends WidgetSpec {
  /// Default constructor.
  const ProgressBarSpec({
    required this.value,
    required this.max,
    this.label,
    super.title,
  });

  /// Builds from JSON.
  factory ProgressBarSpec.fromJson(Map<String, dynamic> json) =>
      ProgressBarSpec(
        title: json['title'] as String?,
        label: json['label'] as String?,
        value: (json['value'] as num?)?.toDouble() ?? 0,
        max: (json['max'] as num?)?.toDouble() ?? 1,
      );

  /// Inline label rendered next to the percentage.
  final String? label;

  /// Current value.
  final double value;

  /// Maximum value (denominator).
  final double max;

  /// Clamped fraction in `[0, 1]`.
  double get fraction => max <= 0 ? 0 : (value / max).clamp(0.0, 1.0);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': 'progress_bar',
        if (title != null) 'title': title,
        if (label != null) 'label': label,
        'value': value,
        'max': max,
      };

  @override
  bool operator ==(Object other) =>
      other is ProgressBarSpec &&
      other.title == title &&
      other.label == label &&
      other.value == value &&
      other.max == max;

  @override
  int get hashCode => Object.hash(title, label, value, max);
}
