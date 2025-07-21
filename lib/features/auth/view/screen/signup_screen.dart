import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/core/utils/validators.dart'; // Import for validators
import 'package:starter_codes/features/auth/view_model/signup_view_model.dart';
import 'package:starter_codes/widgets/app_bar/empty_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() =>
      _SignUpScreenState(); // Changed to ConsumerState
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added form key
  bool _termsAgreed = false; // Local state for terms agreement

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the signUpViewModelProvider to rebuild UI on state changes
    final signUpViewModel = ref.watch(signUpViewModelProvider);

    return Scaffold(
      appBar: const EmptyAppBar(),
      body: Stack(
        // Use Stack to overlay loading indicator
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Form(
              // Wrap with Form for validation
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h2('Sign up'),
                  Gap.h8,
                  AppText.body('Create an account with few steps'),
                  Gap.h32,
                  AppText.caption('E-mail Address'),
                  Gap.h8,
                  AppTextField(
                    controller: _emailController,
                    hint: 'vinkol.user@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => Validator.email(value),
                    suffixIcon: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.email,
                        size: 20, // Adjusted size for better visibility
                        color: AppColors.greyLight,
                      ),
                    ),
                  ),
                  Gap.h16,
                  AppText.caption('Password'),
                  Gap.h8,
                  AppTextField(
                    controller: _passwordController,
                    hint: '********',
                    isPassword: true, // Use isPassword for toggling visibility
                    validator: (value) =>
                        Validator.password(value), // Add password validator
                  ),
                  Gap.h16,
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAgreed,
                        onChanged: (bool? value) {
                          setState(() {
                            _termsAgreed = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: AppText.caption(
                          'I agree to the terms & conditions',
                        ),
                      ),
                    ],
                  ),
                  Gap.h32,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                      title: 'Next',
                      loading: signUpViewModel.isBusy,
                      onTap: (_termsAgreed &&
                              signUpViewModel.state.maybeWhen(
                                busy: () => false,
                                orElse: () => true,
                              ))
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                // Validate form
                                signUpViewModel.signUp(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  termsAgreed: _termsAgreed,
                                  context: context,
                                );
                              }
                            }
                          : null, // Disable button
                    ),
                  ),
                  Gap.h32,
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText.caption('Have an account? '),
                        GestureDetector(
                          onTap: signUpViewModel
                              .navigateToLogin, // Use ViewModel for navigation
                          child: AppText.caption(
                            'Login',
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap.h16,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
