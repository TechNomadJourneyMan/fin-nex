// Sign-up page — collects email, password, and display name.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

import '../auth_state.dart';
import '../providers.dart';

/// Sign-up page.
class SignUpPage extends ConsumerStatefulWidget {
  /// Default constructor.
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppL10n.of(context);
    setState(() {
      _emailError =
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim())
              ? l10n.commonRequired
              : null;
      _passwordError = _password.text.length < 8 ? l10n.commonRequired : null;
    });
    if (_emailError != null || _passwordError != null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).signInEmail(
          email: _email.text.trim(),
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(authControllerProvider);
    final loading = state.isLoading || (state.valueOrNull is Authenticating);
    final failure = state.hasError && !state.isLoading
        ? state.error
        : (state.valueOrNull is AuthError
            ? (state.valueOrNull as AuthError).failure
            : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authSignUp)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (failure != null) ...[
                      PfBanner(
                        tone: PfBannerTone.error,
                        message: failure.toString(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    PfTextField(
                      key: const ValueKey<String>('signup.name'),
                      label: l10n.commonOptional,
                      controller: _name,
                      enabled: !loading,
                    ),
                    const SizedBox(height: 12),
                    PfTextField(
                      key: const ValueKey<String>('signup.email'),
                      label: l10n.authContinueEmail,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !loading,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 12),
                    PfTextField(
                      key: const ValueKey<String>('signup.password'),
                      label: l10n.commonContinue,
                      controller: _password,
                      obscure: true,
                      enabled: !loading,
                      errorText: _passwordError,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    PfButton(
                      key: const ValueKey<String>('signup.submit'),
                      label: l10n.commonContinue,
                      onPressed: loading ? null : _submit,
                      loading: loading,
                      fullWidth: true,
                      size: PfButtonSize.lg,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed:
                          loading ? null : () => context.go('/auth/sign-in'),
                      child: Text(l10n.commonBack),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
