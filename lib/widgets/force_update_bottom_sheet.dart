import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/core/utils/launch_link.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

class ForceUpdateBottomSheet extends StatelessWidget {
  const ForceUpdateBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ForceUpdateBottomSheet(),
    );
  }

  String _getStoreUrl() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=app.vinkol.user';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/ng/app/vinkol/id6751447117';
    }
    return '';
  }

  Future<void> _openStore(BuildContext context) async {
    try {
      final url = _getStoreUrl();
      if (url.isNotEmpty) {
        await LaunchLink.launchURL(url);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open app store. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap.h16,
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Gap.h24,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.system_update,
                      size: 64.w,
                      color: AppColors.primary,
                    ),
                    Gap.h24,
                    AppText.h1(
                      'Update Required',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    Gap.h12,
                    AppText.body(
                      'A new version of Vinkol is available. Please update to the latest version to continue using the app.',
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                      textAlign: TextAlign.center,
                    ),
                    Gap.h32,
                    AppButton.primary(
                      title: 'Update Now',
                      onTap: () => _openStore(context),
                    ),
                    Gap.h24,
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

