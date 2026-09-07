import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/auth/view_model/verify_email_otp_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Email verification after sign-up. The code lands by email, so the field carries the
/// `oneTimeCode` autofill hint and the platform can fill it without a copy-paste round trip.
class VerifyEmailOtpScreen extends ConsumerStatefulWidget {
  const VerifyEmailOtpScreen({super.key});

  @override
  ConsumerState<VerifyEmailOtpScreen> createState() =>
      _VerifyEmailOtpScreenState();
}

class _VerifyEmailOtpScreenState extends ConsumerState<VerifyEmailOtpScreen> {
  final TextEditingController _otp = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(verifyEmailOtpViewModelProvider);
      vm.setEmail(ref.read(verifyEmailProvider));
      vm.startResendCooldown();
    });
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  void _verify(VerifyEmailOtpViewModel vm) {
    if (_otp.text.length < 4) {
      setState(() => _error = context.l10n.authOtpIncomplete);
      return;
    }
    setState(() => _error = null);
    vm.verifyEmailOtp(otp: _otp.text, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final vm = ref.watch(verifyEmailOtpViewModelProvider);
    final email = ref.watch(verifyEmailProvider);
    final canResend = vm.secondsRemaining == 0 && !vm.isBusy;

    return VinkolAuthScaffold(
      title: l10n.authOtpTitle,
      body: l10n.authOtpSentTo(email),
      fields: <Widget>[
        AutofillGroup(
          child: VinkolOtpField(
            controller: _otp,
            length: 4,
            error: _error,
            enabled: !vm.isBusy,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onCompleted: (code) {
              if (!vm.isBusy) {
                vm.verifyEmailOtp(otp: code, context: context);
              }
            },
          ),
        ),
      ],
      below: Center(
        child: canResend
            ? VinkolFooterLink(
                lead: l10n.authOtpDidntGet,
                action: l10n.authOtpResend,
                onTap: () => vm.resendEmailOtp(context: context),
              )
            : Text(
                l10n.authOtpResendIn(vm.secondsRemaining),
                style: VinkolType.bodyS.copyWith(color: v.textTertiary),
              ),
      ),
      primaryAction: VinkolPrimaryButton(
        label: l10n.authOtpVerify,
        loading: vm.isBusy,
        onPressed: () => _verify(vm),
      ),
    );
  }
}
