// Welcome page — first onboarding screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

import '../controllers/onboarding_controller.dart';
import '../providers.dart';
import '../widgets/onboarding_scaffold.dart';

/// Onboarding step 1 — hero + value pitch + entry CTAs.
class WelcomePage extends ConsumerWidget {
  /// Creates the welcome page.
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final typo = context.fnxTypography;
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingScaffold(
      currentStep: 0,
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
            label: l10n.onbStart,
            fullWidth: true,
            size: PfButtonSize.lg,
            onPressed: () {
              controller.goTo(OnboardingStep.valueProps);
              context.go('/onboarding/value-props');
            },
          ),
          SizedBox(height: spacing.s4),
          PfButton(
            label: l10n.onbHaveAccount,
            variant: PfButtonVariant.ghost,
            fullWidth: true,
            onPressed: () => context.go('/auth/login'),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HeroIllustration(color: colors.brand, tint: colors.brandSubtle),
            SizedBox(height: spacing.s7),
            Text(
              'Pocket Flow',
              style: typo.displaySm,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.s4),
            Text(
              l10n.onbP1Body,
              style: typo.bodyLg.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative hero illustration. Pure widgets — no asset dependency.
class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.color, required this.tint});

  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 64),
          ),
        ],
      ),
    );
  }
}
