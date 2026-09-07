// lib/features/profile/view_model/personal_info_state.dart
import 'dart:io';
import 'package:starter_codes/features/auth/data/auth_service.dart';
import 'package:starter_codes/features/auth/model/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:starter_codes/core/market/market_provider.dart';
import 'package:starter_codes/core/market/market_scope.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/provider/user_provider.dart';

final personalInfoViewModelProvider =
    StateNotifierProvider<PersonalInfoViewModel, PersonalInfoState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final user = ref.watch(userProvider);
  return PersonalInfoViewModel(authService, user, ref);
});

class PersonalInfoViewModel extends StateNotifier<PersonalInfoState> {
  final AuthService _authService;
  final AppLogger logger = const AppLogger(PersonalInfoViewModel);
  final Ref _ref;

  PersonalInfoViewModel(this._authService, User? initialUser, this._ref)
      : super(PersonalInfoState.fromUser(initialUser));

  // Update methods
  void updateFirstName(String value) => _updateField(firstname: value);

  void updateLastName(String value) => _updateField(lastname: value);

  void updateEmail(String value) => _updateField(email: value);

  void updatePhoneNumber(String value) => _updateField(phoneNumber: value);

  void updateAddress(String value) => _updateField(address: value);

  void _updateField({
    String? firstname,
    String? lastname,
    String? email,
    String? phoneNumber,
    String? address,
  }) {
    state = state.copyWith(
      firstname: firstname,
      lastname: lastname,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      errorMessage: null,
      successMessage: null,
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        logger.d('No image selected.');
        return;
      }

      if (!mounted) return;

      state = state.copyWith(
        profileImage: File(pickedFile.path),
        errorMessage: null,
        successMessage: null,
      );

      logger.d('Image picked: ${pickedFile.path}');
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        errorMessage: L10n.current.profilePhotoFailed,
      );
      logger.e('Error picking image: $e');
    }
  }

  Future<bool> updateProfile() async {
    if (!mounted) return false;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      // Prepare avatar file if image is selected
      MultipartFile? avatarFile;
      if (state.profileImage != null) {
        avatarFile = await MultipartFile.fromFile(
          state.profileImage!.path,
          filename: state.profileImage!.path.split('/').last,
        );
      }

      // The phone shape is market config, not a constant. This used to strip a literal
      // '+234' and demand 10 digits, which is wrong the moment the market is Canada.
      final phoneConfig = MarketScope.market.phone;
      final phoneNumber = state.phoneNumber.trim();

      if (!phoneConfig.isValidNational(phoneNumber)) {
        if (!mounted) return false;

        state = state.copyWith(
          isLoading: false,
          errorMessage:
              L10n.current.profilePhoneRequired(phoneConfig.nationalDigits),
        );
        return false;
      }

      final formattedPhoneNumber = phoneConfig.international(phoneNumber);
      logger.i('Sending phone number to backend: $formattedPhoneNumber');
      logger.i(
          'Full update payload - firstname: ${state.firstname}, lastName: ${state.lastname}, state: ${state.address}');

      await _authService.updateProfile(
        firstname: state.firstname,
        lastName: state.lastname,
        state: state.address,
        phoneNumber: formattedPhoneNumber,
        avatar: avatarFile,
      );

      logger.i('Backend call completed successfully');

      if (!mounted) return true;

      await _authService.getUserProfile();

      // Keep the active region in step with the one on the account. Tax and pricing resolve
      // from the region, so leaving the two out of sync quietly prices the wrong province.
      await _ref.read(marketProvider.notifier).setRegionByName(state.address);

      if (!mounted) return true;

      state = state.copyWith(
        isLoading: false,
        successMessage: L10n.current.profileSaved,
      );

      logger.i('Profile update successful!');
      return true;
    } on Failure catch (e) {
      if (!mounted) return false;

      logger.e('Backend returned Failure: ${e.message}');
      logger.e('This error is from your backend API, not Flutter validation');

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      logger.e('Profile update failed: ${e.message}');
      return false;
    } catch (e) {
      if (!mounted) return false;

      state = state.copyWith(
        isLoading: false,
        errorMessage: L10n.current.profileSaveFailed,
      );
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
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  factory PersonalInfoState.fromUser(User? user) {
    return PersonalInfoState(
      firstname: user?.firstname ?? '',
      lastname: user?.lastname ?? '',
      email: user?.email ?? '',
      phoneNumber: user?.phoneNumber ?? '',
      address: user?.state ?? '',
    );
  }
}
