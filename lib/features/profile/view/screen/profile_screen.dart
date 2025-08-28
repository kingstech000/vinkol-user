// lib/features/profile/view/screens/profile_screen.dart
// Required for FileImage
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/empty_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/logout_modal.dart';
import 'package:starter_codes/features/auth/model/user_model.dart'; // Ensure User model is imported if not already via provider
import 'package:starter_codes/utils/guest_mode_utils.dart';

// Change StatelessWidget to ConsumerStatefulWidget
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  // Change State to ConsumerState
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

// Change State to ConsumerState
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // _profileImage will now be derived from the provider's user avatar
  // Remove the local _profileImage, userName, userRole as they will come from provider

  @override
  Widget build(BuildContext context) {
    // Use watch to react to user authentication state changes
    final User? user = ref.watch(userProvider);
    final bool isGuestMode = GuestModeUtils.isGuestMode();

    // Determine the profile image based on the user data
    ImageProvider<Object>? profileImageProvider;
    Widget? avatarChild;

    if (user?.avatar?.imageUrl != null && user!.avatar!.imageUrl.isNotEmpty) {
      // Use NetworkImage if avatar URL is available
      profileImageProvider = NetworkImage(user.avatar!.imageUrl);
    } else {
      // Use a local asset or default icon instead of network image
      profileImageProvider = null;
      avatarChild = Icon(Icons.person, size: 40.w, color: Colors.white);
    }

    // Determine user name and role
    final String displayUserName = isGuestMode
        ? 'Guest User'
        : (user != null
            ? '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim().isNotEmpty
                ? '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim()
                : user.email // Fallback to email if first/last name are empty
            : 'Guest User'); // Default if no user is logged in

    final String displayUserRole = isGuestMode
        ? 'Continue as guest'
        : (user != null
            ? ' ${user.state}| ${user.role}' // Truncate ID for display
            : 'Not Logged In'); // Default if no user is logged in

    return Scaffold(
      appBar: const EmptyAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 40.r,
                    backgroundImage: profileImageProvider,
                    child: avatarChild, // Shows icon if no image
                  ),
                  Gap.w8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap.h16,
                      AppText.h2(displayUserName, fontWeight: FontWeight.bold),
                      Gap.h4,
                      AppText.body(displayUserRole,
                          color: Colors.grey.shade600, fontSize: 12.sp),
                    ],
                  )
                ],
              ),
              const Gap.h(72),
              Card(
                elevation: 1,
                color: Colors.grey.shade50,
                child: Column(
                  children: [
                    if (!isGuestMode) ...[
                      _ProfileOption(
                        icon: Icons.person_outline,
                        title: 'Personal Info',
                        onTap: () {
                          NavigationService.instance
                              .navigateTo(NavigatorRoutes.personalInfoScreen);
                        },
                      ),
                      _ProfileOption(
                        icon: Icons.security,
                        title: 'Security',
                        onTap: () {
                          NavigationService.instance
                              .navigateTo(NavigatorRoutes.securityScreen);
                        },
                      ),
                      _ProfileOption(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {
                          NavigationService.instance
                              .navigateTo(NavigatorRoutes.settingsScreen);
                        },
                      ),
                    ],
                    _ProfileOption(
                      icon: Icons.help_outline,
                      title: 'Support & Help',
                      onTap: () {
                        NavigationService.instance
                            .navigateTo(NavigatorRoutes.supportAndHelpScreen);
                      },
                    ),
                    _ProfileOption(
                      icon: isGuestMode ? Icons.login : Icons.logout,
                      title: isGuestMode ? 'Sign In / Sign Up' : 'Log Out',
                      onTap: () {
                        if (isGuestMode) {
                          // For guest users, navigate to auth choice screen
                          NavigationService.instance.navigateToReplaceAll(
                              NavigatorRoutes.authChoiceScreen);
                        } else {
                          // For authenticated users, show logout modal
                          showLogoutModal(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, color: AppColors.black, size: 24.w),
            Gap.w16,
            Expanded(
              child: AppText.body(title, color: AppColors.black),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18.w),
          ],
        ),
      ),
    );
  }
}
