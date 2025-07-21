import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/core/utils/validators.dart';
import 'package:starter_codes/features/auth/view_model/login_view_model.dart';
import 'package:starter_codes/widgets/app_bar/mini_action_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // We no longer need these TextEditingControllers to hold state directly,
  // as the ViewModel will manage the email and password.
  // However, we still need them to connect to the AppTextField widgets.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Listen to changes in the view model and update controllers accordingly
    // This is useful if the view model clears fields or prefills them.
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);

    // Initial sync from view model to controllers (e.g., if fields are pre-filled)
    final loginViewModel = ref.read(loginViewModelProvider);
    _emailController.text = loginViewModel.email;
    _passwordController.text = loginViewModel.password;
  }

  // Update view model when email changes in the text field
  void _onEmailChanged() {
    ref.read(loginViewModelProvider).setEmail(_emailController.text);
  }

  // Update view model when password changes in the text field
  void _onPasswordChanged() {
    ref.read(loginViewModelProvider).setPassword(_passwordController.text);
  }

  @override
  void dispose() {
    // Dispose the controllers to prevent memory leaks
    _emailController.removeListener(_onEmailChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the loginViewModelProvider to rebuild UI on state changes
    final loginViewModel = ref.watch(loginViewModelProvider);

    return Scaffold(
      appBar: MiniActionAppBar(
        icon: CupertinoIcons.chevron_back,
        action: 'Sign up',
        actionOnTap: () {
          NavigationService.instance.navigateTo(NavigatorRoutes.signupScreen);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.h1(
                'Login ',
                color: AppColors.black,
              ),
              Gap.h4,
              AppText.h1(
                'Welcome Back',
                color: AppColors.black,
              ),
              Gap.h32,
              AppText.caption(
                'Email Address',
                fontSize: 16,
                color: AppColors.black,
              ),
              Gap.h4,
              AppTextField(
                controller: _emailController,
                hint: 'sample@gmail.com',
                keyboardType: TextInputType.emailAddress,
                // No need for onChanged here as listener handles it
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
              AppText.caption(
                'Password',
                fontSize: 16,
                color: AppColors.black,
              ),
              Gap.h4,
              AppTextField(
                controller: _passwordController,
                hint: '********',
                isPassword: true,
                // No need for onChanged here as listener handles it
                validator: (value) => Validator.password(value),
              ),
              Gap.h36,
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  title: 'Login',
                  loading: loginViewModel.isBusy,
                  onTap: loginViewModel.state.maybeWhen(
                    busy: () => null, // Disable button if busy
                    orElse: () => () {
                      // Validate form before calling login
                      if (_formKey.currentState?.validate() ?? false) {
                        loginViewModel.login(context: context);
                      }
                    },
                  ),
                ),
              ),
              Gap.h32,
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        // Call the navigateToResetPassword from the view model
                        onTap: loginViewModel.navigateToResetPassword,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Can\'t remember your password? ',
                                  style: TextStyle(
                                    color: AppColors.darkgrey,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Reset it. ',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap.h16,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
