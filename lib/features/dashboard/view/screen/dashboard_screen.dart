import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/features/booking/view/screen/booking_screen.dart';
import 'package:starter_codes/features/delivery/view/screen/delivery_screen.dart';
import 'package:starter_codes/features/profile/view/screen/profile_screen.dart';
import 'package:starter_codes/features/store/view/screen/tags_screen.dart';
import 'package:starter_codes/features/wallet/view/screen/wallet_screen.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  /// The bar, for one market.
  ///
  /// Only Nigeria has a customer wallet: elsewhere top-ups are refused,
  /// withdrawals do not apply and every order is paid by card, so the tab has
  /// nothing behind it and is not shown. The market layer owns that fact —
  /// this reads it rather than naming countries.
  List<NavItem> _tabsFor(Country market) {
    return [
      const NavItem(
        label: 'Home',
        icon: PhosphorIconsRegular.house,
        screen: BookingsScreen(),
      ),
      const NavItem(
        label: 'Shop',
        icon: PhosphorIconsRegular.storefront,
        screen: TagsScreen(),
      ),
      const NavItem(
        label: 'Delivery',
        icon: PhosphorIconsRegular.truck,
        screen: DeliveryScreen(),
        guestGuard: GuestModeUtils.requireAuthForDelivery,
      ),
      if (market.hasCustomerWallet)
        const NavItem(
          label: 'Wallet',
          icon: PhosphorIconsRegular.wallet,
          screen: WalletHistoryScreen(),
          guestGuard: GuestModeUtils.requireAuthForWallet,
        ),
      const NavItem(
        label: 'Profile',
        icon: PhosphorIconsRegular.user,
        screen: ProfileScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = _tabsFor(ref.watch(marketProvider));
    // Clamped, not trusted: the index is a plain int that a push notification
    // sets from its payload, and a market without a wallet has one tab fewer
    // than the number that payload was written against.
    final navigationIndex =
        ref.watch(navigationIndexProvider).clamp(0, tabs.length - 1);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: tabs[navigationIndex].screen,
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          height: 120.h,
          padding: EdgeInsets.all(20.r),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                tabs.length,
                (index) => _buildNavItem(
                  context,
                  ref,
                  tabs[index],
                  index,
                  navigationIndex,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, NavItem tab,
      int index, int currentIndex) {
    final double iconSize = 24.w;
    final double labelFontSize = 10.sp;

    return Expanded(
      child: InkWell(
        onTap: () {
          // The guard travels with the tab. Keyed to the position it silently
          // moved to whichever tab happened to be third once one was hidden.
          final guard = tab.guestGuard;
          if (guard != null && !guard(context)) return;
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        borderRadius: BorderRadius.circular(30.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tab.icon,
                color: currentIndex == index ? AppColors.primary : Colors.white,
                size: iconSize,
              ),
              Gap.h4,
              Text(
                tab.label,
                style: TextStyle(
                  color:
                      currentIndex == index ? AppColors.primary : Colors.white,
                  fontSize: labelFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final String label;
  final IconData icon;
  final Widget screen;

  /// Whether a guest may open this tab, or a prompt to sign in instead. Hangs
  /// off the tab rather than off its index so that hiding a tab cannot move
  /// the guard onto its neighbour.
  final bool Function(BuildContext context)? guestGuard;

  const NavItem({
    required this.label,
    required this.icon,
    required this.screen,
    this.guestGuard,
  });
}
