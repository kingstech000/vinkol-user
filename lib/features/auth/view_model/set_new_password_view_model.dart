// lib/features/auth/viewmodel/set_new_password_viewmodel.dart

import 'package:flutter/material.dart'; // Import Material for TextEditingController
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/base_view_model.dart';
import 'package:starter_codes/features/auth/data/auth_service.dart'; // Ensure this is correct
import 'package:starter_codes/models/app_state/view_model_state.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/provider/user_provider.dart'; // Import your providers (should contain resetEmailProvider and resetPasswordProvider)
import 'package:starter_codes/widgets/text_action_modal.dart';

class SetNewPasswordViewModel extends BaseViewModel {
  final AuthService _authService;
  final Ref _ref; // To access other providers

  // Declare controllers as public
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  SetNewPasswordViewModel(this._authService, this._ref);

  // Remember to dispose controllers when the ViewModel is no longer needed
  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> setNewPassword({
    // Removed required newPassword, confirmPassword as they come from controllers
    required BuildContext context,
  }) async {
    final String newPassword = newPasswordController.text; // Get text from controller
    final String confirmPassword = confirmPasswordController.text; // Get text from controller

    // Basic validation within ViewModel (can also be done in UI validator)
    if (newPassword != confirmPassword) {
      // changeState(const ViewModelState.error(Failure('Passwords do not match.'))); // You had this commented, but it's good for state
      textActionModal(
        context,
        onPressed: () => NavigationService.instance.goBack(), // Or just close dialog
        dialogText: 'Passwords do not match. Please re-enter.',
        buttonText: "Okay",
      );
      return;
    }

    // Get email and OTP from providers
    final String email = _ref.read(resetEmailProvider)!; // Added String type hint for clarity
    final String otp = _ref.read(resetPasswordProvider)!; // Added String type hint for clarity

    if (otp.isEmpty) {
      // changeState(const ViewModelState.error(Failure('OTP not found. Please restart the password reset process.')));
      textActionModal(
        context,
        onPressed: () => NavigationService.instance.navigateToReplace(NavigatorRoutes.resetPasswordScreen),
        dialogText: 'OTP not found. Please restart the process.',
        buttonText: "Restart",
      );
      return;
    }

    changeState(const ViewModelState.busy());
    try {
      // Call your AuthService method to set the new password
      await _authService.setPassword(
        // Assuming setPassword also takes email
        otp: otp,
        password: newPassword,
      );

      logger.i('Password reset successful for email: $email');
      changeState(const ViewModelState.idle());

      // Navigate to success screen
      NavigationService.instance.navigateToReplaceAll(
          NavigatorRoutes.passwordResetSuccessScreen); // Navigate to success screen and remove all previous routes
    } on Failure catch (e) {
      logger.e('Password reset failed: ${e.message}');
      changeState(ViewModelState.error(e));
      textActionModal(
        context,
        onPressed: () => NavigationService.instance.goBack(), // Or simply close the dialog
        dialogText: e.message,
        buttonText: "Try Again",
      );
    }
  }
}

/// Riverpod provider for SetNewPasswordViewModel
final setNewPasswordViewModelProvider = ChangeNotifierProvider<SetNewPasswordViewModel>((ref) {
  final authService = ref.watch(authServiceProvider); // Assuming authServiceProvider exists
  return SetNewPasswordViewModel(authService, ref);
});