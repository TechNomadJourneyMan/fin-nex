// Shared scaffold + step indicator for onboarding pages.

import 'package:flutter/material.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

/// Wraps an onboarding page with a top "Skip" affordance and a bottom
/// step indicator. Keeps visual rhythm consistent across all 5 pages.
class OnboardingScaffold extends StatelessWidget {
  /// Creates an onboarding scaffold.
  const OnboardingScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.child,
    this.onSkip,
    this.bottomBar,
    this.showSkip = true,
  });

  /// 0-based current step index.
  final int currentStep;

  /// Total steps shown in the indicator.
  final int totalSteps;

  /// Page body.
  final Widget child;

  /// Optional skip action. When null and [showSkip] true, no button shown.
  final VoidCallback? onSkip;

  /// Optional bottom CTA bar.
  final Widget? bottomBar;

  /// Whether to render the skip button at all.
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showSkip && onSkip != null)
                      PfButton(
                        label: 'Skip',
                        variant: PfButtonVariant.ghost,
                        size: PfButtonSize.sm,
                        onPressed: onSkip,
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s6),
                child: child,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.s5),
              child: OnboardingStepIndicator(
                currentStep: currentStep,
                totalSteps: totalSteps,
              ),
            ),
            if (bottomBar != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s6,
                  0,
                  spacing.s6,
                  spacing.s6,
                ),
                child: bottomBar,
              ),
          ],
        ),
      ),
    );
  }
}

/// Pill-style step indicator. The active dot animates into a wider pill.
///
/// Honors `MediaQuery.disableAnimations` for reduced motion.
class OnboardingStepIndicator extends StatelessWidget {
  /// Creates a step indicator.
  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  /// 0-based active step.
  final int currentStep;

  /// Total number of dots.
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 200);

    return Semantics(
      label: 'Step ${currentStep + 1} of $totalSteps',
      container: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(totalSteps, (i) {
          final active = i == currentStep;
          return AnimatedContainer(
            duration: duration,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 6,
            width: active ? 24 : 6,
            decoration: BoxDecoration(
              color: active ? colors.brand : colors.borderDefault,
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }),
      ),
    );
  }
}
