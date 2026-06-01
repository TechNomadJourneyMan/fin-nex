// Settings root — list of sections (Profile, Appearance, Language,
// Privacy, Notifications, Data, About). Each tile routes to its dedicated
// page so deep-links can target individual settings.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import '../widgets/sound_haptics_section.dart';

/// Settings hub page. Routed at `/settings`.
class SettingsRootPage extends ConsumerWidget {
  /// Default constructor.
  const SettingsRootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final router = GoRouter.maybeOf(context);
    final bool highContrast = ref.watch(highContrastProvider);

    final sections = <_SectionData>[
      _SectionData(
        icon: Icons.person_outline,
        title: l10n.setProfile,
        route: '/settings/profile',
      ),
      _SectionData(
        icon: Icons.palette_outlined,
        title: l10n.setAppearance,
        route: '/settings/appearance',
      ),
      _SectionData(
        icon: Icons.language_outlined,
        title: l10n.setLanguage,
        route: '/settings/language',
      ),
      _SectionData(
        icon: Icons.lock_outline,
        title: l10n.setSecurity,
        route: '/settings/privacy',
      ),
      _SectionData(
        icon: Icons.notifications_none,
        title: l10n.setNotifications,
        route: '/settings/notifications',
      ),
      _SectionData(
        icon: Icons.cloud_download_outlined,
        title: l10n.setData,
        route: '/settings/data',
      ),
      const _SectionData(
        icon: Icons.memory,
        title: 'Локальная модель (Gemma)',
        route: '/settings/local-llm',
      ),
      _SectionData(
        icon: Icons.info_outline,
        title: l10n.setAbout,
        route: '/settings/about',
      ),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.setTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: <Widget>[
            // New "Sound & Haptics" section sits above the routed-section
            // list so it's immediately discoverable on first open.
            const SoundHapticsSection(),
            // Accessibility section: toggles that apply app-wide (sits under
            // the Appearance grouping; uses a distinct "Accessibility" header
            // so it doesn't collide with the routed Appearance tile).
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.setAccessibility,
                style: typo.bodySm.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            SwitchListTile(
              key: const Key('settings.appearance.highContrast'),
              title: Text(l10n.setHighContrast),
              subtitle: Text(l10n.setHighContrastDesc),
              value: highContrast,
              onChanged: (bool v) {
                // ignore: discarded_futures
                ref.read(highContrastProvider.notifier).set(v);
              },
            ),
            Divider(
              height: 1,
              color: colors.divider,
              indent: 16,
              endIndent: 16,
            ),
            for (int i = 0; i < sections.length; i++) ...<Widget>[
              PfListItem(
                leading: Icon(sections[i].icon, color: colors.textSecondary),
                title: sections[i].title,
                trailing: Icon(
                  Icons.chevron_right,
                  color: colors.textMuted,
                ),
                onTap: router == null
                    ? null
                    : () => router.push(sections[i].route),
                semanticLabel: sections[i].title,
              ),
              if (i < sections.length - 1)
                Divider(
                  height: 1,
                  color: colors.divider,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.appName,
            textAlign: TextAlign.center,
            style: typo.bodySm.copyWith(color: colors.textMuted),
          ),
        ),
      ),
    );
  }
}

class _SectionData {
  const _SectionData({
    required this.icon,
    required this.title,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String route;
}
