// Settings → Language. Native labels for each locale.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

import '../providers.dart';

/// Language picker page.
class LanguagePage extends ConsumerWidget {
  /// Default constructor.
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final locale = ref.watch(localeProvider);
    final ctl = ref.read(localeProvider.notifier);

    // Native names so the option is recognisable regardless of UI locale.
    final options = <_LanguageChoice>[
      _LanguageChoice(
        nativeName: 'Русский',
        localizedName: l10n.setLanguageRu,
        locale: const Locale('ru'),
      ),
      _LanguageChoice(
        nativeName: 'Қазақша',
        localizedName: l10n.setLanguageKk,
        locale: const Locale('kk'),
      ),
      _LanguageChoice(
        nativeName: 'English',
        localizedName: l10n.setLanguageEn,
        locale: const Locale('en'),
      ),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.setLanguage)),
      body: SafeArea(
        child: ListView(
          children: [
            for (final option in options)
              RadioListTile<Locale>(
                value: option.locale,
                groupValue: locale,
                onChanged: (next) {
                  if (next != null) ctl.set(next);
                },
                title: Text(option.nativeName),
                subtitle: option.nativeName == option.localizedName
                    ? null
                    : Text(option.localizedName),
                activeColor: colors.brand,
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChoice {
  const _LanguageChoice({
    required this.nativeName,
    required this.localizedName,
    required this.locale,
  });

  final String nativeName;
  final String localizedName;
  final Locale locale;
}
