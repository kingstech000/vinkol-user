import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The three things the app does, as shortcuts on the home screen. Sending a
/// package is the reason the app exists, so it is the one saturated object on
/// the screen (decision D-07); the other two are quiet hairline tiles.
class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  /// Tab positions in `dashboard_screen.dart`. Home, Shop and Delivery sit
  /// before the market-dependent Wallet tab, so these hold in every market.
  static const _shopTab = 1;
  static const _deliveryTab = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void switchTab(int index) =>
        ref.read(navigationIndexProvider.notifier).state = index;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PrimaryAction(
            onTap: () => NavigationService.instance
                .navigateTo(NavigatorRoutes.deliveryTypeScreen),
          ),
          Gap.h12,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SecondaryAction(
                    icon: PhosphorIconsRegular.storefront,
                    title: 'Shop on Vinkol',
                    subtitle: 'Order from stores near you',
                    onTap: () => switchTab(_shopTab),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: _SecondaryAction(
                    icon: PhosphorIconsRegular.truck,
                    title: 'Track your order',
                    subtitle: 'See where your deliveries are',
                    onTap: () {
                      // The same guard the Delivery tab carries.
                      if (!GuestModeUtils.requireAuthForDelivery(context)) {
                        return;
                      }
                      switchTab(_deliveryTab);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Send a package. Book a delivery today.',
      child: Material(
        color: VinkolPalette.brand500,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIconsRegular.package,
                        size: 28.w,
                        color: VinkolPalette.white,
                      ),
                      Gap.h16,
                      AppText.h2(
                        'Send a package',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: VinkolPalette.white,
                        letterSpacing: -0.3,
                        maxLines: 1,
                      ),
                      Gap.h2,
                      AppText.body(
                        'Book a delivery today.',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: VinkolPalette.white,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Gap.w12,
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: VinkolPalette.white,
                  ),
                  child: Icon(
                    PhosphorIconsBold.arrowRight,
                    size: 20.w,
                    color: VinkolPalette.brand600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle.',
      child: Material(
        color: VinkolPalette.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 24.w, color: VinkolPalette.brand600),
                Gap.h12,
                AppText.body(
                  title,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.neutral900,
                  maxLines: 1,
                ),
                Gap.h2,
                AppText.caption(
                  subtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: VinkolPalette.neutral500,
                  maxLines: 2,
                  lineHeight: 1.3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
