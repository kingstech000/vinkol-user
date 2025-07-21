import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/base_view_model.dart';
import 'package:starter_codes/features/auth/data/auth_service.dart'; // Assuming you have an AuthService
import 'package:starter_codes/models/app_state/view_model_state.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/widgets/text_action_modal.dart';
import 'package:dio/dio.dart'; // Import dio for MultipartFile

class ProfileSettingViewModel extends BaseViewModel {
  final AuthService _authService;

  String _firstName = '';
  String _surname = '';
  String _country = '';
  String _selectedState = ' ';
  String _phoneNumberPrefix = '+234';
  String _phoneNumber = '';
  File? _profileImage;

  ProfileSettingViewModel(this._authService);

  // Getters
  String get firstName => _firstName;
  String get surname => _surname;
  String get country => _country;
  String get selectedState => _selectedState;
  String get phoneNumberPrefix => _phoneNumberPrefix;
  String get phoneNumber => _phoneNumber;
  File? get profileImage => _profileImage;

  // Setters
  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void setSurname(String value) {
    _surname = value;
    notifyListeners();
  }

  void setCountry(String value) {
    _country = value;
    notifyListeners();
  }

  void setSelectedState(String value) {
    _selectedState = value;
    notifyListeners();
  }

  void setPhoneNumberPrefix(String value) {
    _phoneNumberPrefix = value;
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  /// Handles picking an image from camera or gallery.
  Future<void> pickImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    changeState(const ViewModelState.busy());
       FocusScope.of(context).unfocus();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
        logger.i('Selected Profile Image: ${_profileImage?.path}');
      } else {
        logger.i('No image selected.');
      }
      changeState(const ViewModelState.idle());
      notifyListeners(); // Notify to update image display
    } on Failure catch (e) {
      logger.e('Image picking failed: ${e.message}');
      changeState(ViewModelState.error(e));
      textActionModal(
        context,
        onPressed: () => {},
        dialogText: e.message,
        buttonText: "Dismiss",
      );
    }
  }

  /// Submits the profile settings.
  Future<void> submitProfile({required BuildContext context}) async {
    changeState(const ViewModelState.busy());
    try {
      // Prepare MultipartFile for avatar if an image is selected
      MultipartFile? avatarFile;
      if (_profileImage != null) {
        avatarFile = await MultipartFile.fromFile(
          _profileImage!.path,
          filename: _profileImage!.path.split('/').last,
        );
      }

      await _authService.updateProfile(
        firstname: _firstName,
        lastName: _surname,
        state: _selectedState,
        phoneNumber: _phoneNumber,
        avatar: avatarFile,
      );

      logger.i('Profile setup successful for $_firstName $_surname');
      _authService.getUserProfile();
      changeState(const ViewModelState.idle());

      NavigationService.instance.navigateTo(
          NavigatorRoutes.dashboardScreen); // Navigate to dashboard after setup
    } on Failure catch (e) {
      logger.e('Profile setup failed: ${e.message}');
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

final profileSettingViewModelProvider =
    ChangeNotifierProvider<ProfileSettingViewModel>((ref) {
  final authService =
      ref.watch(authServiceProvider); // Assuming authServiceProvider is defined
  return ProfileSettingViewModel(authService);
});
