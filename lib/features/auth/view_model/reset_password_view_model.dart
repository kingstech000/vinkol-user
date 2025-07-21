// lib/features/auth/viewmodel/reset_password_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/base_view_model.dart';
import 'package:starter_codes/features/auth/data/auth_service.dart';
import 'package:starter_codes/models/app_state/view_model_state.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/text_action_modal.dart';

class ResetPasswordViewModel extends BaseViewModel {
  final AuthService _authService;
  final Ref _ref; // Add Ref to access other providers

  // Internal state for the email field
  String _email = '';

  // Constructor now takes Ref
  ResetPasswordViewModel(this._authService, this._ref);

  // Getter for UI to observe
  String get email => _email;

  // Setter to update state and notify listeners
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail({required BuildContext context}) async {
       FocusScope.of(context).unfocus();
    try {
      changeState(const ViewModelState.busy()); // Indicate busy state
      await _authService.forgotPassword(email: _email);

      logger.i('Password reset email sent successfully to $_email!');

      // Set the email in the resetEmailProvider after successful API call
      _ref.read(resetEmailProvider.notifier).state = _email;

      changeState(const ViewModelState.idle());

      NavigationService.instance.navigateTo(NavigatorRoutes.enterOtpCodeScreen);
    } on Failure catch (e) {
      logger.e('Failed to send password reset email: ${e.message}');
      changeState(ViewModelState.error(e));
      textActionModal(
        context,
        onPressed: () => NavigationService.instance.goBack(),
        dialogText: e.message,
        buttonText: "Dismiss",
      );
    }
  }
}

/// Riverpod provider for ResetPasswordViewModel
final resetPasswordViewModelProvider =
    ChangeNotifierProvider<ResetPasswordViewModel>((ref) {
  final authService =
      ref.watch(authServiceProvider); // Get AuthService from its provider
  return ResetPasswordViewModel(authService, ref); // Pass ref to the ViewModel
});
