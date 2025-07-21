
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/gap.dart'; // Assuming this provider exists and provides a User model

class NavAppBar extends ConsumerWidget implements PreferredSizeWidget {
  // Changed to ConsumerWidget
  const NavAppBar({
    super.key,
    this.userRole = 'Where would you like to deliver to?', // Default user role
    this.showNotificationBadge = true, // Whether to show the red dot
    this.onNotificationTap, // Callback for notification bell tap
  });

  // Removed userName as it will be fetched from userProvider
  final String userRole;
  final bool showNotificationBadge;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref
    // Watch the userProvider to get the user data
    final user = ref.watch(userProvider);

    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Padding(
        padding: EdgeInsets.only(left: 10.w, top: 5.h, bottom: 5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText.h1(
              // Use user.firstName from the provider
              'Hi ${user!.firstname}',
              color: AppColors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            Gap.h4,
            AppText.body(
              userRole,
              color: AppColors.darkgrey,
              fontSize: 14.sp,
            ),
          ],
        ),
      ),
      centerTitle: false,
      // actions: [
      //   GestureDetector(
      //     onTap: onNotificationTap,
      //     child: Padding(
      //       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      //       child: Stack(
      //         children: [
      //           Icon(
      //             CupertinoIcons.bell,
      //             color: AppColors.black,
      //             size: 28.w,
      //           ),
      //           if (showNotificationBadge)
      //             Positioned(
      //               right: 0,
      //               top: 0,
      //               child: Container(
      //                 padding: EdgeInsets.all(2.w),
      //                 decoration: BoxDecoration(
      //                   color: Colors.red,
      //                   borderRadius: BorderRadius.circular(6.r),
      //                 ),
      //                 constraints: BoxConstraints(
      //                   minWidth: 10.w,
      //                   minHeight: 10.h,
      //                 ),
      //               ),
      //             ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(55.h); // Adjust height as needed
}
