// Grant permissions — notifications + biometric (biometric web-skipped).

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

import '../controllers/onboarding_controller.dart';
import '../providers.dart';
import '../widgets/onboarding_scaffold.dart';

/// Onboarding step 4 — ask for notification + biometric permission.
///
/// On Flutter Web the biometric row is hidden entirely (no platform API);
/// notifications are stubbed via [OnboardingController.requestNotifications].
class GrantPermissionsPage extends ConsumerWidget {
  /// Creates the permissions page.
  const GrantPermissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final typo = context.fnxTypography;
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;

    return OnboardingScaffold(
      currentStep: 3,
      totalSteps: 5,
      onSkip: () async {
        await controller.complete();
        if (context.mounted) {
          context.go('/dashboard');
        }
      },
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PfButton(
            label: l10n.commonNext,
            fullWidth: true,
            size: PfButtonSize.lg,
            onPressed: () {
              controller.goTo(OnboardingStep.firstTransaction);
              context.go('/onboarding/first-transaction');
            },
          ),
        ],
      ),
      child: ListView(
        children: [
          SizedBox(height: spacing.s7),
          Text('Stay in the loop', style: typo.heading1),
          SizedBox(height: spacing.s4),
          Text(
            'A couple of optional permissions to make PocketFlow feel native. '
            'Both can be changed later in Settings.',
            style: typo.bodyMd.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.s7),
          _PermissionRow(
            icon: Icons.notifications_active_outlined,
            title: 'Notifications',
            subtitle: 'Gentle daily nudges + weekly recap.',
            granted: state.notificationsGranted,
            onAsk: () => controller.requestNotifications(),
          ),
          if (!kIsWeb) ...[
            SizedBox(height: spacing.s4),
            _PermissionRow(
              icon: Icons.fingerprint,
              title: 'Biometric unlock',
              subtitle: 'Lock the app with Face ID / Touch ID.',
              granted: state.biometricGranted,
              onAsk: () => controller.requestBiometric(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onAsk,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final Future<void> Function() onAsk;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final radii = context.fnxRadii;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(radii.r3),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.brandSubtle,
              borderRadius: BorderRadius.circular(radii.r2),
            ),
            child: Icon(icon, color: colors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: typo.heading3),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: typo.bodySm.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (granted)
            Icon(Icons.check_circle, color: colors.success)
          else
            PfButton(
              label: 'Allow',
              variant: PfButtonVariant.secondary,
              size: PfButtonSize.sm,
              onPressed: () => onAsk(),
            ),
        ],
      ),
    );
  }
}
