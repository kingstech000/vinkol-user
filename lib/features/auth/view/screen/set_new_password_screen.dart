import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/core/utils/validators.dart';
import 'package:starter_codes/features/auth/view_model/set_new_password_view_model.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';

// Change from StatefulWidget to ConsumerWidget
class SetNewPasswordScreen extends ConsumerWidget {
  const SetNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef ref
    final setNewPasswordViewModel = ref.watch(setNewPasswordViewModelProvider);
    final formKey = GlobalKey<FormState>(); // Form key for validation

    return Scaffold(
      appBar: MiniAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form( // Wrap with Form for validation
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.h2('Set New Password'),
              Gap.h8,
              AppText.free('Let\'s reset your password quickly'),
              Gap.h32,
              AppText.caption(
                'Create New Password',
                fontSize: 14,
              ),
              Gap.h4,
              AppTextField(
                controller: setNewPasswordViewModel.newPasswordController, // Use ViewModel's controller (or make them public in VM)
                hint: '********',
                isPassword: true,
                validator: (value) => Validator.password(value),
              ),
              Gap.h16,
              AppText.caption(
                'Confirm Password',
                fontSize: 14,
              ),
              Gap.h4,
              AppTextField(
                controller: setNewPasswordViewModel.confirmPasswordController, // Use ViewModel's controller (or make them public in VM)
                hint: '********',
                isPassword: true,
                // Add a validator to check if passwords match.
                // This validator needs access to _newPasswordController's text.
                // A better way is to pass new password text to this validator.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != setNewPasswordViewModel.newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              Gap.h32,
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  title: 'Reset',
                  loading: setNewPasswordViewModel.isBusy, // Show loading state
                  onTap: () {
                    // Validate form before calling ViewModel method
                    if (formKey.currentState?.validate() ?? false) {
                      setNewPasswordViewModel.setNewPassword(
                           context: context,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}