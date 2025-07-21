import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/auth/view_model/reset_password_view_model.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState(); // Changed to ConsumerState
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added form key for validation

  @override
  void initState() {
    super.initState();
    // Initialize controller with value from the ViewModel
    final viewModel = ref.read(resetPasswordViewModelProvider);
    _emailController.text = viewModel.email;

    // Add listener to update ViewModel on text field changes
    _emailController
        .addListener(() => viewModel.setEmail(_emailController.text));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel to react to state changes (busy, error, idle)
    final resetPasswordViewModel = ref.watch(resetPasswordViewModelProvider);

    return Scaffold(
      appBar: MiniAppBar(),
      body: Stack(
        // Use Stack to overlay loading indicator
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              // Wrap with Form for validation
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h2('Reset Password'),
                  Gap.h8,
                  AppText.body('Let\'s reset your password quickly'),
                  Gap.h32,
                  AppText.caption('E-mail Address'),
                  Gap.h8,
                  AppTextField(
                    controller: _emailController,
                    hint: 'michael.osato@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      // Basic email validation regex
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  Gap.h32,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                      title: 'Send',
                      loading: resetPasswordViewModel.isBusy,
                      onTap: resetPasswordViewModel.state.maybeWhen(
                        busy: () => null, // Disable button if busy
                        orElse: () => () {
                          // Validate form before calling sendPasswordResetEmail
                          if (_formKey.currentState?.validate() ?? false) {
                            resetPasswordViewModel.sendPasswordResetEmail(
                                context: context);
                          }
                        },
                      ),
                    ),
                  ),
                  Gap.h32,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
