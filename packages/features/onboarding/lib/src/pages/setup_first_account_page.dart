// Setup first account — pick default currency + name.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

import '../controllers/onboarding_controller.dart';
import '../providers.dart';
import '../widgets/onboarding_scaffold.dart';

/// Supported currencies for the first account picker.
const List<({String code, String label})> _kCurrencies = [
  (code: 'KZT', label: 'Kazakh Tenge'),
  (code: 'USD', label: 'US Dollar'),
  (code: 'EUR', label: 'Euro'),
  (code: 'RUB', label: 'Russian Ruble'),
];

/// Onboarding step 3 — create the user's first account.
class SetupFirstAccountPage extends ConsumerStatefulWidget {
  /// Creates the setup page.
  const SetupFirstAccountPage({super.key});

  @override
  ConsumerState<SetupFirstAccountPage> createState() =>
      _SetupFirstAccountPageState();
}

class _SetupFirstAccountPageState extends ConsumerState<SetupFirstAccountPage> {
  late final TextEditingController _nameCtl;
  String _currency = 'KZT';

  @override
  void initState() {
    super.initState();
    final initial = ref.read(onboardingControllerProvider);
    _nameCtl = TextEditingController(
      text: initial.accountName.isEmpty ? 'My wallet' : initial.accountName,
    );
    _currency = initial.currencyCode;
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  void _continue() {
    final controller = ref.read(onboardingControllerProvider.notifier);
    controller
      ..setCurrency(_currency)
      ..setAccountName(_nameCtl.text.trim())
      ..goTo(OnboardingStep.permissions);
    context.go('/onboarding/permissions');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final typo = context.fnxTypography;
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingScaffold(
      currentStep: 2,
      totalSteps: 5,
      onSkip: () async {
        await controller.complete();
        if (context.mounted) {
          context.go('/dashboard');
        }
      },
      bottomBar: PfButton(
        label: l10n.commonNext,
        fullWidth: true,
        size: PfButtonSize.lg,
        onPressed: _continue,
      ),
      child: ListView(
        children: [
          SizedBox(height: spacing.s7),
          Text('Set up your first account', style: typo.heading1),
          SizedBox(height: spacing.s4),
          Text(
            'Pick a currency and a friendly name. You can add more later.',
            style: typo.bodyMd.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.s7),
          Text('Account name', style: typo.caption),
          SizedBox(height: spacing.s3),
          TextField(
            controller: _nameCtl,
            decoration: const InputDecoration(
              hintText: 'My wallet',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: spacing.s6),
          Text('Default currency', style: typo.caption),
          SizedBox(height: spacing.s3),
          ..._kCurrencies.map(
            (c) => Padding(
              padding: EdgeInsets.only(bottom: spacing.s3),
              child: _CurrencyTile(
                code: c.code,
                label: c.label,
                selected: c.code == _currency,
                onTap: () => setState(() => _currency = c.code),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final radii = context.fnxRadii;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label $code',
      child: Material(
        color: selected ? colors.brandSubtle : colors.surface,
        borderRadius: BorderRadius.circular(radii.r3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radii.r3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? colors.brand : colors.borderSubtle,
              ),
              borderRadius: BorderRadius.circular(radii.r3),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    code,
                    style: typo.amountSm.copyWith(color: colors.textPrimary),
                  ),
                ),
                Expanded(
                  child: Text(
                    label,
                    style: typo.bodyMd.copyWith(color: colors.textSecondary),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: colors.brand, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
