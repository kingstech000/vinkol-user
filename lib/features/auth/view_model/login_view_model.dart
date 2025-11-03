// lib/features/auth/viewmodel/login_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/base_view_model.dart';
import 'package:starter_codes/features/auth/data/auth_service.dart';
import 'package:starter_codes/models/app_state/view_model_state.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/widgets/text_action_modal.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/provider/user_provider.dart';

class LoginViewModel extends BaseViewModel {
  final AuthService _authService;
  final Ref ref;
  final LocalCache _localCache = locator<LocalCache>();

  String _email = '';
  String _password = '';

  LoginViewModel(this._authService, this.ref);

  String get email => _email;
  String get password => _password;

  // Setters to update state and notify listeners
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  /// Clears the email and password fields in the ViewModel.
  void clearFields() {
    _email = '';
    _password = '';
    notifyListeners();
  }

  Future<void> login({required BuildContext context}) async {
    changeState(const ViewModelState.busy());
    FocusScope.of(context).unfocus();
    try {
      final responseData = await _authService.login(
        email: _email,
        password: _password,
      );

      // Check if login was successful
      if (responseData['success'] == true) {
        final userData = responseData['data'] as Map<String, dynamic>;
        final isEmailVerified = userData['isEmailVerified'] ?? false;
        final message = responseData['message'] ?? '';

        if (!isEmailVerified) {
          // Email not verified - send OTP first, then redirect to verification screen
          logger.i(
              'Login successful but email not verified. Sending OTP first, then redirecting to verification screen.');

          // Store email in provider for verification screen
          ref.read(verifyEmailProvider.notifier).state = _email;

          // Send OTP first before navigating

          // Show message and navigate to verification screen
          textActionModal(
            context,
            onPressed: () async {
              try {
                await _authService.resendOtp(email: _email);
                logger.i('OTP sent successfully for: $_email');
                // Navigate to verification screen after user dismisses message
                NavigationService.instance
                    .navigateToReplace(NavigatorRoutes.verifyEmailOtpScreen);
              } catch (e) {
                logger.e('Failed to send OTP: $e');
                // Continue anyway - user can request OTP again on verification screen
              }
            },
            dialogText: message,
            buttonText: "Verify Email",
          );

          changeState(const ViewModelState.idle());
          return;
        }

        // Email is verified - proceed with normal login flow
        logger.i('Login successful! Email verified. Proceeding to dashboard.');

        _authService.sendFcmTokenToBackend();

        await _authService.getUserProfile();

        // Clear guest mode when user successfully logs in
        await GuestModeUtils.clearGuestMode();

        clearFields();

        changeState(const ViewModelState.idle());

        NavigationService.instance
            .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
      } else {
        // Login failed
        textActionModal(
          context,
          onPressed: () {},
          dialogText: responseData['message'] ?? 'Login failed',
          buttonText: "Dismiss",
        );
      }
    } on Failure catch (e) {
      logger.e('Login failed: ${e.message}');
      changeState(ViewModelState.error(e));
      textActionModal(
        context,
        onPressed: () {},
        dialogText: e.message,
        buttonText: "Dismiss",
      );
    }
  }

  void navigateToResetPassword() {
    NavigationService.instance.navigateTo(NavigatorRoutes.resetPasswordScreen);
  }
}

final loginViewModelProvider = ChangeNotifierProvider<LoginViewModel>((ref) {
  final authService =
      ref.watch(authServiceProvider); // Get AuthService from its provider
  return LoginViewModel(authService, ref);
});
