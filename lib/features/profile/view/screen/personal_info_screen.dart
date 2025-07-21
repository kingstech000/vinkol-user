// lib/features/profile/view/screens/personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/data_utils.dart'; // For nigerianStates
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/provider/user_provider.dart'; // To get initial user data
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';

import 'package:starter_codes/features/profile/view_model/personal_info_view_model.dart';
import 'package:starter_codes/widgets/modal_form_field.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current state from the view model
    final initialPersonalInfo = ref.read(personalInfoViewModelProvider);
    _firstNameController = TextEditingController(text: initialPersonalInfo.firstname);
    _lastNameController = TextEditingController(text: initialPersonalInfo.lastname);
    _emailController = TextEditingController(text: initialPersonalInfo.email);
    _phoneController = TextEditingController(text: initialPersonalInfo.phoneNumber);
    _addressController = TextEditingController(text: initialPersonalInfo.address);

    // Add listeners to update the view model state as text changes
    _firstNameController.addListener(() {
      ref.read(personalInfoViewModelProvider.notifier).updateFirstName(_firstNameController.text);
    });
    _lastNameController.addListener(() {
      ref.read(personalInfoViewModelProvider.notifier).updateLastName(_lastNameController.text);
    });
    _emailController.addListener(() {
      ref.read(personalInfoViewModelProvider.notifier).updateEmail(_emailController.text);
    });
    _phoneController.addListener(() {
      ref.read(personalInfoViewModelProvider.notifier).updatePhoneNumber(_phoneController.text);
    });
    _addressController.addListener(() {
      ref.read(personalInfoViewModelProvider.notifier).updateAddress(_addressController.text);
    });
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers to prevent memory leaks
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,backgroundColor: AppColors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  ref.read(personalInfoViewModelProvider.notifier).pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: AppText.body('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  ref.read(personalInfoViewModelProvider.notifier).pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onAddressSelected(String selectedState) {
    _addressController.text = selectedState; // Update the TextEditingController
    ref.read(personalInfoViewModelProvider.notifier).updateAddress(selectedState); // Update the view model
  }

  @override
  Widget build(BuildContext context) {
    // Watch the personalInfoViewModelProvider for state changes.
    final personalInfoState = ref.watch(personalInfoViewModelProvider);
    // Watch the userProvider to get the current user's general info (e.g., existing avatar URL)
    final currentUser = ref.watch(userProvider);

    ImageProvider<Object>? displayImageProvider;
    Widget? avatarPlaceholder;

    // Logic to determine which image to display for the avatar
    if (personalInfoState.profileImage != null) {
      displayImageProvider = FileImage(personalInfoState.profileImage!);
    } else if (currentUser?.avatar?.imageUrl != null && currentUser!.avatar!.imageUrl.isNotEmpty) {
      displayImageProvider = NetworkImage(currentUser.avatar!.imageUrl);
    } else {
      displayImageProvider = const NetworkImage('https://via.placeholder.com/150/0000FF/808080?Text=User');
      avatarPlaceholder = Icon(Icons.person, size: 40.w, color: Colors.white);
    }

    // Use ref.listen to react to one-off state changes like success/error messages.
    ref.listen<PersonalInfoState>(personalInfoViewModelProvider, (previous, next) {
      // Show SnackBar for success message
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
      }
      // Show error SnackBar if errorMessage is set
      else if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar:  MiniAppBar(
        title: 'Personal Info',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap.h24,
            Center(
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 40.r,
                  backgroundImage: displayImageProvider,
                  child: avatarPlaceholder,
                ),
              ),
            ),
            Gap.h24,
            AppText.caption('First name'),
            Gap.h4,
            AppTextField(
              controller: _firstNameController,
              hint: 'First name',
            ),
            Gap.h16,
            AppText.caption('Last name'),
            Gap.h4,
            AppTextField(
              controller: _lastNameController,
              hint: 'Last name',
            ),
            Gap.h16,
            AppText.caption('Email'),
            Gap.h4,
            AppTextField(
              controller: _emailController,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              enabled: false, // Email is typically not editable
            ),
            Gap.h16,
            AppText.caption('Phone Number'),
            Gap.h4,
            AppTextField(
              controller: _phoneController,
              hint: 'Phone Number',
              enabled: false, // Phone number is typically not editable
              keyboardType: TextInputType.phone,
            ),
            Gap.h16,
            AppText.caption('State '),
            Gap.h4,
            ModalFormField(
              controller: _addressController,
              title: 'Select State',
              options: nigerianStates,
              modalHeightFactor: 0.9,
              onOptionSelected: _onAddressSelected,
              enableSearch: true,
            ),
            Gap.h36,
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                title: 'Update',
                loading: personalInfoState.isLoading,
                onTap: personalInfoState.isLoading
                    ? null // Disable button when loading
                    : () async {
                        FocusScope.of(context).unfocus(); // Dismiss keyboard
                        // Trigger the updateProfile method and await its completion.
                        final success = await ref.read(personalInfoViewModelProvider.notifier).updateProfile();

                        // Only navigate back if the update was successful AND
                        // the widget is still mounted (i.e., screen hasn't been popped already).
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText.button('Updated Successfully',color: AppColors.white,),backgroundColor: AppColors.green,));
                          NavigationService.instance.goBack();
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}