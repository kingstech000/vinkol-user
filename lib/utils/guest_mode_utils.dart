import 'package:flutter/material.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/widgets/auth_prompt_bottom_sheet.dart';

class GuestModeUtils {
  static final localCache = locator<LocalCache>();

  /// Check if the current user is in guest mode
  static bool isGuestMode() {
    return localCache.isGuestMode();
  }

  /// Force refresh guest mode state from cache
  static Future<bool> refreshGuestModeState() async {
    // This method can be used to force refresh the guest mode state
    // Useful when the state might be stale
    return localCache.isGuestMode();
  }

  /// Clear guest mode and return the new state
  static Future<bool> clearGuestMode() async {
    await localCache.setGuestMode(false);
    return false; // Return false since guest mode is now cleared
  }

  /// Show auth prompt for guest users when they try to access authenticated features
  static void showAuthPromptForGuest(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
  }) {
    if (isGuestMode()) {
      AuthPromptBottomSheet.show(
        context,
        title: title,
        message: message,
        actionText: actionText,
      );
    }
  }

  /// Check if user can access a feature (not in guest mode)
  /// Returns true if user is authenticated, false if guest
  static bool canAccessFeature() {
    return !isGuestMode();
  }

  /// Wrapper for actions that require authentication
  /// If user is guest, shows auth prompt and returns false
  /// If user is authenticated, returns true and allows action to proceed
  static bool requireAuthForAction(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
  }) {
    if (isGuestMode()) {
      showAuthPromptForGuest(
        context,
        title: title,
        message: message,
        actionText: actionText,
      );
      return false;
    }
    return true;
  }

  /// Specific method for delivery booking
  static bool requireAuthForDelivery(BuildContext context) {
    return requireAuthForAction(
      context,
      title: 'Authentication Required',
      message: 'Please sign up or login to book delivery services.',
    );
  }

  /// Specific method for store purchases
  static bool requireAuthForStorePurchase(BuildContext context) {
    return requireAuthForAction(
      context,
      title: 'Authentication Required',
      message: 'Please sign up or login to make purchases.',
    );
  }

  /// Method to check auth when user tries to buy from store
  /// This should be called when user clicks "Buy" or "Add to Cart" buttons
  static bool requireAuthForBuying(BuildContext context) {
    return requireAuthForAction(
      context,
      title: 'Authentication Required',
      message: 'Please sign up or login to complete your purchase.',
    );
  }

  /// Specific method for wallet operations
  static bool requireAuthForWallet(BuildContext context) {
    return requireAuthForAction(
      context,
      title: 'Authentication Required',
      message: 'Please sign up or login to access wallet features.',
    );
  }
}
