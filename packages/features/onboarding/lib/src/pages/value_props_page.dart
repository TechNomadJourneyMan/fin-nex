// Value props page — 4-slide pager.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

import '../controllers/onboarding_controller.dart';
import '../providers.dart';
import '../widgets/onboarding_scaffold.dart';

/// A single value-prop slide model.
@immutable
class ValuePropSlide {
  /// Creates a slide.
  const ValuePropSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  /// Icon shown above the title.
  final IconData icon;

  /// Slide headline.
  final String title;

  /// Slide body copy.
  final String body;
}

/// Onboarding step 2 — 4-slide PageView with dots + Skip.
class ValuePropsPage extends ConsumerStatefulWidget {
  /// Creates the value props page.
  const ValuePropsPage({super.key});

  @override
  ConsumerState<ValuePropsPage> createState() => _ValuePropsPageState();
}

class _ValuePropsPageState extends ConsumerState<ValuePropsPage> {
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _advance(OnboardingController controller) async {
    if (_index < 3) {
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) {
        _pageController.jumpToPage(_index + 1);
      } else {
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    } else {
      controller.goTo(OnboardingStep.setupAccount);
      if (mounted) {
        context.go('/onboarding/setup-account');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final slides = <ValuePropSlide>[
      ValuePropSlide(
        icon: Icons.bolt,
        title: l10n.onbP1Title,
        body: l10n.onbP1Body,
      ),
      ValuePropSlide(
        icon: Icons.donut_large,
        title: l10n.onbP2Title,
        body: l10n.onbP2Body,
      ),
      ValuePropSlide(
        icon: Icons.savings,
        title: l10n.onbP3Title,
        body: l10n.onbP3Body,
      ),
      ValuePropSlide(
        icon: Icons.shield_moon,
        title: l10n.onbP4Title,
        body: l10n.onbP4Body,
      ),
    ];

    return OnboardingScaffold(
      currentStep: 1,
      totalSteps: 5,
      onSkip: () async {
        await controller.complete();
        if (context.mounted) {
          context.go('/dashboard');
        }
      },
      bottomBar: PfButton(
        label: _index == slides.length - 1 ? l10n.onbStart : l10n.onbNext,
        fullWidth: true,
        size: PfButtonSize.lg,
        onPressed: () => _advance(controller),
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => _ValuePropSlideView(slide: slides[i]),
            ),
          ),
          _DotsIndicator(count: slides.length, index: _index),
          SizedBox(height: context.fnxSpacing.s5),
        ],
      ),
    );
  }
}

class _ValuePropSlideView extends StatelessWidget {
  const _ValuePropSlideView({required this.slide});

  final ValuePropSlide slide;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final spacing = context.fnxSpacing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: colors.brandSubtle,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(slide.icon, color: colors.brand, size: 72),
          ),
          SizedBox(height: spacing.s7),
          Text(
            slide.title,
            style: typo.heading1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.s4),
          Text(
            slide.body,
            style: typo.bodyLg.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 200);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: duration,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 28 : 8,
          decoration: BoxDecoration(
            color: active ? colors.brand : colors.borderDefault,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
