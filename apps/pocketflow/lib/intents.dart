// App-level keyboard intents.
//
// Wired in [PocketFlowApp] via a top-level Shortcuts/Actions wrapper so they
// fire app-wide on web/desktop. The command-palette handler is a stub for now
// (full implementation lands in Prompt 6); Esc is handled by Flutter's
// built-in [DismissIntent], which closes open dialogs and bottom sheets.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Fired by Cmd+K / Ctrl+K to open the global command palette.
class OpenCommandPaletteIntent extends Intent {
  /// Const constructor.
  const OpenCommandPaletteIntent();
}

/// Default action for [OpenCommandPaletteIntent].
///
/// Stubbed: logs in debug builds. Prompt 6 replaces [onInvoke] with the real
/// palette-launch logic (likely via a router push or an overlay).
class OpenCommandPaletteAction extends Action<OpenCommandPaletteIntent> {
  /// Const constructor.
  OpenCommandPaletteAction();

  @override
  Object? invoke(OpenCommandPaletteIntent intent) {
    // TODO(F-CMDK): open the command palette (Prompt 6).
    if (kDebugMode) {
      debugPrint('OpenCommandPaletteIntent invoked (Cmd/Ctrl+K) — stub.');
    }
    return null;
  }
}
