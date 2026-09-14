// lib/features/profile/view/screens/personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/profile/view/widget/settings_group.dart';
import 'package:starter_codes/features/profile/view_model/personal_info_view_model.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/modal_form_field.dart';
import 'package:starter_codes/widgets/phone_number_input.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _stateController;

  late final PersonalInfoState _initial;

  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final initialPersonalInfo = ref.read(personalInfoViewModelProvider);
    _initial = initialPersonalInfo;

    _firstNameController =
        TextEditingController(text: initialPersonalInfo.firstname);
    _lastNameController =
        TextEditingController(text: initialPersonalInfo.lastname);
    _stateController = TextEditingController(text: initialPersonalInfo.address);

    // No email controller: the address is not editable here and is not part of
    // the update payload, so it is read straight off the account.
    _firstNameController.addListener(() {
      ref
          .read(personalInfoViewModelProvider.notifier)
          .updateFirstName(_firstNameController.text);
    });
    _lastNameController.addListener(() {
      ref
          .read(personalInfoViewModelProvider.notifier)
          .updateLastName(_lastNameController.text);
    });
    _stateController.addListener(() {
      ref
          .read(personalInfoViewModelProvider.notifier)
          .updateAddress(_stateController.text);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightgrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Gap.h20,
                AppText.h4('Profile photo'),
                Gap.h20,
                SettingsGroup(
                  children: [
                    SettingsRow(
                      icon: PhosphorIconsRegular.camera,
                      title: 'Take a picture',
                      affordance: RowAffordance.none,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ref
                            .read(personalInfoViewModelProvider.notifier)
                            .pickImage(ImageSource.camera);
                      },
                    ),
                    SettingsRow(
                      icon: PhosphorIconsRegular.images,
                      title: 'Choose from gallery',
                      affordance: RowAffordance.none,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ref
                            .read(personalInfoViewModelProvider.notifier)
                            .pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onStateSelected(String selectedState) {
    _stateController.text = selectedState;
    ref
        .read(personalInfoViewModelProvider.notifier)
        .updateAddress(selectedState);
  }

  /// Strips the dial code so a number can be compared and counted consistently,
  /// however PhoneNumberInput happened to hand it over.
  String _localPhoneDigits(String raw) {
    final trimmed = raw.trim().replaceAll(' ', '');
    final dial = ref.read(marketProfileProvider).dialCode;
    final digits = dial.replaceAll('+', '');
    if (trimmed.startsWith(dial)) return trimmed.substring(dial.length);
    if (trimmed.startsWith(digits)) return trimmed.substring(digits.length);
    return trimmed;
  }

  bool _isDirty(PersonalInfoState state) {
    return state.profileImage != null ||
        state.firstname.trim() != _initial.firstname.trim() ||
        state.lastname.trim() != _initial.lastname.trim() ||
        _localPhoneDigits(state.phoneNumber) !=
            _localPhoneDigits(_initial.phoneNumber) ||
        state.address.trim() != _initial.address.trim();
  }

  String? _firstNameError(PersonalInfoState state) {
    if (!_submitted) return null;
    if (state.firstname.trim().isEmpty) return 'Enter your first name';
    return null;
  }

  String? _lastNameError(PersonalInfoState state) {
    if (!_submitted) return null;
    if (state.lastname.trim().isEmpty) return 'Enter your last name';
    return null;
  }

  String? _phoneError(PersonalInfoState state) {
    if (!_submitted) return null;
    // The expected length is the market's, not Nigeria's. Both markets happen
    // to want ten digits today, which is exactly why hardcoding it would go
    // unnoticed until the third market.
    final expected = ref.read(marketProfileProvider).localPhoneDigits;
    final digits = _localPhoneDigits(state.phoneNumber);
    if (digits.isEmpty) return 'Enter your phone number';
    if (digits.length != expected) {
      return 'Enter a $expected-digit phone number';
    }
    return null;
  }

  String? _stateError(PersonalInfoState state, String regionLabel) {
    if (!_submitted) return null;
    if (state.address.trim().isEmpty) {
      return 'Select your ${regionLabel.toLowerCase()}';
    }
    return null;
  }

  bool _hasErrors(PersonalInfoState state, String regionLabel) =>
      _firstNameError(state) != null ||
      _lastNameError(state) != null ||
      _phoneError(state) != null ||
      _stateError(state, regionLabel) != null;

  Future<void> _submit(PersonalInfoState state, String regionLabel) async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (_hasErrors(state, regionLabel)) return;
    final updated =
        await ref.read(personalInfoViewModelProvider.notifier).updateProfile();
    if (!mounted || !updated) return;
    AppStatusDialogs.showSuccess(
      context,
      'Success',
      'Profile updated successfully!',
      onClosed: () => NavigationService.instance.goBack(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personalInfoState = ref.watch(personalInfoViewModelProvider);
    final profile = ref.watch(marketProfileProvider);
    final currentUser = ref.watch(userProvider);

    // Local pick wins, then the stored avatar, then the person glyph. No
    // network round trip just to render an empty state.
    ImageProvider<Object>? displayImageProvider;
    if (personalInfoState.profileImage != null) {
      displayImageProvider = FileImage(personalInfoState.profileImage!);
    } else if (currentUser?.avatar?.imageUrl != null &&
        currentUser!.avatar!.imageUrl.isNotEmpty) {
      displayImageProvider = NetworkImage(currentUser.avatar!.imageUrl);
    }

    final dirty = _isDirty(personalInfoState);

    ref.listen<PersonalInfoState>(personalInfoViewModelProvider,
        (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppStatusDialogs.showError(context, 'Error', next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: MiniAppBar(title: 'Personal info'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PhotoField(
              image: displayImageProvider,
              hasPhoto: displayImageProvider != null,
              onTap: _showImagePickerOptions,
            ),
            Gap.h28,
            _Field(
              label: 'First name',
              error: _firstNameError(personalInfoState),
              child: AppTextField(
                controller: _firstNameController,
                hint: 'First name',
                fillColor: AppColors.white,
                outlineColor: AppColors.lightgrey,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.givenName],
              ),
            ),
            Gap.h16,
            _Field(
              label: 'Last name',
              error: _lastNameError(personalInfoState),
              child: AppTextField(
                controller: _lastNameController,
                hint: 'Last name',
                fillColor: AppColors.white,
                outlineColor: AppColors.lightgrey,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.familyName],
              ),
            ),
            Gap.h28,
            _Field(
              label: 'Phone number',
              error: _phoneError(personalInfoState),
              helper: 'Your rider calls this number on the day of delivery.',
              child: PhoneNumberInput(
                initialPhoneNumber: personalInfoState.phoneNumber,
                onPhoneNumberChanged: (fullPhoneNumber) {
                  ref
                      .read(personalInfoViewModelProvider.notifier)
                      .updatePhoneNumber(fullPhoneNumber);
                },
                enabled: true,
                hint: profile.phoneExample,
              ),
            ),
            Gap.h16,
            _Field(
              label: 'Email',
              helper: 'Contact support to change the address on your account.',
              child: _ReadOnlyValue(
                value: personalInfoState.email.isNotEmpty
                    ? personalInfoState.email
                    : currentUser?.email ?? '',
              ),
            ),
            Gap.h28,
            _Field(
              label: profile.regionLabel,
              error: _stateError(personalInfoState, profile.regionLabel),
              child: ModalFormField(
                controller: _stateController,
                title: 'Select ${profile.regionLabel}',
                options: profile.regions,
                modalHeightFactor: 0.9,
                onOptionSelected: _onStateSelected,
                enableSearch: true,
                fillColor: AppColors.white,
                outlineColor: AppColors.lightgrey,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: BorderDirectional(
            top: BorderSide(color: AppColors.lightgrey),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!dirty && !personalInfoState.isLoading) ...[
                  AppText.caption(
                    'Nothing to save yet. Edit a field to continue.',
                    color: AppColors.darkgrey,
                    fontSize: 13,
                    textAlign: TextAlign.center,
                  ),
                  Gap.h8,
                ],
                SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    title: 'Save changes',
                    loading: personalInfoState.isLoading,
                    disable: !dirty,
                    onTap: () =>
                        _submit(personalInfoState, profile.regionLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The photo, and the control that changes it, in one row.
///
/// It used to be a 88pt circle centred over a third of the screen, which left
/// one and a half fields visible above the fold. Laid out like the identity
/// card on the profile hub, it costs a quarter of the height and the two
/// screens read as one flow.
/// The photo, centred on the canvas with its action beneath it, rather than
/// dressed up as a row in a card. It is the only thing on this screen that is a
/// picture, so it is allowed to be one.
class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.image,
    required this.hasPhoto,
    required this.onTap,
  });

  final ImageProvider<Object>? image;
  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Both the photo and the label do the same thing, so they announce
    // themselves to a screen reader once, as one button.
    return Semantics(
      button: true,
      label: hasPhoto ? 'Change profile photo' : 'Add a profile photo',
      excludeSemantics: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lightgrey),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary,
                    foregroundImage: image,
                    child: const Icon(
                      PhosphorIconsFill.user,
                      size: 36,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            Gap.h12,
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                customBorder: const StadiumBorder(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: AppText.body(
                    hasPhoto ? 'Change photo' : 'Add a photo',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkgrey.withOpacity(.3))),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText.body(
              value,
              fontSize: 15,
              color: AppColors.darkgrey,
              maxLines: 1,
            ),
          ),
          Gap.w12,
          const Icon(
            PhosphorIconsRegular.lock,
            size: 16,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }
}

/// Label above the field, message below it. One place decides the spacing and
/// the error treatment, so every field in the form behaves the same way.
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.child,
    this.error,
    this.helper,
  });

  final String label;
  final Widget child;
  final String? error;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final message = error ?? helper;
    final isError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.caption(
          label,
          color: AppColors.darkgrey,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        Gap.h8,
        child,
        if (message != null) ...[
          Gap.h6,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isError) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    PhosphorIconsRegular.warningCircle,
                    size: 14,
                    color: AppColors.redText,
                  ),
                ),
                Gap.w4,
              ],
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.blue.withOpacity(.1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.info_outline,
                            color: AppColors.blue,
                            size: 10,
                          ),
                        ),
                        Gap.w6,
                        Expanded(
                          child: AppText.free(
                            message,
                            fontSize: 12,
                            lineHeight: 1.4,
                            color: isError ? AppColors.redText : AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
