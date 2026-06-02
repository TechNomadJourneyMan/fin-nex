// Global command palette (Flutter web / desktop).
//
// Opened via Cmd/Ctrl+K (see app.dart). Presents a search field plus a
// scrollable list of commands filtered by a simple case-insensitive substring
// match — no fuzzy-search package. Arrow keys move the selection; Enter runs
// the highlighted command.
//
// Every command here maps to a capability that already exists elsewhere in the
// app. No placeholders.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_feat_settings/settings.dart' as settings;
import 'package:pf_feat_transactions/transactions.dart' as transactions;

/// A single runnable command in the palette.
class PaletteCommand {
  /// Creates a command.
  const PaletteCommand({
    required this.id,
    required this.label,
    required this.icon,
    required this.run,
  });

  /// Stable identifier (used as a widget key / for tests).
  final String id;

  /// Localized, user-visible label.
  final String label;

  /// Leading glyph.
  final IconData icon;

  /// Invoked when the command is selected. Receives the palette's
  /// [BuildContext] (already popped) and the [WidgetRef].
  final void Function(BuildContext context, WidgetRef ref) run;
}

/// Opens the command palette dialog. Safe to call on any platform; the caller
/// (app.dart) gates it to web/desktop.
Future<void> showCommandPalette(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (BuildContext ctx) => const _CommandPaletteDialog(),
  );
}

/// Builds the localized command set. Kept top-level so tests can assert the
/// catalogue without pumping the dialog.
List<PaletteCommand> buildCommands(AppL10n l10n) {
  return <PaletteCommand>[
    PaletteCommand(
      id: 'add-expense',
      label: l10n.cmdAddExpense,
      icon: Icons.remove_circle_outline,
      run: (BuildContext context, WidgetRef ref) =>
          transactions.openQuickAddExpense(context),
    ),
    PaletteCommand(
      id: 'add-income',
      label: l10n.cmdAddIncome,
      icon: Icons.add_circle_outline,
      run: (BuildContext context, WidgetRef ref) =>
          transactions.openQuickAddIncome(context),
    ),
    PaletteCommand(
      id: 'search-transactions',
      label: l10n.cmdSearchTransactions,
      icon: Icons.search,
      run: (BuildContext context, WidgetRef ref) {
        context.go('/transactions');
        // Bump the focus-request counter so the History search field grabs
        // focus once it (re)mounts.
        ref
            .read(transactions.searchFocusRequestProvider.notifier)
            .update((int v) => v + 1);
      },
    ),
    PaletteCommand(
      id: 'open-dashboard',
      label: l10n.cmdOpenDashboard,
      icon: Icons.dashboard_outlined,
      run: (BuildContext context, WidgetRef ref) => context.go('/home'),
    ),
    PaletteCommand(
      id: 'open-transactions',
      label: l10n.cmdOpenTransactions,
      icon: Icons.receipt_long_outlined,
      run: (BuildContext context, WidgetRef ref) => context.go('/transactions'),
    ),
    PaletteCommand(
      id: 'open-analytics',
      label: l10n.cmdOpenAnalytics,
      icon: Icons.insights_outlined,
      run: (BuildContext context, WidgetRef ref) => context.go('/analytics'),
    ),
    PaletteCommand(
      id: 'open-spending-calendar',
      label: l10n.cmdOpenCalendar,
      icon: Icons.calendar_month_outlined,
      run: (BuildContext context, WidgetRef ref) =>
          context.go('/analytics/calendar'),
    ),
    PaletteCommand(
      id: 'open-settings',
      label: l10n.cmdOpenSettings,
      icon: Icons.settings_outlined,
      run: (BuildContext context, WidgetRef ref) => context.go('/settings'),
    ),
    PaletteCommand(
      id: 'toggle-theme',
      label: l10n.cmdToggleTheme,
      icon: Icons.brightness_6_outlined,
      run: (BuildContext context, WidgetRef ref) {
        final ThemeMode current = ref.read(settings.themeProvider);
        // Flip between light and dark explicitly (the app launches dark).
        final ThemeMode next =
            current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        // ignore: discarded_futures
        ref.read(settings.themeProvider.notifier).set(next);
      },
    ),
    PaletteCommand(
      id: 'switch-language',
      label: l10n.cmdSwitchLanguage,
      icon: Icons.translate_outlined,
      run: (BuildContext context, WidgetRef ref) =>
          context.go('/settings/language'),
    ),
  ];
}

class _CommandPaletteDialog extends ConsumerStatefulWidget {
  const _CommandPaletteDialog();

  @override
  ConsumerState<_CommandPaletteDialog> createState() =>
      _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends ConsumerState<_CommandPaletteDialog> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _fieldFocus = FocusNode();
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fieldFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _query.dispose();
    _fieldFocus.dispose();
    super.dispose();
  }

  List<PaletteCommand> _filtered(AppL10n l10n) {
    final String q = _query.text.trim().toLowerCase();
    final List<PaletteCommand> all = buildCommands(l10n);
    if (q.isEmpty) {
      return all;
    }
    return all
        .where((PaletteCommand c) => c.label.toLowerCase().contains(q))
        .toList(growable: false);
  }

  void _run(PaletteCommand command) {
    Navigator.of(context).pop();
    command.run(context, ref);
  }

  void _move(int delta, int count) {
    if (count == 0) {
      return;
    }
    setState(() {
      _selected = (_selected + delta) % count;
      if (_selected < 0) {
        _selected += count;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final List<PaletteCommand> commands = _filtered(l10n);
    final int clampedSelected =
        commands.isEmpty ? 0 : _selected.clamp(0, commands.length - 1);

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
        child: Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowDown):
                _MoveSelectionIntent(1),
            SingleActivator(LogicalKeyboardKey.arrowUp):
                _MoveSelectionIntent(-1),
            SingleActivator(LogicalKeyboardKey.enter): _RunSelectionIntent(),
            SingleActivator(LogicalKeyboardKey.numpadEnter):
                _RunSelectionIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              _MoveSelectionIntent: CallbackAction<_MoveSelectionIntent>(
                onInvoke: (_MoveSelectionIntent intent) {
                  _move(intent.delta, commands.length);
                  return null;
                },
              ),
              _RunSelectionIntent: CallbackAction<_RunSelectionIntent>(
                onInvoke: (_) {
                  if (commands.isNotEmpty) {
                    _run(commands[clampedSelected]);
                  }
                  return null;
                },
              ),
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _query,
                    focusNode: _fieldFocus,
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.cmdPaletteHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() => _selected = 0),
                    onSubmitted: (_) {
                      if (commands.isNotEmpty) {
                        _run(commands[clampedSelected]);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: commands.length,
                    itemBuilder: (BuildContext ctx, int i) {
                      final PaletteCommand c = commands[i];
                      return ListTile(
                        key: ValueKey<String>('cmd-${c.id}'),
                        leading: Icon(c.icon),
                        title: Text(c.label),
                        selected: i == clampedSelected,
                        selectedTileColor:
                            Theme.of(ctx).colorScheme.primaryContainer,
                        onTap: () => _run(c),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveSelectionIntent extends Intent {
  const _MoveSelectionIntent(this.delta);
  final int delta;
}

class _RunSelectionIntent extends Intent {
  const _RunSelectionIntent();
}
