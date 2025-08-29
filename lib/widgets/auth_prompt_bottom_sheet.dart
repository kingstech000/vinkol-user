import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

class AuthPromptBottomSheet extends ConsumerWidget {
  final String title;
  final String message;
  final String? actionText;

  const AuthPromptBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthPromptBottomSheet(
        title: title,
        message: message,
        actionText: actionText,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.lightgrey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Gap.h24,

            // Icon
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 30.sp,
                color: AppColors.primary,
              ),
            ),
            Gap.h16,

            // Title
            AppText.h2(
              title,
              color: AppColors.black,
              textAlign: TextAlign.center,
            ),
            Gap.h8,

            // Message
            AppText.body(
              message,
              color: AppColors.darkgrey,
              textAlign: TextAlign.center,
            ),
            Gap.h32,

            // Login Button
            AppButton.primary(
              title: 'Login',
              onTap: () {
                Navigator.pop(context);
                NavigationService.instance
                    .navigateTo(NavigatorRoutes.loginScreen);
              },
            ),
            Gap.h12,

            // Sign Up Button
            AppButton.outline(
              title: 'Create Account',
              onTap: () {
                Navigator.pop(context);
                NavigationService.instance
                    .navigateTo(NavigatorRoutes.signupScreen);
              },
            ),
            Gap.h16,

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: AppText.body(
                'Cancel',
                color: AppColors.darkgrey,
              ),
            ),
            Gap.h16,
          ],
        ),
      ),
    );
  }
}
