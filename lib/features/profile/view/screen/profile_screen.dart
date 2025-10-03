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
    // Watch the userProvider to get the current user state
    final User? user = ref.watch(userProvider);

    // Determine the profile image based on the user data
    ImageProvider<Object>? profileImageProvider;

    if (user?.avatar?.imageUrl != null && user!.avatar!.imageUrl.isNotEmpty) {
      // Use NetworkImage if avatar URL is available
      profileImageProvider = NetworkImage(user.avatar!.imageUrl);
    } else {
      // No image available
      profileImageProvider = null;
    }

    // Determine user name and role
    final String displayUserName = user != null
        ? '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim().isNotEmpty
            ? '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim()
            : user.email ?? '' // Fallback to email if first/last name are empty
        : 'Guest User'; // Default if no user is logged in

    final String displayUserRole = user != null
        ? '${user.state ?? ''} | ${user.role ?? ''}' // Handle null values
        : 'Not Logged In'; // Default if no user is logged in

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const EmptyAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile Header Section
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Centered Avatar with Border
                    Center(
                      child: Container(
                        width: 100.r,
                        height: 100.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 4.r,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: profileImageProvider != null
                            ? ClipOval(
                                child: Image(
                                  image: profileImageProvider!,
                                  width: 100.r,
                                  height: 100.r,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 50.w,
                                      color: AppColors.primary,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Icon(
                                      Icons.person,
                                      size: 50.w,
                                      color: AppColors.primary,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 50.w,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                    Gap.h20,
                    // Centered User Info
                    Center(
                      child: Column(
                        children: [
                          AppText.h3(
                            displayUserName,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                            color: Colors.white,
                          ),
                          Gap.h8,
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.r, vertical: 8.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: AppText.body(
                              displayUserRole,
                              color: Colors.white,
                              fontSize: 14.sp,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap.h32,
              // Profile Options Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ProfileOption(
                      icon: Icons.person_outline,
                      title: 'Personal Info',
                      subtitle: 'Manage your personal information',
                      onTap: () {
                        NavigationService.instance
                            .navigateTo(NavigatorRoutes.personalInfoScreen);
                      },
                    ),
                    _ProfileOption(
                      icon: Icons.security,
                      title: 'Security',
                      subtitle: 'Password and security settings',
                      onTap: () {
                        NavigationService.instance
                            .navigateTo(NavigatorRoutes.securityScreen);
                      },
                    ),
                    _ProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'App preferences and configuration',
                      onTap: () {
                        NavigationService.instance
                            .navigateTo(NavigatorRoutes.settingsScreen);
                      },
                    ),
                    _ProfileOption(
                      icon: Icons.help_outline,
                      title: 'Support & Help',
                      subtitle: 'Get help and contact support',
                      onTap: () {
                        NavigationService.instance
                            .navigateTo(NavigatorRoutes.supportAndHelpScreen);
                      },
                    ),
                    _ProfileOption(
                      icon: Icons.logout,
                      title: 'Log Out',
                      subtitle: 'Sign out of your account',
                      onTap: () {
                        showLogoutModal(context);
                      },
                      isDestructive: true,
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
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon,
                  color: isDestructive ? Colors.red : AppColors.primary,
                  size: 24.w),
            ),
            Gap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(
                    title,
                    color: isDestructive ? Colors.red : AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  if (subtitle != null) ...[
                    Gap.h4,
                    AppText.caption(
                      subtitle!,
                      color: Colors.grey.shade600,
                      fontSize: 12.sp,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: isDestructive
                    ? Colors.red.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.6),
                size: 18.w),
          ],
        ),
      ),
    );
  }
}
