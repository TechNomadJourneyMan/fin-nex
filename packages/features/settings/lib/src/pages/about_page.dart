// Settings → About.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

/// About page (version, links).
class AboutPage extends ConsumerWidget {
  /// Default constructor.
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    // Hard-coded so the page renders even without the build-info plugin.
    // TODO(F-ABOUT-BUILD): wire to `package_info_plus` once available.
    const version = '0.1.0';
    const build = '1';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.setAbout)),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Center(child: Text(l10n.appName, style: typo.heading1)),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'OmniFi OS · design philosophy',
                style: typo.bodySm.copyWith(color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                l10n.setVersion('$version ($build)'),
                style: typo.bodyMd.copyWith(color: colors.textMuted),
              ),
            ),
            const SizedBox(height: 24),
            PfListItem(
              leading: Icon(Icons.shield_outlined, color: colors.textSecondary),
              title: 'Privacy policy',
              trailing: Icon(Icons.open_in_new, color: colors.textMuted),
              onTap: () {
                /* TODO(F-LEGAL): open privacy URL. */
              },
            ),
            PfListItem(
              leading: Icon(
                Icons.description_outlined,
                color: colors.textSecondary,
              ),
              title: 'Terms of service',
              trailing: Icon(Icons.open_in_new, color: colors.textMuted),
              onTap: () {
                /* TODO(F-LEGAL): open terms URL. */
              },
            ),
          ],
        ),
      ),
    );
  }
}
