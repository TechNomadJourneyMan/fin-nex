// App-level keyboard intents.
//
// Wired in [PocketFlowApp] via a top-level Shortcuts/Actions wrapper so they
// fire app-wide on web/desktop. Cmd/Ctrl+K opens the global command palette;
// Esc is handled by Flutter's built-in [DismissIntent], which closes open
// dialogs and bottom sheets.

import 'package:flutter/widgets.dart';

/// Fired by Cmd+K / Ctrl+K to open the global command palette.
class OpenCommandPaletteIntent extends Intent {
  /// Const constructor.
  const OpenCommandPaletteIntent();
}

/// Default action for [OpenCommandPaletteIntent].
///
/// Delegates to [onOpen], supplied by [PocketFlowApp], which shows the command
/// palette dialog rooted at the app's navigator. Guarded against repeat-fire
/// while a palette is already open.
class OpenCommandPaletteAction extends Action<OpenCommandPaletteIntent> {
  /// Creates the action with the palette-launch callback.
  OpenCommandPaletteAction(this.onOpen);

  /// Opens the palette. Provided by the app so it can reach a navigator
  /// context and the Riverpod container.
  final VoidCallback onOpen;

  @override
  Object? invoke(OpenCommandPaletteIntent intent) {
    onOpen();
    return null;
  }
}
