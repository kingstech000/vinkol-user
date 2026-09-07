import 'dart:developer';
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
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/market/market.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/l10n/l10n.dart';

class ProfileSettingViewModel extends BaseViewModel {
  final AuthService _authService;
  final LocalCache _localCache = locator<LocalCache>();

  String _firstName = '';
  String _surname = '';
  String _country = '';
  String _selectedState = '';
  String _phoneNumber = '';
  File? _profileImage;

  ProfileSettingViewModel(this._authService, this._ref);

  final Ref _ref;

  /// The dial code shown beside the phone field, and the one sent with the number. It belongs
  /// to the market the user picked on the country screen — it was a hardcoded `+234`, which
  /// is wrong the moment that choice is Canada.
  String get phoneNumberPrefix => MarketScope.market.phone.dialCode;

  // Getters
  String get firstName => _firstName;
  String get surname => _surname;
  String get country => _country;
  String get selectedState => _selectedState;
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
        buttonText: context.l10n.authDismiss,
      );
    }
  }

  /// Submits the profile settings.
  Future<void> submitProfile({required BuildContext context}) async {
    changeState(const ViewModelState.busy());
    FocusScope.of(context).unfocus();
    try {
      // The phone shape is market config, not a constant. This used to run through
      // PhoneNumberUtils, which rejects any dial code that is not +234 and demands exactly
      // 10 digits — a Canadian user could never get past it, whatever the picker said.
      final phoneConfig = MarketScope.market.phone;
      if (!phoneConfig.isValidNational(_phoneNumber)) {
        changeState(const ViewModelState.idle());
        textActionModal(
          context,
          onPressed: () => {},
          dialogText:
              context.l10n.profilePhoneRequired(phoneConfig.nationalDigits),
          buttonText: context.l10n.authOk,
        );
        return;
      }
      final String formattedPhoneNumber =
          phoneConfig.international(_phoneNumber);

      // Prepare MultipartFile for avatar if an image is selected
      MultipartFile? avatarFile;
      if (_profileImage != null) {
        avatarFile = await MultipartFile.fromFile(
          _profileImage!.path,
          filename: _profileImage!.path.split('/').last,
        );
      }

      logger.i('Sending formatted phone number: $formattedPhoneNumber');
      log("{$_firstName, $_surname, $_selectedState, $formattedPhoneNumber, Avatar: ${avatarFile != null}}");
      await _authService.updateProfile(
        firstname: _firstName,
        lastName: _surname,
        state: _selectedState,
        phoneNumber:
            formattedPhoneNumber, // Use the validated and formatted number
        avatar: avatarFile,
      );

      // Clear guest mode when profile is successfully completed
      await GuestModeUtils.clearGuestMode();

      // Tax and pricing resolve from the region, so the active one has to match the one
      // just written to the account.
      //
      // Guarded on its own. The profile is already saved by this point, so a failure here
      // must not fall through to the outer catch — that would tell the user the save failed
      // and leave them on this screen when their account is in fact up to date. The region
      // also re-resolves from the account on the next profile fetch, so the worst case is
      // that pricing uses the previous region until then.
      try {
        await _ref
            .read(marketProvider.notifier)
            .setRegionByName(_selectedState);
      } catch (e) {
        logger.w('Could not sync the active region to $_selectedState: $e');
      }

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
        buttonText: context.l10n.commonTryAgain,
      );
    }
  }
}

final profileSettingViewModelProvider =
    ChangeNotifierProvider<ProfileSettingViewModel>((ref) {
  final authService =
      ref.watch(authServiceProvider); // Assuming authServiceProvider is defined
  return ProfileSettingViewModel(authService, ref);
});
