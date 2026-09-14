// lib/widgets/modals/logout_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The confirmation for logging out.
///
/// No icon on a tinted disc and no oversized headline: the sheet asks one
/// question, names what is about to happen, and gives the two answers equal
/// room with the destructive one on the end.
class LogoutModal extends ConsumerWidget {
  const LogoutModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localCache = locator<LocalCache>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightgrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Gap.h24,
            AppText.h4('Log out?', color: AppColors.black),
            Gap.h8,
            AppText.body(
              'You will need your email and password to get back in. Nothing '
              'about your orders changes.',
              color: AppColors.darkgrey,
              fontSize: 14,
              lineHeight: 1.45,
            ),
            Gap.h24,
            Row(
              children: [
                Expanded(
                  child: AppButton.outline(
                    title: 'Cancel',
                    onTap: () => NavigationService.instance.goBack(),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: AppButton(
                    color: AppColors.redText,
                    textColor: AppColors.white,
                    outlineColor: AppColors.redText,
                    title: 'Log out',
                    onTap: () async {
                      await GuestModeUtils.clearGuestMode();
                      await localCache.saveToken('');
                      ref.read(navigationIndexProvider.notifier).state = 0;
                      NavigationService.instance.navigateToReplaceAll(
                          NavigatorRoutes.authChoiceScreen);
                    },
                  ),
                ),
              ],
            ),
            Gap.h8,
            Center(
              child: TextButton(
                onPressed: () {
                  NavigationService.instance.goBack();
                  NavigationService.instance
                      .navigateTo(NavigatorRoutes.supportAndHelpScreen);
                },
                child: AppText.body(
                  'Having a problem? Contact us',
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Function to show the Logout Modal as a Bottom Sheet
void showLogoutModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const LogoutModal(),
      );
    },
  );
}
