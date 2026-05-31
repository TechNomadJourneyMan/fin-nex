import 'package:equatable/equatable.dart';

/// A 24-bit RGB color encoded as a `#RRGGBB` hex string.
///
/// Domain-layer wrapper so we don't depend on `dart:ui` / Flutter `Color`.
class CategoryColor extends Equatable {
  /// Parses a `#RRGGBB` (or `RRGGBB`) string.
  factory CategoryColor(String hex) {
    var v = hex.trim();
    if (v.startsWith('#')) {
      v = v.substring(1);
    }
    if (v.length != 6) {
      throw ArgumentError.value(hex, 'hex', 'Must be #RRGGBB');
    }
    if (int.tryParse(v, radix: 16) == null) {
      throw ArgumentError.value(hex, 'hex', 'Not valid hexadecimal');
    }
    return CategoryColor._('#${v.toUpperCase()}');
  }

  const CategoryColor._(this.hex);

  /// Default neutral grey used when a category has no explicit color.
  static const CategoryColor neutral = CategoryColor._('#888888');

  /// Canonical `#RRGGBB` representation.
  final String hex;

  /// Red channel (0–255).
  int get red => int.parse(hex.substring(1, 3), radix: 16);

  /// Green channel (0–255).
  int get green => int.parse(hex.substring(3, 5), radix: 16);

  /// Blue channel (0–255).
  int get blue => int.parse(hex.substring(5, 7), radix: 16);

  @override
  String toString() => hex;

  @override
  List<Object?> get props => <Object?>[hex];
}
