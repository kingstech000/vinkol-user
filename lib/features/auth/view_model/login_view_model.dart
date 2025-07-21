// lib/features/auth/viewmodel/login_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/base_view_model.dart'; // Your BaseViewModel
import 'package:starter_codes/features/auth/data/auth_service.dart'; // Your AuthService
import 'package:starter_codes/models/app_state/view_model_state.dart'; // Your ViewModelState
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/widgets/text_action_modal.dart'; // Your text_action_modal

class LoginViewModel extends BaseViewModel {
  final AuthService _authService;

  String _email = '';
  String _password = '';

  LoginViewModel(this._authService);

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
      await _authService.login(
        email: _email,
        password: _password,
      );

      logger.i('Login successful!');
      await _authService.getUserProfile();

      clearFields();

      changeState(const ViewModelState.idle());

      NavigationService.instance.navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
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
  return LoginViewModel(authService);
});
