// Phone OTP page — phone input → 6-digit OTP grid with auto-advance & paste.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

import '../auth_state.dart';
import '../providers.dart';

/// Phone + OTP entry page.
class PhoneOtpPage extends ConsumerStatefulWidget {
  /// Default constructor.
  const PhoneOtpPage({super.key});

  @override
  ConsumerState<PhoneOtpPage> createState() => _PhoneOtpPageState();
}

class _PhoneOtpPageState extends ConsumerState<PhoneOtpPage> {
  final TextEditingController _phone = TextEditingController();
  bool _otpStage = false;
  String? _phoneError;
  Timer? _resendTimer;
  int _resendIn = 0;

  @override
  void dispose() {
    _phone.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendIn = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendIn -= 1);
      if (_resendIn <= 0) t.cancel();
    });
  }

  Future<void> _requestCode() async {
    final l10n = AppL10n.of(context);
    final phone = _phone.text.trim();
    if (!RegExp(r'^\+\d{6,15}$').hasMatch(phone)) {
      setState(() => _phoneError = l10n.commonRequired);
      return;
    }
    setState(() => _phoneError = null);
    await ref.read(authControllerProvider.notifier).requestOtp(phone);
    if (!mounted) return;
    setState(() => _otpStage = true);
    _startResendTimer();
  }

  Future<void> _verify(String code) async {
    await ref.read(authControllerProvider.notifier).verifyOtp(
          identifier: _phone.text.trim(),
          code: code,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(authControllerProvider);
    final loading =
        state.isLoading || (state.valueOrNull is Authenticating);
    final failure = state.hasError && !state.isLoading
        ? state.error
        : (state.valueOrNull is AuthError
            ? (state.valueOrNull as AuthError).failure
            : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(_otpStage ? l10n.authOtpTitle : l10n.authTitle),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (failure != null) ...[
                    FnxBanner(
                      tone: FnxBannerTone.error,
                      message: failure.toString(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!_otpStage) ...[
                    Text(l10n.authSubtitle),
                    const SizedBox(height: 16),
                    FnxTextField(
                      key: const ValueKey<String>('otp.phone'),
                      label: l10n.authCtaSendCode,
                      controller: _phone,
                      hint: '+7 700 123 4567',
                      keyboardType: TextInputType.phone,
                      enabled: !loading,
                      errorText: _phoneError,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FnxButton(
                      key: const ValueKey<String>('otp.request'),
                      label: l10n.authCtaSendCode,
                      onPressed: loading ? null : _requestCode,
                      loading: loading,
                      fullWidth: true,
                      size: FnxButtonSize.lg,
                    ),
                  ] else ...[
                    Text(l10n.authOtpSubtitle(_phone.text.trim())),
                    const SizedBox(height: 24),
                    _OtpGrid(
                      key: const ValueKey<String>('otp.grid'),
                      enabled: !loading,
                      onCompleted: _verify,
                    ),
                    const SizedBox(height: 24),
                    if (_resendIn > 0)
                      Text(
                        l10n.authOtpResendIn('00:${_resendIn.toString().padLeft(2, '0')}'),
                        textAlign: TextAlign.center,
                      )
                    else
                      TextButton(
                        key: const ValueKey<String>('otp.resend'),
                        onPressed: loading ? null : _requestCode,
                        child: Text(l10n.authOtpResend),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authOtpHelp,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 6-cell OTP grid with auto-advance and paste support.
class _OtpGrid extends StatefulWidget {
  const _OtpGrid({super.key, required this.onCompleted, this.enabled = true});

  final ValueChanged<String> onCompleted;
  final bool enabled;

  @override
  State<_OtpGrid> createState() => _OtpGridState();
}

class _OtpGridState extends State<_OtpGrid> {
  static const int _length = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      _length,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(_length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String value) {
    if (value.length > 1) {
      // Paste path: distribute characters across cells.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var j = 0; j < _length; j++) {
        _controllers[j].text = j < digits.length ? digits[j] : '';
      }
      final filled = digits.length.clamp(0, _length);
      if (filled >= _length) {
        _focusNodes[_length - 1].unfocus();
        widget.onCompleted(_collect());
      } else {
        _focusNodes[filled].requestFocus();
      }
      setState(() {});
      return;
    }
    if (value.isNotEmpty && i < _length - 1) {
      _focusNodes[i + 1].requestFocus();
    }
    if (_collect().length == _length) {
      _focusNodes[_length - 1].unfocus();
      widget.onCompleted(_collect());
    }
    setState(() {});
  }

  String _collect() => _controllers.map((c) => c.text).join();

  void _onKey(int i, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[i].text.isEmpty &&
        i > 0) {
      _focusNodes[i - 1].requestFocus();
      _controllers[i - 1].clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(_length, (i) {
        return SizedBox(
          width: 44,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (e) => _onKey(i, e),
            child: TextField(
              key: ValueKey<String>('otp.cell.$i'),
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: i == 0 ? 6 : 1,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(counterText: ''),
              onChanged: (v) => _onChanged(i, v),
            ),
          ),
        );
      }),
    );
  }
}
