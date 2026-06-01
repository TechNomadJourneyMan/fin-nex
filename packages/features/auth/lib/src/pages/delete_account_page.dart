// Delete-account confirmation page with "type DELETE" gate.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

import '../auth_state.dart';
import '../providers.dart';

/// Account deletion confirmation page.
class DeleteAccountPage extends ConsumerStatefulWidget {
  /// Default constructor.
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  final TextEditingController _confirm = TextEditingController();
  static const String _gate = 'DELETE';

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    await ref.read(authControllerProvider.notifier).deleteAccount();
    if (!mounted) return;
    context.go('/auth/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(authControllerProvider);
    final loading = state.isLoading || (state.valueOrNull is Authenticating);
    final canSubmit = _confirm.text.trim() == _gate && !loading;
    final failure = state.hasError && !state.isLoading
        ? state.error
        : (state.valueOrNull is AuthError
            ? (state.valueOrNull as AuthError).failure
            : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commonDelete)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PfBanner(
                    tone: PfBannerTone.warning,
                    title: l10n.commonDelete,
                    message: l10n.txDeleteConfirm,
                  ),
                  const SizedBox(height: 16),
                  if (failure != null) ...[
                    PfBanner(
                      tone: PfBannerTone.error,
                      message: failure.toString(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  PfTextField(
                    key: const ValueKey<String>('delete.confirm'),
                    label: 'Type "$_gate" to confirm',
                    controller: _confirm,
                    enabled: !loading,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  PfButton(
                    key: const ValueKey<String>('delete.submit'),
                    label: l10n.commonDelete,
                    variant: PfButtonVariant.destructive,
                    onPressed: canSubmit ? _delete : null,
                    loading: loading,
                    fullWidth: true,
                    size: PfButtonSize.lg,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: loading ? null : () => context.pop(),
                    child: Text(l10n.commonCancel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
