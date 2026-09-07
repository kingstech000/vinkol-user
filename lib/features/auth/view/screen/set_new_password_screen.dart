import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/utils/validators.dart';
import 'package:starter_codes/features/auth/view_model/set_new_password_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Step two of the reset: choose the new password.
///
/// The mismatch is reported on the **confirm** field, not the first one — that is the field
/// the user has to change, and putting the error anywhere else sends them to the wrong box.
class SetNewPasswordScreen extends ConsumerStatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  ConsumerState<SetNewPasswordScreen> createState() =>
      _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends ConsumerState<SetNewPasswordScreen> {
  String? _passwordError;
  String? _confirmError;

  void _submit(SetNewPasswordViewModel vm) {
    final password = vm.newPasswordController.text;
    final confirm = vm.confirmPasswordController.text;
    final passwordError = Validator.password(password);
    final confirmError = confirm.isEmpty
        ? 'Repeat your new password.'
        : (confirm != password ? 'These two passwords do not match.' : null);

    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
    });
    if (passwordError != null || confirmError != null) return;
    vm.setNewPassword(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = ref.watch(setNewPasswordViewModelProvider);

    return VinkolAuthScaffold(
      title: l10n.authCreateNewPassword,
      body: l10n.authNewPasswordBody,
      fields: <Widget>[
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              VinkolPasswordField(
                pill: true,
                label: l10n.authNewPassword,
                controller: vm.newPasswordController,
                hint: l10n.authPasswordHint,
                helper: l10n.authPasswordHelper,
                error: _passwordError,
                autofillHint: AutofillHints.newPassword,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
              const SizedBox(height: VinkolSpace.lg),
              VinkolPasswordField(
                pill: true,
                label: l10n.authConfirmPassword,
                controller: vm.confirmPasswordController,
                hint: l10n.authConfirmPasswordHint,
                error: _confirmError,
                autofillHint: AutofillHints.newPassword,
                onChanged: (_) {
                  if (_confirmError != null) {
                    setState(() => _confirmError = null);
                  }
                },
              ),
            ],
          ),
        ),
      ],
      primaryAction: VinkolPrimaryButton(
        label: l10n.authSavePassword,
        loading: vm.isBusy,
        onPressed: () => _submit(vm),
      ),
    );
  }
}
