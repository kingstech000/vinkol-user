// lib/features/profile/view/screens/delete_account_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart'; // Assuming AppTextField is defined
import 'package:starter_codes/widgets/gap.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _termsAccepted = false; // State variable for the checkbox

  @override
  void dispose() {
    _reasonController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h1('Delete Account'),
            Gap.h24,
            AppText.caption(
                'Describe reason why you want to delete your account'),
            Gap.h4,
            AppTextField(
              controller: _reasonController,
              hint: '', // No specific hint text in the image for reason
              maxLines: 5, // Allow multiple lines for reason
              keyboardType: TextInputType.multiline,
            ),
            Gap.h24,
            AppText.caption('Password'),
            Gap.h4,
            AppTextField(
              controller: _passwordController,
              hint: '**********',
              isPassword: true, // Assuming this property handles obscureText
              suffixIcon: IconButton(
                icon: const Icon(Icons
                    .visibility_off), // Example icon for password visibility
                onPressed: () {
                  // Toggle password visibility - you might need to add a state variable
                  // for visibility in AppTextField if it doesn't have it.
                },
              ),
            ),
            Gap.h8,
            Row(
              children: [
                SizedBox(
                  width: 24.w, // Standard checkbox size
                  height: 24.h, // Standard checkbox size
                  child: Checkbox(
                    value: _termsAccepted,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _termsAccepted = newValue ?? false;
                      });
                    },
                    activeColor: AppColors.primary, // Color when checked
                    checkColor: Colors.white, // Color of the checkmark
                  ),
                ),
                Gap.w8, // Gap between checkbox and text
                Expanded(
                  // Use Expanded to ensure text wraps if long
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12.sp),
                      children: [
                        const TextSpan(text: 'I accept the '),
                        TextSpan(
                          text: 'terms and conditions',
                          style: const TextStyle(
                            color: AppColors
                                .primary, // Your primary color for links
                            decoration:
                                TextDecoration.underline, // Underline the link
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              print('Terms and Conditions tapped!');
                              // Navigate to terms and conditions screen
                              // NavigationService.instance.navigateTo(NavigatorRoutes.termsAndConditionsScreen);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Gap.h36, // More vertical space before buttons
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Expanded(
              child: AppButton.outline(
                // Example secondary button style
                title: 'Contact Us',
                onTap: () {
                  print('Contact Us button tapped from Delete Account');
                  NavigationService.instance.navigateTo(
                      NavigatorRoutes.supportAndHelpScreen); // Example
                },
              ),
            ),
            Gap.w16,
            Expanded(
              child: AppButton(
                color: Colors.red,
                title: 'Delete',
                onTap: _termsAccepted
                    ? () {
                        print(
                            'Deleting account with reason: ${_reasonController.text} and password: ${_passwordController.text}');
                        // Show confirmation, then proceed with deletion
                      }
                    : null, // Set onTap to null to disable the button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
