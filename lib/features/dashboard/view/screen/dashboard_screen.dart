import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/features/booking/view/screen/booking_screen.dart';
import 'package:starter_codes/features/delivery/view/screen/delivery_screen.dart';
import 'package:starter_codes/features/profile/view/screen/profile_screen.dart';
import 'package:starter_codes/features/store/view/screen/store_screen.dart';
import 'package:starter_codes/features/store/view/screen/tags_screen.dart';
import 'package:starter_codes/features/wallet/view/screen/wallet_screen.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  final List<NavItem> _navItems = const [
    NavItem(
      label: 'Home',
      icon: Icons.home,
    ),
    NavItem(
      label: 'Shop',
      icon: Icons.store,
    ),
    NavItem(
      label: 'Delivery',
      icon: Icons.fire_truck,
    ),
    NavItem(
      label: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
    ),
    NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
    ),
  ];

  final List<Widget> _screens = const [
    BookingsScreen(),
    TagsScreen(),
    DeliveryScreen(),
    WalletHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationIndex = ref.watch(navigationIndexProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: _screens[navigationIndex],
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
                _navItems.length,
                (index) => _buildNavItem(
                  context,
                  ref,
                  _navItems[index].icon,
                  index,
                  _navItems[index].label,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, IconData icon,
      int index, String label) {
    final double iconSize = 24.w;
    final double labelFontSize = 10.sp;

    final currentIndex =
        ref.watch(navigationIndexProvider);

    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 2 && !GuestModeUtils.requireAuthForDelivery(context)) {
            return;
          }
          if (index == 3 && !GuestModeUtils.requireAuthForWallet(context)) {
            return;
          }
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        borderRadius: BorderRadius.circular(30.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: currentIndex == index ? AppColors.primary : Colors.white,
                size: iconSize,
              ),
              Gap.h4,
              Text(
                label,
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

  const NavItem({
    required this.label,
    required this.icon,
  });
}
