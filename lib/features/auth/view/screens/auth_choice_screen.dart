import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';

class AuthChoiceScreen extends ConsumerStatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  ConsumerState<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends ConsumerState<AuthChoiceScreen> {
  final localCache = locator<LocalCache>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // Logo and welcome section
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 120.h,
                      width: 120.w,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ImageAsset.splash),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Gap.h24,
                    AppText.h1(
                      'Welcome to Vinkol',
                      color: AppColors.black,
                      textAlign: TextAlign.center,
                    ),
                    Gap.h8,
                    AppText.body(
                      'Choose how you\'d like to get started',
                      color: AppColors.darkgrey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Auth options
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Guest Mode Button
                    AppButton.primary(
                      title: 'Continue as Guest',
                      onTap: () async {
                        await localCache.setGuestMode(true);
                        NavigationService.instance.navigateToReplaceAll(
                            NavigatorRoutes.dashboardScreen);
                      },
                    ),
                    Gap.h16,

                    // Divider with "or" text
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.lightgrey,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: AppText.caption(
                            'or',
                            color: AppColors.darkgrey,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.lightgrey,
                          ),
                        ),
                      ],
                    ),
                    Gap.h16,

                    // Login Button
                    AppButton.outline(
                      title: 'Login',
                      onTap: () {
                        NavigationService.instance
                            .navigateTo(NavigatorRoutes.loginScreen);
                      },
                    ),
                    Gap.h12,

                    // Sign Up Button
                    AppButton.outline(
                      title: 'Create Account',
                      onTap: () {
                        NavigationService.instance
                            .navigateTo(NavigatorRoutes.signupScreen);
                      },
                    ),
                  ],
                ),
              ),

              // Footer text
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppText.caption(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      color: AppColors.darkgrey,
                      textAlign: TextAlign.center,
                      fontSize: 12.sp,
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
