
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  // bool _rememberMeEnabled = true;
  // bool _authenticatedWithGoogle = false; // Simulating Google auth status
  final String _password = '********'; // Placeholder for password

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniAppBar(
        icon: Icons.arrow_back_ios,
        color: AppColors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h1('Security'),
            Gap.h24,
            // _SecurityToggle(
            //   title: 'Remember me',
            //   value: _rememberMeEnabled,
            //   onChanged: (bool newValue) {
            //     setState(() {
            //       _rememberMeEnabled = newValue;
            //     });
            //   },
            // ),
            // _SecurityOption(
            //   title: 'Authenticated with',
            //   trailingWidget: Row(
            //     children: [
            //       if (_authenticatedWithGoogle)
            //         Icon(Icons.check, color: AppColors.primary, size: 20.w),
            //       Gap.w4,
            //       AppText.body('Google',
            //           color: _authenticatedWithGoogle
            //               ? AppColors.black
            //               : Colors.grey),
            //     ],
            //   ),
            //   onTap: () {
            //     // Simulate linking/unlinking Google account
            //     setState(() {
            //       _authenticatedWithGoogle = !_authenticatedWithGoogle;
            //     });
            //     print(
            //         'Toggled Google authentication: $_authenticatedWithGoogle');
            //   },
            // ),
            _SecurityOption(
              title: 'Change Password',
              trailingWidget: AppText.body(_password),
              onTap: () {
                // Navigate to Change Password Screen
                NavigationService.instance
                    .navigateTo(NavigatorRoutes.resetPasswordScreen);
                // NavigationService.instance.navigateTo(NavigatorRoutes.changePasswordScreen);
              },
            ),
            Gap.h36,
          ],
        ),
      ),
    );
  }
}

// class _SecurityToggle extends StatelessWidget {
//   final String title;
//   final bool value;
//   final ValueChanged<bool> onChanged;

//   const _SecurityToggle({
//     required this.title,
//     required this.value,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           AppText.body(title, color: AppColors.black),
//           Transform.scale(
//             scale: 0.8,
//             child: CupertinoSwitch(
//               value: value,
//               onChanged: onChanged,
//               activeTrackColor: AppColors.primary,
//               inactiveTrackColor: Colors.grey.shade300,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _SecurityOption extends StatelessWidget {
  final String title;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  const _SecurityOption({
    required this.title,
    this.trailingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.body(title, color: AppColors.black),
            Row(
              children: [
                if (trailingWidget != null) trailingWidget!,
                Gap.w8,
                Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18.w),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
