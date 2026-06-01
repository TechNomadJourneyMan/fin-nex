// Final onboarding page — invites the user to log their first transaction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import '../widgets/onboarding_scaffold.dart';

/// Onboarding step 5 — "try it now" CTA that hands off to transactions.
///
/// The transactions feature owns the actual quick-add sheet. To avoid a
/// cross-feature import dependency, the host app wires this page with a
/// callback via [FirstTransactionPromptPage.onTryNow]. When `null`, the
/// page falls back to navigating to `/transactions/add`.
class FirstTransactionPromptPage extends ConsumerWidget {
  /// Creates the prompt page.
  const FirstTransactionPromptPage({super.key, this.onTryNow});

  /// Callback invoked when the user taps "Try it now". Typically opens
  /// the transactions quick-add bottom sheet via a feature callback.
  final void Function(BuildContext context)? onTryNow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final typo = context.fnxTypography;
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final controller = ref.read(onboardingControllerProvider.notifier);

    Future<void> finishAndGo({required bool tryAdd}) async {
      await controller.complete();
      if (!context.mounted) {
        return;
      }
      if (tryAdd) {
        if (onTryNow != null) {
          onTryNow!(context);
          return;
        }
        context.go('/transactions/add');
      } else {
        context.go('/dashboard');
      }
    }

    return OnboardingScaffold(
      currentStep: 4,
      totalSteps: 5,
      showSkip: false,
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PfButton(
            label: 'Try it now',
            fullWidth: true,
            size: PfButtonSize.lg,
            onPressed: () => finishAndGo(tryAdd: true),
          ),
          SizedBox(height: spacing.s4),
          PfButton(
            label: 'Maybe later',
            variant: PfButtonVariant.ghost,
            fullWidth: true,
            onPressed: () => finishAndGo(tryAdd: false),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.successSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: colors.success, size: 56),
            ),
            SizedBox(height: spacing.s6),
            Text(
              l10n.onbStart,
              style: typo.heading1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.s3),
            Text(
              "You're set. Let's log your first transaction — it takes 3 seconds.",
              style: typo.bodyLg.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
