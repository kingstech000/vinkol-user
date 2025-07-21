// lib/features/profile/view/screens/settings_screen.dart
// For CupertinoSwitch
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/constants/link_routes.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final bool _darkModeEnabled = false; // Initial state for Dark Mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniAppBar(
        title: "Setting",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h1(
                'Notification'), // Title as per image, even though it's "Settings"
            Gap.h24,
            _SettingsRow(
              title: 'Language',
              trailingWidget: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: AppText.caption('EN',
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                print('Change Language');
              },
            ),
            // _SettingsRow(
            //   title: 'Dark Mode',
            //   trailingWidget: Transform.scale(
            //     scale: 0.8,
            //     child: CupertinoSwitch(
            //       value: _darkModeEnabled,
            //       onChanged: (bool newValue) {
            //         setState(() {
            //           _darkModeEnabled = newValue;
            //         });
            //         print('Dark Mode: $_darkModeEnabled');
            //         // Implement theme change logic here
            //       },
            //       activeColor: AppColors.primary,
            //       trackColor: Colors.grey.shade300,
            //     ),
            //   ),
            //   onTap: () {
            //     // Tapping the row should also toggle the switch
            //     setState(() {
            //       _darkModeEnabled = !_darkModeEnabled;
            //     });
            //     print('Dark Mode row tapped! $_darkModeEnabled');
            //   },
            // ),
            Gap.h16,
            // _SettingsLink(
            //   title: 'Term & Condition',
            //   onTap: () {
            //     print('Navigate to Terms & Conditions');
            //     // NavigationService.instance.navigateTo(NavigatorRoutes.termsAndConditionsScreen);
            //   },
            // ),
            // _SettingsLink(
            //   title: 'Privacy & Policy',
            //   onTap: () {
            //     print('Navigate to Privacy & Policy');
            //     // NavigationService.instance.navigateTo(NavigatorRoutes.privacyPolicyScreen);
            //   },
            // ),
            _SettingsLink(
              title: 'Delete Account',
              onTap: () {
               launchUrlString(LinkRoutes.contactUrl);
                // NavigationService.instance
                //     .navigateTo(NavigatorRoutes.deleteAccountScreen);
              },
              color: Colors.red, // Make delete account text red
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final Widget trailingWidget;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.title,
    required this.trailingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.body(title, color: AppColors.black),
            trailingWidget,
          ],
        ),
      ),
    );
  }
}

class _SettingsLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _SettingsLink({
    required this.title,
    required this.onTap,
    this.color = AppColors.black, // Default color for links
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.body(title, color: color),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18.w),
          ],
        ),
      ),
    );
  }
}
