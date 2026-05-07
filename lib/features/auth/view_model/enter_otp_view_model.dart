// lib/features/auth/viewmodel/otp_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/base_view_model.dart'; // Assuming BaseViewModel extends ChangeNotifier or provides notifyListeners
import 'package:starter_codes/features/auth/data/auth_service.dart'; // Your AuthService
import 'package:starter_codes/models/app_state/view_model_state.dart'; // Your ViewModelState
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/provider/user_provider.dart'; // Contains resetPasswordProvider
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

class OtpViewModel extends BaseViewModel {
  final AuthService _authService;
  // This Ref is crucial for interacting with other providers within the ViewModel's methods
  final Ref _ref; // Add Ref here

  String _email = ''; // This should be set from the previous screen or cached

  OtpViewModel(this._authService, this._ref); // Initialize Ref in constructor

  String get email => _email;

  void setEmail(String email) {
    _email = email;
    notifyListeners(); // Notify listeners if UI depends on this
  }

  Future<void> verifyOtp({
    required String otp,
    required BuildContext context,
  }) async {
    try {
      // changeState(const ViewModelState.busy());
      _ref.read(resetPasswordProvider.notifier).state = otp;

      logger.i('OTP verification successful for email: $_email');
      changeState(const ViewModelState.idle());

      // Navigate to the next screen after successful OTP verification,
      // which is typically setting a new password or the dashboard if it's a new signup.
      NavigationService.instance.navigateToReplace(
          NavigatorRoutes.setNewPasswordScreen); // Adjust as per your flow
    } on Failure catch (e) {
      logger.e('OTP verification failed: ${e.message}');
      changeState(ViewModelState.error(e));
      AppStatusDialogs.showError(
        context,
        'Verification Failed',
        e.message,
      );
    }
  }

  Future<void> resendOtp({required BuildContext context}) async {
    changeState(const ViewModelState.busy());
    try {
      await _authService.resendOtp(email: _email);

      logger.i('OTP resend request successful for email: $_email');
      changeState(const ViewModelState.idle());
      // Optionally show a success message to the user that OTP has been resent
      AppStatusDialogs.showSuccess(context, 'Success', 'OTP has been resent!');
    } on Failure catch (e) {
      logger.e('Failed to resend OTP: ${e.message}');
      changeState(ViewModelState.error(e));
      AppStatusDialogs.showError(
        context,
        'Resend Failed',
        e.message,
      );
    }
  }
}

/// Riverpod provider for OtpViewModel
final otpViewModelProvider = ChangeNotifierProvider<OtpViewModel>((ref) {
  final authService = ref.watch(authServiceProvider);
  // Pass ref to the OtpViewModel constructor
  return OtpViewModel(authService, ref);
});
