// lib/features/auth/view/screen/enter_otp_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/auth/view_model/enter_otp_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The password-reset code. Verifying advances to setting a new password.
class EnterOTPCodeScreen extends ConsumerStatefulWidget {
  const EnterOTPCodeScreen({super.key});

  @override
  ConsumerState<EnterOTPCodeScreen> createState() => _EnterOTPCodeScreenState();
}

class _EnterOTPCodeScreenState extends ConsumerState<EnterOTPCodeScreen> {
  final TextEditingController _otp = TextEditingController();

  static const int _resendSeconds = 30;
  int _remaining = _resendSeconds;
  Timer? _timer;
  String? _error;
  late String _email;

  @override
  void initState() {
    super.initState();
    _email = ref.read(resetEmailProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpViewModelProvider).setEmail(_email);
    });
    _startCountdown();
  }

  /// A real [Timer], not a chain of `Future.delayed` calls that keeps ticking after the
  /// screen is popped and cannot be cancelled.
  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remaining = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _remaining--);
      if (_remaining <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    super.dispose();
  }

  void _verify(OtpViewModel vm) {
    if (_otp.text.length < 4) {
      setState(() => _error = context.l10n.authOtpIncomplete);
      return;
    }
    setState(() => _error = null);
    vm.verifyOtp(otp: _otp.text, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = ref.watch(otpViewModelProvider);
    final canResend = _remaining <= 0 && !vm.isBusy;

    return VinkolAuthScaffold(
      title: l10n.authEnterOtpCode,
      // One whole sentence with the address interpolated, not two spans glued together:
      // French puts the placeholder somewhere else, and a split sentence cannot follow it.
      body: l10n.authOtpSentTo(_email),
      fields: <Widget>[
        AutofillGroup(
          // The reset code is 4 digits, matching what the API sends.
          child: VinkolOtpField(
            controller: _otp,
            length: 4,
            error: _error,
            enabled: !vm.isBusy,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onCompleted: (code) {
              if (!vm.isBusy) vm.verifyOtp(otp: code, context: context);
            },
          ),
        ),
      ],
      below: _ResendRow(
        canResend: canResend,
        remaining: _remaining,
        onResend: () {
          vm.resendOtp(context: context);
          _startCountdown();
        },
      ),
      primaryAction: VinkolPrimaryButton(
        label: l10n.authNext,
        loading: vm.isBusy,
        onPressed: () => _verify(vm),
      ),
    );
  }
}

/// "Didn't get it? Resend code" — or the countdown while resending is blocked.
class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.canResend,
    required this.remaining,
    required this.onResend,
  });

  final bool canResend;
  final int remaining;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;

    return Center(
      child: canResend
          ? VinkolFooterLink(
              lead: l10n.authOtpDidntGet,
              action: l10n.authOtpResend,
              onTap: onResend,
            )
          : Text(
              l10n.authOtpResendIn(remaining),
              style: VinkolType.bodyS.copyWith(color: v.textTertiary),
            ),
    );
  }
}
