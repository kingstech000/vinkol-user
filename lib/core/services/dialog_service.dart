import 'package:flutter/material.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

class DialogService {
  final GlobalKey<NavigatorState> _navigatorKey = NavigationService.instance.navigatorKey;

  void showError(String title, String message) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      AppStatusDialogs.showError(context, title, message);
    }
  }

  void showSuccess(String title, String message, {VoidCallback? onClosed}) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      AppStatusDialogs.showSuccess(context, title, message, onClosed: onClosed);
    }
  }

  void showConfirmation({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      AppStatusDialogs.showConfirmation(
        context,
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
      );
    }
  }
}
