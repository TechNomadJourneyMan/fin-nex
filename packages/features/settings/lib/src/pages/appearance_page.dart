// Settings → Appearance.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

import '../providers.dart';

/// Appearance page — pick the [ThemeMode].
class AppearancePage extends ConsumerWidget {
  /// Default constructor.
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final theme = ref.watch(themeProvider);
    final ctl = ref.read(themeProvider.notifier);

    final options = <_ThemeChoice>[
      _ThemeChoice(label: l10n.setThemeSystem, mode: ThemeMode.system),
      _ThemeChoice(label: l10n.setThemeLight, mode: ThemeMode.light),
      _ThemeChoice(label: l10n.setThemeDark, mode: ThemeMode.dark),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.setAppearance)),
      body: SafeArea(
        child: ListView(
          children: [
            for (final option in options)
              RadioListTile<ThemeMode>(
                value: option.mode,
                groupValue: theme,
                onChanged: (next) {
                  if (next != null) ctl.set(next);
                },
                title: Text(option.label),
                activeColor: colors.brand,
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChoice {
  const _ThemeChoice({required this.label, required this.mode});

  final String label;
  final ThemeMode mode;
}
