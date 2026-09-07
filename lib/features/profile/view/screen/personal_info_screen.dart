// lib/features/profile/view/screens/personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/provider/user_provider.dart'; // To get initial user data
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/features/profile/view_model/personal_info_view_model.dart';
import 'package:starter_codes/widgets/modal_form_field.dart';
import 'package:starter_codes/widgets/phone_number_input.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _stateController;

  /// The values this screen opened with. Used to tell a real edit from a tap,
  /// so we never send an update request that changes nothing.
  late final PersonalInfoState _initial;

  /// Errors stay hidden until the first save attempt, then track every keystroke.
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
    _emailController = TextEditingController(text: initialPersonalInfo.email);
    _stateController =
        TextEditingController(text: initialPersonalInfo.address);

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
    _emailController.addListener(() {
      ref
          .read(personalInfoViewModelProvider.notifier)
          .updateEmail(_emailController.text);
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
    _emailController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: AppText.body(
                    'Profile photo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap.h8,
                ListTile(
                  leading: const Icon(PhosphorIconsRegular.camera),
                  title: AppText.body('Take a picture'),
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(personalInfoViewModelProvider.notifier)
                        .pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(PhosphorIconsRegular.images),
                  title: AppText.body('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(personalInfoViewModelProvider.notifier)
                        .pickImage(ImageSource.gallery);
                  },
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
    final digits = _localPhoneDigits(state.phoneNumber);
    if (digits.isEmpty) return 'Enter your phone number';
    if (digits.length != 10) {
      return 'Enter a 10-digit phone number';
    }
    return null;
  }

  String? _stateError(PersonalInfoState state) {
    if (!_submitted) return null;
    if (state.address.trim().isEmpty) return 'Select your state';
    return null;
  }

  bool _hasErrors(PersonalInfoState state) =>
      _firstNameError(state) != null ||
      _lastNameError(state) != null ||
      _phoneError(state) != null ||
      _stateError(state) != null;

  Future<void> _submit(PersonalInfoState state) async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (_hasErrors(state)) return;
    // Success is taken from the return value rather than from state: saving
    // refreshes the user, which rebuilds the view model's provider and
    // disposes the notifier before it can publish a success message. Failures
    // are set while the notifier is still alive, so ref.listen below still
    // announces those.
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

  String _initials(PersonalInfoState state) {
    final first = state.firstname.trim();
    final last = state.lastname.trim();
    final buffer = StringBuffer();
    if (first.isNotEmpty) buffer.write(first[0]);
    if (last.isNotEmpty) buffer.write(last[0]);
    return buffer.toString().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final personalInfoState = ref.watch(personalInfoViewModelProvider);
    final profile = ref.watch(marketProfileProvider);
    final currentUser = ref.watch(userProvider);

    // Local pick wins, then the stored avatar, then initials. No network round
    // trip just to render an empty state.
    ImageProvider<Object>? displayImageProvider;
    if (personalInfoState.profileImage != null) {
      displayImageProvider = FileImage(personalInfoState.profileImage!);
    } else if (currentUser?.avatar?.imageUrl != null &&
        currentUser!.avatar!.imageUrl.isNotEmpty) {
      displayImageProvider = NetworkImage(currentUser.avatar!.imageUrl);
    }

    final initials = _initials(personalInfoState);
    final dirty = _isDirty(personalInfoState);

    ref.listen<PersonalInfoState>(personalInfoViewModelProvider,
        (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppStatusDialogs.showError(context, 'Error', next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: MiniAppBar(
        title: 'Personal Info',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _AvatarPicker(
                image: displayImageProvider,
                initials: initials,
                onTap: _showImagePickerOptions,
              ),
            ),
            Gap.h32,
            const _SectionHeader('Your name'),
            Gap.h12,
            _Field(
              label: 'First name',
              error: _firstNameError(personalInfoState),
              child: AppTextField(
                controller: _firstNameController,
                hint: 'First name',
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
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.familyName],
              ),
            ),
            Gap.h28,
            const _SectionHeader('How we reach you'),
            Gap.h12,
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
                hint: 'Enter phone number',
              ),
            ),
            Gap.h16,
            _Field(
              label: 'Email',
              helper: 'Your email cannot be changed here. Contact support to '
                  'update it.',
              child: AppTextField(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                enabled: false,
                suffixIcon: Icon(
                  PhosphorIconsRegular.lock,
                  size: 18.w,
                  color: AppColors.darkgrey,
                ),
              ),
            ),
            Gap.h28,
            const _SectionHeader('Where you are'),
            Gap.h12,
            _Field(
              label: profile.regionLabel,
              error: _stateError(personalInfoState),
              child: ModalFormField(
                controller: _stateController,
                title: 'Select ${profile.regionLabel}',
                options: profile.regions,
                modalHeightFactor: 0.9,
                onOptionSelected: _onStateSelected,
                enableSearch: true,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!dirty && !personalInfoState.isLoading) ...[
                AppText.caption(
                  'Nothing to save yet. Edit a field to continue.',
                  color: AppColors.darkgrey,
                  textAlign: TextAlign.center,
                ),
                Gap.h8,
              ],
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  title: 'Save changes',
                  loading: personalInfoState.isLoading,
                  onTap: (!dirty || personalInfoState.isLoading)
                      ? null
                      : () => _submit(personalInfoState),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section heading. Groups the form so the screen reads as three short
/// decisions rather than one undifferentiated stack of inputs.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppText.body(
      title,
      color: AppColors.black,
      fontWeight: FontWeight.w600,
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
        AppText.caption(label, color: AppColors.darkgrey),
        Gap.h8,
        child,
        if (message != null) ...[
          Gap.h4,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isError) ...[
                Padding(
                  padding: EdgeInsets.only(top: 2.w),
                  child: Icon(
                    PhosphorIconsRegular.warningCircle,
                    size: 14.w,
                    color: AppColors.red,
                  ),
                ),
                Gap.w4,
              ],
              Expanded(
                child: AppText.caption(
                  message,
                  color: isError ? AppColors.red : AppColors.darkgrey,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// The avatar doubles as the control that changes it, so it carries a visible
/// badge instead of relying on the user guessing that the circle is tappable.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.image,
    required this.initials,
    required this.onTap,
  });

  final ImageProvider<Object>? image;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Change profile photo',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 44.r,
                  backgroundImage: image,
                  child: image == null
                      ? (initials.isEmpty
                          ? Icon(
                              PhosphorIconsFill.user,
                              size: 40.w,
                              color: AppColors.white,
                            )
                          : AppText.h4(
                              initials,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ))
                      : null,
                ),
                PositionedDirectional(
                  end: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lightgrey),
                    ),
                    child: Icon(
                      PhosphorIconsFill.camera,
                      size: 14.w,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h8,
            AppText.caption('Change photo', color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
