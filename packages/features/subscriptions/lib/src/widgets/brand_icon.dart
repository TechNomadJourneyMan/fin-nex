// Resolves a brand/merchant glyph for a detected subscription.
//
// Detection / asset wiring is owned by other agents; this is a lightweight,
// deterministic placeholder that derives a colored monogram from the merchant
// name (with a few well-known glyph overrides keyed by [brandIconKey]).

import 'package:flutter/material.dart';

/// Circular brand avatar showing a known glyph or a colored monogram.
class BrandIcon extends StatelessWidget {
  /// Creates a brand icon for [merchantName].
  const BrandIcon({
    required this.merchantName,
    this.brandIconKey,
    this.size = 40,
    super.key,
  });

  /// Merchant display name, used for the monogram fallback.
  final String merchantName;

  /// Optional key the detector attaches for well-known brands.
  final String? brandIconKey;

  /// Diameter in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final glyph = _glyphFor(brandIconKey);
    final letter = merchantName.trim().isEmpty
        ? '?'
        : merchantName.trim().characters.first.toUpperCase();
    final bg = _bgColor(merchantName);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: glyph != null
          ? Icon(glyph, size: size * 0.5, color: bg)
          : Text(
              letter,
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
                color: bg,
              ),
            ),
    );
  }

  static IconData? _glyphFor(String? key) {
    switch (key) {
      case 'music':
        return Icons.music_note_rounded;
      case 'video':
        return Icons.movie_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'game':
        return Icons.sports_esports_rounded;
      case 'news':
        return Icons.article_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      default:
        return null;
    }
  }

  Color _bgColor(String name) {
    const palette = <Color>[
      Color(0xFF3D5AFE),
      Color(0xFF00A87D),
      Color(0xFFE89500),
      Color(0xFFD9342B),
      Color(0xFF7C4DFF),
      Color(0xFF0066CC),
    ];
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }
}
