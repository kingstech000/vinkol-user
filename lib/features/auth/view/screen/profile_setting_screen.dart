import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/data_utils.dart';
import 'package:starter_codes/core/utils/text.dart';
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
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _phoneNumberPrefixController =
      TextEditingController(); // For +234

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _states = nigerianStates; // Example states, expanded

  final List<String> _countries = [
    'Nigeria',
    // 'Ghana',
    // 'Kenya',
    // 'South Africa'
  ]; // Example countries

  @override
  void initState() {
    super.initState();
    // Initialize controllers with values from the ViewModel
    final viewModel = ref.read(profileSettingViewModelProvider);
    _firstNameController.text = viewModel.firstName;
    _surnameController.text = viewModel.surname;
    _countryController.text = viewModel.country;
    _stateController.text = viewModel.selectedState;
    _phoneNumberPrefixController.text = viewModel.phoneNumberPrefix;
    _phoneNumberController.text = viewModel.phoneNumber;

    // Add listeners to update ViewModel on text field changes
    _firstNameController
        .addListener(() => viewModel.setFirstName(_firstNameController.text));
    _surnameController
        .addListener(() => viewModel.setSurname(_surnameController.text));
    _countryController
        .addListener(() => viewModel.setCountry(_countryController.text));
    _stateController
        .addListener(() => viewModel.setSelectedState(_stateController.text));
    _phoneNumberPrefixController.addListener(() =>
        viewModel.setPhoneNumberPrefix(_phoneNumberPrefixController.text));
    _phoneNumberController.addListener(
        () => viewModel.setPhoneNumber(_phoneNumberController.text));
  }

  @override
  void dispose() {
    // Dispose controllers and remove listeners
    _firstNameController.dispose();
    _surnameController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _phoneNumberPrefixController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel to react to state changes (busy, error, idle, image updates)
    final viewModel = ref.watch(profileSettingViewModelProvider);

    return Scaffold(
      appBar: const EmptyAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h1(
                        'Complete Profile'), // Updated title as per image
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Surname cannot be empty';
                        }
                        return null;
                      },
                    ),
                    Gap.h16,
                    AppText.caption('Country'),
                    Gap.h4,
                    ModalFormField(
                      title: viewModel.country.isEmpty
                          ? 'Select Country'
                          : viewModel.country,
                      textColor: viewModel.country.isEmpty
                          ? AppColors.darkgrey.withOpacity(0.5)
                          : AppColors.black,
                      options: _countries, // Get states from ViewModel
                      controller: _countryController,
                      onOptionSelected: (option) {
                        viewModel.setCountry(option);
                      }, // Control ModalFormField's text
                    ),
                    Gap.h16,
                    AppText.caption('State'),
                    Gap.h4,
                    ModalFormField(
                      title: viewModel.selectedState.isEmpty
                          ? 'Select State'
                          : viewModel.selectedState,
                      textColor: viewModel.selectedState.isEmpty
                          ? AppColors.darkgrey.withOpacity(0.5)
                          : AppColors.black,
                      options: _states, // Get states from ViewModel
                      controller: _stateController,
                      enableSearch: true,
                      modalHeightFactor: 0.9,
                      onOptionSelected: (option) {
                        viewModel.setSelectedState(option);
                      }, // Control ModalFormField's text
                    ),
                    Gap.h16,
                    AppText.caption('Phone number'),
                    Gap.h4,
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: AppTextField(
                            controller: _phoneNumberPrefixController,
                            hint: '+234',
                            enabled: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                        Gap.w8,
                        // Main phone number field
                        Expanded(
                          child: AppTextField(
                            controller: _phoneNumberController,
                            hint: '901 234 5678',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number cannot be empty';
                              }
                              // Basic phone number validation
                              if (value.length < 7 || value.length > 15) {
                                return 'Invalid phone number length';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Gap.h36,
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        title: 'Submit',
                        loading: viewModel.isBusy,
                        onTap: viewModel.state.maybeWhen(
                          busy: () => null, // Disable button if busy
                          orElse: () => () {
                            if (_formKey.currentState?.validate() ?? false) {
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
        ],
      ),
    );
  }
}
