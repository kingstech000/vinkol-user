// lib/provider/user/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/auth/model/user_model.dart'; // Import your User model

/// This notifier manages the current authenticated user's data.
/// It holds a User object, which can be null if no user is logged in.
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null); // Initial state is null (no user logged in)

  /// Sets the current user.
  /// This is typically called after successful login, signup, or profile fetch.
  void setUser(User user) {
    state = user;
  }

  /// Clears the current user.
  /// This is typically called on logout.
  void clearUser() {
    state = null;
  }

  /// Updates specific properties of the current user.
  /// It uses the copyWith method of the User model for efficient updates.
  void updateUserProfile({
    String? firstname,
    String? lastname,
    String? phoneNumber,
    String? stateParam, // Renamed 'state' to 'stateParam' to avoid conflict
    Avatar? avatar,
  }) {
    if (state == null) return; // Cannot update if no user is logged in

    state = state!.copyWith(
      firstname: firstname,
      lastname: lastname,
      phoneNumber: phoneNumber,
      state: stateParam, // Use the renamed parameter here
      avatar: avatar,
    );
  }

  // You can add more methods here to update other parts of the user state
  // or to check user roles, permissions, etc.
}

/// Provider for the UserNotifier.
/// Widgets can listen to this provider to react to changes in the user's authentication state.
final userProvider = StateNotifierProvider<UserNotifier, User?>(
  (ref) => UserNotifier(),
);

final resetEmailProvider = StateProvider<String>((ref) => '');

final verifyEmailProvider = StateProvider<String>((ref) => '');

final resetPasswordProvider = StateProvider<String?>((ref) => '');

