// Settings → Privacy & Security. On Flutter Web the biometric and
// screenshot toggles are hidden because the platform doesn't support them.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

import '../providers.dart';

/// Privacy / security page.
class PrivacyPage extends ConsumerWidget {
  /// Default constructor.
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final state = ref.watch(privacyProvider);
    final ctl = ref.read(privacyProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.setSecurity)),
      body: SafeArea(
        child: ListView(
          children: [
            if (!kIsWeb)
              SwitchListTile(
                value: state.biometricLock,
                onChanged: ctl.setBiometric,
                title: Text(l10n.setBiometric),
                activeColor: colors.brand,
              ),
            SwitchListTile(
              value: state.hideBalances,
              onChanged: ctl.setHideBalances,
              title: Text(l10n.setPin),
              activeColor: colors.brand,
            ),
            // Screenshot-lock is a mobile-only privacy primitive; hidden on
            // web where there is no platform hook for it.
            // TODO(F-PRIV-SCREENSHOT): wire to a native plugin on iOS/Android.
          ],
        ),
      ),
    );
  }
}
