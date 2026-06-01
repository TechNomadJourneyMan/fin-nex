import 'package:flutter/material.dart';

/// PocketFlow elevation tokens — two-layer (ambient + key) shadows.
///
/// Light mode uses cool-grey shadows; dark mode uses near-black with
/// reduced opacity, matched with surface-elevation overlays in the
/// theme layer.
@immutable
class PfElevation extends ThemeExtension<PfElevation> {
  /// Const constructor — values are static.
  const PfElevation();

  static const Color _lightAmbient = Color(0x0F101828); // rgba(16,24,40,0.06)
  static const Color _lightAmbientStrong = Color(0x14101828); // 0.08
  static const Color _lightAmbientLouder = Color(0x1A101828); // 0.10
  static const Color _lightAmbientLoudest = Color(0x1F101828); // 0.12
  static const Color _lightAmbientMax = Color(0x24101828); // 0.14
  static const Color _lightAmbientUlt = Color(0x29101828); // 0.16

  static const Color _darkShadow40 = Color(0x66000000);
  static const Color _darkShadow50 = Color(0x80000000);
  static const Color _darkShadow55 = Color(0x8C000000);
  static const Color _darkShadow60 = Color(0x99000000);
  static const Color _darkShadow65 = Color(0xA6000000);

  /// Flat — no shadow.
  static const List<BoxShadow> e0Light = <BoxShadow>[];
  /// Cards (default) — elevation 1, light.
  static const List<BoxShadow> e1Light = <BoxShadow>[
    BoxShadow(color: _lightAmbient, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: _lightAmbientLouder, offset: Offset(0, 1), blurRadius: 3),
  ];
  /// Raised cards / dropdowns — elevation 2, light.
  static const List<BoxShadow> e2Light = <BoxShadow>[
    BoxShadow(color: _lightAmbient, offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(
      color: _lightAmbientStrong,
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];
  /// Bottom sheets / modals — elevation 3, light.
  static const List<BoxShadow> e3Light = <BoxShadow>[
    BoxShadow(
      color: _lightAmbientStrong,
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: _lightAmbientLouder,
      offset: Offset(0, 8),
      blurRadius: 16,
    ),
  ];
  /// Dialogs / popovers — elevation 4, light.
  static const List<BoxShadow> e4Light = <BoxShadow>[
    BoxShadow(
      color: _lightAmbientLouder,
      offset: Offset(0, 8),
      blurRadius: 16,
    ),
    BoxShadow(
      color: _lightAmbientLoudest,
      offset: Offset(0, 16),
      blurRadius: 24,
    ),
  ];
  /// Floating overlays / menus — elevation 5, light.
  static const List<BoxShadow> e5Light = <BoxShadow>[
    BoxShadow(
      color: _lightAmbientMax,
      offset: Offset(0, 12),
      blurRadius: 24,
    ),
    BoxShadow(
      color: _lightAmbientUlt,
      offset: Offset(0, 24),
      blurRadius: 48,
    ),
  ];

  /// Flat — no shadow (dark).
  static const List<BoxShadow> e0Dark = <BoxShadow>[];
  /// Cards (default) — elevation 1, dark.
  static const List<BoxShadow> e1Dark = <BoxShadow>[
    BoxShadow(color: _darkShadow40, offset: Offset(0, 1), blurRadius: 2),
  ];
  /// Raised cards — elevation 2, dark.
  static const List<BoxShadow> e2Dark = <BoxShadow>[
    BoxShadow(color: _darkShadow50, offset: Offset(0, 2), blurRadius: 4),
  ];
  /// Sheets — elevation 3, dark.
  static const List<BoxShadow> e3Dark = <BoxShadow>[
    BoxShadow(color: _darkShadow55, offset: Offset(0, 4), blurRadius: 8),
  ];
  /// Dialogs — elevation 4, dark.
  static const List<BoxShadow> e4Dark = <BoxShadow>[
    BoxShadow(color: _darkShadow60, offset: Offset(0, 8), blurRadius: 16),
  ];
  /// Overlays — elevation 5, dark.
  static const List<BoxShadow> e5Dark = <BoxShadow>[
    BoxShadow(color: _darkShadow65, offset: Offset(0, 12), blurRadius: 24),
  ];

  /// Light shadow ladder (index 0..5).
  static const List<List<BoxShadow>> lightLadder = <List<BoxShadow>>[
    e0Light,
    e1Light,
    e2Light,
    e3Light,
    e4Light,
    e5Light,
  ];

  /// Dark shadow ladder (index 0..5).
  static const List<List<BoxShadow>> darkLadder = <List<BoxShadow>>[
    e0Dark,
    e1Dark,
    e2Dark,
    e3Dark,
    e4Dark,
    e5Dark,
  ];

  @override
  PfElevation copyWith() => const PfElevation();

  @override
  PfElevation lerp(ThemeExtension<PfElevation>? other, double t) => this;
}
