// lib/features/profile/view_model/personal_info_state.dart
import 'dart:io';
import 'package:starter_codes/features/auth/data/auth_service.dart';
import 'package:starter_codes/features/auth/model/user_model.dart'; // Assuming your User model is here

import 'package:dio/dio.dart'; // Import Dio for MultipartFile
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/utils/phone_number_utils.dart';

final personalInfoViewModelProvider =
    StateNotifierProvider<PersonalInfoViewModel, PersonalInfoState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final user =
      ref.watch(userProvider); // Listen to user changes for initial state
  return PersonalInfoViewModel(authService, user, ref);
});

class PersonalInfoViewModel extends StateNotifier<PersonalInfoState> {
  final AuthService _authService;
  final AppLogger logger = const AppLogger(PersonalInfoViewModel);
  final Ref _ref;

  PersonalInfoViewModel(this._authService, User? initialUser, this._ref)
      : super(PersonalInfoState.fromUser(initialUser));

  // Methods to update individual fields in the state
  void updateFirstName(String value) {
    state = state.copyWith(
        firstname: value, errorMessage: null, successMessage: null);
  }

  void updateLastName(String value) {
    state = state.copyWith(
        lastname: value, errorMessage: null, successMessage: null);
  }

  void updateEmail(String value) {
    state =
        state.copyWith(email: value, errorMessage: null, successMessage: null);
  }

  void updatePhoneNumber(String value) {
    state = state.copyWith(
        phoneNumber: value, errorMessage: null, successMessage: null);
  }

  void updateAddress(String value) {
    state = state.copyWith(
        address: value, errorMessage: null, successMessage: null);
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        // Ensure the StateNotifier is still mounted before updating state
        if (!mounted) return;
        state = state.copyWith(
            profileImage: File(pickedFile.path),
            errorMessage: null,
            successMessage: null);
        logger.d('Image picked: ${pickedFile.path}');
      } else {
        logger.d('No image selected.');
      }
    } catch (e) {
      // Ensure the StateNotifier is still mounted before updating state
      if (!mounted) return;
      state =
          state.copyWith(errorMessage: 'Failed to pick image: ${e.toString()}');
      logger.e('Error picking image: $e');
    }
  }

  Future<bool> updateProfile() async {
    // Set loading state and clear previous messages
    if (!mounted)
      return false; // Important: Check mounted at the very beginning
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      MultipartFile? avatarFile;
      if (state.profileImage != null) {
        avatarFile = await MultipartFile.fromFile(state.profileImage!.path,
            filename: state.profileImage!.path.split('/').last);
      }

      // Validate and format phone number before sending to service
      String? formattedPhoneNumber =
          PhoneNumberUtils.validateAndFormatPhoneNumber(
              state.phoneNumber, '+234' // Assuming Nigerian country code
              );

      if (formattedPhoneNumber == null) {
        state = state.copyWith(
          errorMessage:
              "Please enter a valid Nigerian phone number (10 digits starting with 70, 80, 81, 90, or 91)",
          successMessage: null,
        );
        return false;
      }

      // Additional validation for Nigerian mobile number patterns
      if (!PhoneNumberUtils.isValidNigerianNumber(formattedPhoneNumber)) {
        state = state.copyWith(
          errorMessage:
              "Please enter a valid Nigerian mobile number (starting with 70, 80, 81, 90, or 91)",
          successMessage: null,
        );
        return false;
      }

      logger.i('Sending formatted phone number: $formattedPhoneNumber');

      await _authService.updateProfile(
        firstname: state.firstname,
        lastName: state.lastname,
        state: state
            .address, // Assuming 'address' in your state maps to 'state' in backend
        phoneNumber:
            formattedPhoneNumber, // Use the validated and formatted number
        avatar: avatarFile,
      );

      // IMPORTANT: Check if the StateNotifier is still mounted BEFORE updating state
      // after an asynchronous operation, especially if navigation might occur.
      if (!mounted)
        return true; // Return true because the operation succeeded from a business logic perspective

      // After successful update, fetch the latest user profile to update the userProvider
      // This is another async call, so another mounted check might be prudent if it's long-running.
      await _authService.getUserProfile();

      // IMPORTANT: Check mounted again before final state update
      if (!mounted)
        return true; // Operation succeeded, but we can't update state

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Profile updated successfully!',
        errorMessage: null, // Clear any previous error message
      );
      logger.i('Profile update successful!');
      return true;
    } on Failure catch (e) {
      // IMPORTANT: Check mounted before updating state in catch block
      if (!mounted) return false;
      state = state.copyWith(
          isLoading: false, errorMessage: e.message, successMessage: null);
      logger.e('Profile update failed: ${e.message}');
      return false;
    } catch (e) {
      // IMPORTANT: Check mounted before updating state in catch block
      if (!mounted) return false;
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'An unexpected error occurred: ${e.toString()}',
          successMessage: null);
      logger.e('Unexpected error during profile update: $e');
      return false;
    }
  }
}

class PersonalInfoState {
  final String firstname;
  final String lastname;
  final String email;
  final String phoneNumber;
  final String address;
  final File? profileImage;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const PersonalInfoState({
    this.firstname = '',
    this.lastname = '',
    this.email = '',
    this.phoneNumber = '',
    this.address = '',
    this.profileImage,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  // Manual copyWith method for creating new state instances with updated values
  PersonalInfoState copyWith({
    String? firstname,
    String? lastname,
    String? email,
    String? phoneNumber,
    String? address,
    File? profileImage,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return PersonalInfoState(
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Explicitly pass null to clear
      successMessage: successMessage, // Explicitly pass null to clear
    );
  }

  // Factory constructor to initialize state from a User model
  factory PersonalInfoState.fromUser(User? user) {
    return PersonalInfoState(
      firstname: user?.firstname ?? '',
      lastname: user?.lastname ?? '',
      email: user?.email ?? '',
      phoneNumber: user?.phoneNumber ?? '',
      address: user?.state ??
          '', // Assuming 'state' in User model maps to 'address' on screen
    );
  }
}
