import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/utils/validators.dart';
import 'package:starter_codes/features/auth/view_model/reset_password_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Step one of the reset: ask for the email, send a code to it.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  String? _emailError;

  @override
  void initState() {
    super.initState();
    final vm = ref.read(resetPasswordViewModelProvider);
    _email.text = vm.email;
    _email.addListener(() => vm.setEmail(_email.text));
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit(ResetPasswordViewModel vm) {
    final error = Validator.email(_email.text);
    setState(() => _emailError = error);
    if (error != null) return;
    vm.sendPasswordResetEmail(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final vm = ref.watch(resetPasswordViewModelProvider);

    return VinkolAuthScaffold(
      title: l10n.authResetPassword,
      body: l10n.authResetRequestBody,
      fields: <Widget>[
        VinkolFormField(
          pill: true,
          label: l10n.authEmailAddress,
          controller: _email,
          hint: l10n.authEmailHint,
          error: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.email],
          leading: Icon(Icons.mail_outline, size: 19, color: v.textTertiary),
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
      ],
      primaryAction: VinkolPrimaryButton(
        label: l10n.authSendCode,
        loading: vm.isBusy,
        onPressed: () => _submit(vm),
      ),
    );
  }
}
