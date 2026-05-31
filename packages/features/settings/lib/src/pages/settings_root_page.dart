// Settings root — list of sections (Profile, Appearance, Language,
// Privacy, Notifications, Data, About). Each tile routes to its dedicated
// page so deep-links can target individual settings.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:go_router/go_router.dart';

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
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sections.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: colors.divider,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final s = sections[index];
            return FnxListItem(
              leading: Icon(s.icon, color: colors.textSecondary),
              title: s.title,
              trailing: Icon(
                Icons.chevron_right,
                color: colors.textMuted,
              ),
              onTap: router == null ? null : () => router.push(s.route),
              semanticLabel: s.title,
            );
          },
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
