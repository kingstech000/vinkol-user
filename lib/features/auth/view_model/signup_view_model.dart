// lib/features/auth/viewmodel/signup_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/base_view_model.dart';
import 'package:starter_codes/features/auth/data/auth_service.dart';
import 'package:starter_codes/models/app_state/view_model_state.dart'; // Your ViewModelState
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/text_action_modal.dart'; // Your text_action_modal
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';

class SignUpViewModel extends BaseViewModel {
  final AuthService _authService;
  final Ref ref;
  final LocalCache _localCache = locator<LocalCache>();

  SignUpViewModel(this._authService, this.ref);

  void navigateToLogin() {
    NavigationService.instance.navigateTo(NavigatorRoutes.loginScreen);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required bool termsAgreed,
    required BuildContext context,
  }) async {
    changeState(const ViewModelState.busy());
    FocusScope.of(context).unfocus();
    try {
      await _authService.signup(
        email: email,
        password: password,
      );

      // Clear guest mode when user successfully signs up
      await GuestModeUtils.clearGuestMode();

      changeState(const ViewModelState.idle());
      ref.watch(verifyEmailProvider.notifier).state = email;
      NavigationService.instance
          .navigateTo(NavigatorRoutes.verifyEmailOtpScreen);
    } on Failure catch (e) {
      logger.e('Signup failed: ${e.message}');
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

/// Riverpod provider for SignUpViewModel
final signUpViewModelProvider = ChangeNotifierProvider<SignUpViewModel>((ref) {
  final authService = ref.watch(
      authServiceProvider); // Assuming authServiceProvider is defined in auth_service.dart
  return SignUpViewModel(authService, ref);
});
