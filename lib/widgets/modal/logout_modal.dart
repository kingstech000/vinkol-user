// lib/widgets/modals/logout_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/router/routing_constants.dart'; // Assuming you have routing constants for Support
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

class LogoutModal extends ConsumerWidget {
  const LogoutModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use watch to react to user authentication state changes
    final user = ref.watch(userProvider);
    final localCache = locator<LocalCache>();
    return Container(
      // The Container is now the direct child of the ModalBottomSheet
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          // Only top corners are rounded for a bottom sheet
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          // No bottomLeft or bottomRight for a standard bottom sheet
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Make the column take minimum space
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.primary
                .withOpacity(0.3), // A light blue background for the icon
            child: Icon(
              Icons.cancel_outlined, // A clear "cancel" or "stop" icon
              color: AppColors
                  .primary, // Primary color for the icon, or a distinct blue/red
              size: 40.w,
            ),
          ),
          Gap.h24,
          AppText.h2(
            'Log Out',
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          Gap.h8,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppText.body(
              'Really want to log out of the app?\nIf it is due to issue please contact us',
              textAlign: TextAlign.center,
              color: Colors.grey.shade600,
              fontSize: 14.sp,
            ),
          ),
          Gap.h32,
          Row(
            children: [
              Expanded(
                child: AppButton.outline(
                  // Assuming you have an outline button style
                  title: 'Contact Us',
                  onTap: () {
                    NavigationService.instance.goBack(); // Close the modal
                    NavigationService.instance.navigateTo(NavigatorRoutes
                        .supportAndHelpScreen); // Navigate to Support screen
                  },
                ),
              ),
              Gap.w16,
              Expanded(
                child: AppButton(
                  color: AppColors.red,
                  textColor: AppColors.white,
                  title: 'Log Out',
                  onTap: () async {
                    // Clear guest mode and token
                    await GuestModeUtils.clearGuestMode();
                    await localCache.saveToken('');
                    ref.watch(navigationIndexProvider.notifier).state = 0;
                    NavigationService.instance.navigateToReplaceAll(
                        NavigatorRoutes
                            .authChoiceScreen); // Navigate to auth choice
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Function to show the Logout Modal as a Bottom Sheet
void showLogoutModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled:
        true, // Allows the modal to be full height if needed (though not for this one)
    backgroundColor: Colors
        .transparent, // Important for showing the Container's rounded corners
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const LogoutModal(), // Your modal content
      );
    },
  );
}
