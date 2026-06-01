// Sign-in page — email + password + OAuth + phone.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

import '../auth_state.dart';
import '../controllers/auth_controller.dart';
import '../providers.dart';

/// Email + password sign-in page with OAuth buttons and a phone CTA.
class SignInPage extends ConsumerStatefulWidget {
  /// Default constructor.
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v, AppL10n l10n) {
    if (v == null || v.trim().isEmpty) return l10n.commonRequired;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : l10n.commonRequired;
  }

  String? _validatePassword(String? v, AppL10n l10n) {
    if (v == null || v.isEmpty) return l10n.commonRequired;
    if (v.length < 8) return l10n.commonRequired;
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppL10n.of(context);
    setState(() {
      _emailError = _validateEmail(_email.text, l10n);
      _passwordError = _validatePassword(_password.text, l10n);
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
    final loading = state.isLoading ||
        (state.valueOrNull is Authenticating);
    final errorFailure = state.hasError && !state.isLoading
        ? state.error
        : (state.valueOrNull is AuthError
            ? (state.valueOrNull as AuthError).failure
            : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authTitle)),
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
                    Text(
                      l10n.authSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (errorFailure != null) ...[
                      PfBanner(
                        tone: PfBannerTone.error,
                        message: errorFailure.toString(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    PfTextField(
                      key: const ValueKey<String>('signin.email'),
                      label: l10n.authContinueEmail,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !loading,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 12),
                    PfTextField(
                      key: const ValueKey<String>('signin.password'),
                      label: l10n.commonContinue,
                      controller: _password,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      enabled: !loading,
                      errorText: _passwordError,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: loading
                            ? null
                            : () => context.go('/auth/otp'),
                        child: Text(l10n.authOtpHelp),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PfButton(
                      key: const ValueKey<String>('signin.submit'),
                      label: l10n.commonContinue,
                      onPressed: loading ? null : _submit,
                      loading: loading,
                      fullWidth: true,
                      size: PfButtonSize.lg,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l10n.authOr),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!kIsWeb)
                      PfButton(
                        key: const ValueKey<String>('signin.apple'),
                        label: l10n.authContinueApple,
                        variant: PfButtonVariant.secondary,
                        fullWidth: true,
                        size: PfButtonSize.lg,
                        leadingIcon: Icons.apple,
                        onPressed: loading
                            ? null
                            : () => ref
                                .read(authControllerProvider.notifier)
                                .signInOAuth(OAuthProvider.apple),
                      ),
                    if (!kIsWeb) const SizedBox(height: 12),
                    PfButton(
                      key: const ValueKey<String>('signin.google'),
                      label: l10n.authContinueGoogle,
                      variant: PfButtonVariant.secondary,
                      fullWidth: true,
                      size: PfButtonSize.lg,
                      leadingIcon: Icons.g_mobiledata,
                      onPressed: loading
                          ? null
                          : () => ref
                              .read(authControllerProvider.notifier)
                              .signInOAuth(OAuthProvider.google),
                    ),
                    const SizedBox(height: 12),
                    PfButton(
                      key: const ValueKey<String>('signin.phone'),
                      label: l10n.authCtaSendCode,
                      variant: PfButtonVariant.ghost,
                      fullWidth: true,
                      size: PfButtonSize.lg,
                      leadingIcon: Icons.phone_outlined,
                      onPressed:
                          loading ? null : () => context.go('/auth/otp'),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      key: const ValueKey<String>('signin.signup'),
                      onPressed:
                          loading ? null : () => context.go('/auth/sign-up'),
                      child: Text(l10n.authSignUp),
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
