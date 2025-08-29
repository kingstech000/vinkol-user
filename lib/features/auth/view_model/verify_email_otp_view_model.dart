import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/base_view_model.dart';
import 'package:starter_codes/features/auth/data/auth_service.dart'; // Your AuthService
import 'package:starter_codes/models/app_state/view_model_state.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/widgets/text_action_modal.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'dart:async'; // Import for Timer

class VerifyEmailOtpViewModel extends BaseViewModel {
  final AuthService _authService;
  final LocalCache _localCache = locator<LocalCache>();
  String _email = ''; // Internal state for the email

  // Cooldown properties
  Timer? _resendTimer;
  int _secondsRemaining = 0;
  static const int _resendCooldownDuration = 30; // 30 seconds cooldown

  VerifyEmailOtpViewModel(this._authService) {
    // Initialize cooldown state. If we want it to start on screen load,
    // it should be called in the screen's initState and passed to ViewModel.
    // For now, it will start after the first resend.
  }

  String get email => _email;
  int get secondsRemaining => _secondsRemaining;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  /// Starts or resumes the resend cooldown timer.
  void startResendCooldown() {
    // If a timer is already active, cancel it to avoid multiple timers
    _resendTimer?.cancel();

    _secondsRemaining = _resendCooldownDuration;
    notifyListeners(); // Notify immediately to show 30s countdown

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
      } else {
        timer.cancel(); // Stop the timer when countdown reaches 0
      }
      notifyListeners(); // Notify to update UI with new seconds remaining
    });
  }

  void clearField() {
    _email = '';
    _resendTimer
        ?.cancel(); // Cancel timer when fields are cleared/screen leaves
    _secondsRemaining = 0; // Reset countdown
    notifyListeners();
  }

  @override
  void dispose() {
    _resendTimer
        ?.cancel(); // Ensure the timer is cancelled when ViewModel is disposed
    super.dispose();
  }

  /// Verifies the email OTP.
  Future<void> verifyEmailOtp({
    required String otp,
    required BuildContext context,
  }) async {
    changeState(const ViewModelState.busy());
    FocusScope.of(context).unfocus();
    try {
      // Basic validation
      if (otp.isEmpty || otp.length != 4) {
        throw 'Please enter a valid 4-digit OTP.'; // Throw a String for this specific error
      }

      await _authService.verifyEmail(email: _email, otp: otp);

      // Clear guest mode when email is successfully verified
      await GuestModeUtils.clearGuestMode();

      logger.i('Email OTP verification successful for $_email');
      clearField(); // Clear fields and stop countdown on success
      await _authService.getUserProfile();
      changeState(const ViewModelState.idle());

      // Navigate to the next screen after successful verification
      NavigationService.instance
          .navigateTo(NavigatorRoutes.profileSettingScreen);
    } on Failure catch (e) {
      logger.e('Email OTP verification failed: ${e.message}');
      changeState(ViewModelState.error(e));
      textActionModal(
        context,
        onPressed: () => {},
        dialogText: e.message,
        buttonText: "Try Again",
      );
    }
  }

  /// Resends the email OTP.
  Future<void> resendEmailOtp({
    required BuildContext context,
  }) async {
    // Prevent resending if cooldown is active
    if (_secondsRemaining > 0) {
      // Optionally show a message to the user that they need to wait
      textActionModal(
        context,
        onPressed: () => {},
        dialogText:
            'Please wait $_secondsRemaining seconds before resending OTP.',
        buttonText: "Okay",
      );
      return;
    }

    changeState(const ViewModelState.busy());
    try {
      await _authService.resendOtp(email: _email);

      logger.i('Email OTP resend successful for $_email');
      changeState(const ViewModelState.idle());

      startResendCooldown(); // Start cooldown after successful resend

      // Optionally show a success message to the user
      textActionModal(
        context,
        onPressed: () => {},
        dialogText: 'A new OTP has been sent to $_email.',
        buttonText: "Okay",
      );
    } on Failure catch (e) {
      logger.e('Email OTP resend failed: ${e.message}');
      changeState(ViewModelState.error(e));
      textActionModal(
        context,
        onPressed: () => {},
        dialogText: e.message,
        buttonText: "Try Again",
      );
    }
  }
}

/// Riverpod provider for VerifyEmailOtpViewModel
final verifyEmailOtpViewModelProvider =
    ChangeNotifierProvider<VerifyEmailOtpViewModel>((ref) {
  final authService = ref.watch(authServiceProvider);
  return VerifyEmailOtpViewModel(authService);
});
