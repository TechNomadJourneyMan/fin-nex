// Biometric unlock page — Face ID / Touch ID with passcode fallback.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

/// Re-entry unlock page shown when reopening the app.
///
/// On native platforms shows a biometric prompt with a passcode fallback.
/// On web, biometrics are unavailable so only the passcode field is rendered.
class BiometricUnlockPage extends ConsumerStatefulWidget {
  /// Default constructor.
  const BiometricUnlockPage({super.key});

  @override
  ConsumerState<BiometricUnlockPage> createState() =>
      _BiometricUnlockPageState();
}

class _BiometricUnlockPageState extends ConsumerState<BiometricUnlockPage> {
  final TextEditingController _passcode = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _passcode.dispose();
    super.dispose();
  }

  Future<void> _useBiometric() async {
    // TODO(F-AUTH-WEB): integrate local_auth on native; this stub succeeds.
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _busy = false);
    context.go('/dashboard');
  }

  Future<void> _usePasscode() async {
    final l10n = AppL10n.of(context);
    if (_passcode.text.length < 4) {
      setState(() => _error = l10n.commonRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _busy = false);
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_outline,
                      size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.authBiometricPrompt,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  if (!kIsWeb) ...[
                    PfButton(
                      key: const ValueKey<String>('biometric.useBio'),
                      label: l10n.authBiometricPrompt,
                      leadingIcon: Icons.fingerprint,
                      onPressed: _busy ? null : _useBiometric,
                      loading: _busy,
                      fullWidth: true,
                      size: PfButtonSize.lg,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  PfTextField(
                    key: const ValueKey<String>('biometric.passcode'),
                    label: l10n.commonContinue,
                    controller: _passcode,
                    obscure: true,
                    keyboardType: TextInputType.number,
                    enabled: !_busy,
                    errorText: _error,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 16),
                  PfButton(
                    key: const ValueKey<String>('biometric.usePasscode'),
                    label: l10n.commonContinue,
                    onPressed: _busy ? null : _usePasscode,
                    loading: _busy,
                    fullWidth: true,
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
