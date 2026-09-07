import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/market/market_profile.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/utils/phone_number_utils.dart';
import 'package:starter_codes/widgets/app_bar/empty_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal_form_field.dart';
import 'package:starter_codes/features/auth/view_model/profile_setting_view_model.dart';

class ProfileSettingScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  const ProfileSettingScreen({super.key});

  @override
  ConsumerState<ProfileSettingScreen> createState() =>
      _ProfileSettingScreenState(); // Changed to ConsumerState
}

class _ProfileSettingScreenState extends ConsumerState<ProfileSettingScreen> {
  // Controllers for text fields, now updated by ViewModel
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  // final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _phoneNumberPrefixController =
      TextEditingController(); // For +234

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// The region picker is not a FormField, so its error is tracked here.
  String? _stateError;

  // final List<String> _countries = [
  //   'Nigeria',
  //   // 'Ghana',
  //   // 'Kenya',
  //   // 'South Africa'
  // ]; // Example countries

  @override
  void initState() {
    super.initState();
    // Initialize controllers with values from the ViewModel
    final viewModel = ref.read(profileSettingViewModelProvider);
    _firstNameController.text = viewModel.firstName;
    _surnameController.text = viewModel.surname;
    // _countryController.text = viewModel.country;
    _stateController.text = viewModel.selectedState;
    _phoneNumberController.text = viewModel.phoneNumber;
    _adoptMarket(ref.read(marketProfileProvider), viewModel);

    // Add listeners to update ViewModel on text field changes
    _firstNameController.addListener(
      () => viewModel.setFirstName(_firstNameController.text),
    );
    _surnameController.addListener(
      () => viewModel.setSurname(_surnameController.text),
    );
    // _countryController
    //     .addListener(() => viewModel.setCountry(_countryController.text));
    _stateController.addListener(
      () => viewModel.setSelectedState(_stateController.text),
    );
    _phoneNumberController.addListener(
      () => viewModel.setPhoneNumber(_phoneNumberController.text),
    );
  }

  /// The dial code is the market's, never the customer's to type. The box is
  /// display-only, so it and the value that is actually submitted are set from
  /// the same place and cannot drift apart — which is how a Canadian customer
  /// ended up looking at +234.
  void _adoptMarket(MarketProfile profile, ProfileSettingViewModel viewModel) {
    _phoneNumberPrefixController.text = profile.dialCode;
    viewModel.setPhoneNumberPrefix(profile.dialCode);
    viewModel.setLocalPhoneDigits(profile.localPhoneDigits);
  }

  @override
  void dispose() {
    // Dispose controllers and remove listeners
    _firstNameController.dispose();
    _surnameController.dispose();
    // _countryController.dispose();
    _stateController.dispose();
    _phoneNumberPrefixController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel to react to state changes (busy, error, idle, image updates)
    final viewModel = ref.watch(profileSettingViewModelProvider);
    final profile = ref.watch(marketProfileProvider);
    // Moving market mid-form is rare but real: the location screen can be
    // reached from anywhere, and the dial code has to follow it.
    ref.listen<MarketProfile>(
      marketProfileProvider,
      (_, next) => _adoptMarket(next, viewModel),
    );

    return Scaffold(
      appBar: const EmptyAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.h1(
                        'Complete Profile',
                      ), // Updated title as per image
                      Gap.h6,
                      // Subtitle from image is missing, keeping original subtitle for now
                      AppText.body('Complete details to complete profile'),

                      // Center profile image removed as per image
                      // The image shows no profile picture upload area.
                      // If you need it, you can re-add it here with GestureDetector and showModalBottomSheet.
                      Gap.h24,
                      AppText.caption('First name'),
                      Gap.h4,
                      AppTextField(
                        controller: _firstNameController,
                        hint: 'Sarah',
                        autofillHints: const [AutofillHints.givenName],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      Gap.h16,
                      AppText.caption('Last Name'),
                      Gap.h4,
                      AppTextField(
                        controller: _surnameController,
                        hint: 'Osato',
                        autofillHints: const [AutofillHints.familyName],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Surname cannot be empty';
                          }
                          return null;
                        },
                      ),
                      Gap.h16,
                      // AppText.caption('Country'),
                      // Gap.h4,
                      // ModalFormField(
                      //   title: viewModel.country.isEmpty
                      //       ? 'Select Country'
                      //       : viewModel.country,
                      //   textColor: viewModel.country.isEmpty
                      //       ? AppColors.darkgrey.withOpacity(0.5)
                      //       : AppColors.black,
                      //   options: _countries, // Get states from ViewModel
                      //   controller: _countryController,
                      //   onOptionSelected: (option) {
                      //     viewModel.setCountry(option);
                      //   }, // Control ModalFormField's text
                      // ),
                      Gap.h16,
                      AppText.caption(profile.regionLabel),
                      Gap.h4,
                      ModalFormField(
                        title: 'Select ${profile.regionLabel}',
                        options: profile.regions,
                        controller: _stateController,
                        enableSearch: true,
                        modalHeightFactor: 0.9,
                        onOptionSelected: (option) {
                          viewModel.setSelectedState(option);
                          setState(() => _stateError = null);
                        },
                      ),
                      if (_stateError != null) ...[
                        Gap.h4,
                        AppText.caption(_stateError!, color: AppColors.red),
                      ],
                      Gap.h16,
                      AppText.caption('Phone number'),
                      Gap.h4,
                      Row(
                        children: [
                          SizedBox(
                            width: 84,
                            // Read-only rather than disabled: a disabled field
                            // falls back to Material's underline and stops
                            // looking like the fields around it.
                            child: AppTextField(
                              controller: _phoneNumberPrefixController,
                              readOnly: true,
                            ),
                          ),
                          Gap.w8,
                          // Main phone number field
                          Expanded(
                            child: AppTextField(
                              formatter: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(
                                  profile.localPhoneDigits,
                                ),
                                NoLeadingZeroFormatter(),
                              ],
                              controller: _phoneNumberController,
                              hint: profile.phoneExample,
                              keyboardType: TextInputType.phone,
                              autofillHints: const [
                                AutofillHints.telephoneNumberLocal,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Phone number cannot be empty';
                                }
                                if (!PhoneNumberUtils.isValidPhoneNumber(
                                  value,
                                  profile.dialCode,
                                  expectedLength: profile.localPhoneDigits,
                                )) {
                                  return 'Enter ${profile.localPhoneDigits} digits';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton.primary(
                          title: 'Submit',
                          loading: viewModel.isBusy,
                          onTap: viewModel.state.maybeWhen(
                            busy: () => null, // Disable button if busy
                            orElse: () => () {
                              final formValid =
                                  _formKey.currentState?.validate() ?? false;
                              final regionChosen =
                                  _stateController.text.trim().isNotEmpty;
                              setState(
                                () => _stateError = regionChosen
                                    ? null
                                    : 'Select your '
                                        '${profile.regionLabel.toLowerCase()}',
                              );
                              if (formValid && regionChosen) {
                                viewModel.submitProfile(context: context);
                              }
                            },
                          ),
                        ),
                      ),
                      Gap.h32,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
