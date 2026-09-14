import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/booking/view/screen/booking_screen.dart';
import 'package:starter_codes/features/delivery/view/screen/delivery_screen.dart';
import 'package:starter_codes/features/profile/view/screen/profile_screen.dart';
import 'package:starter_codes/features/store/view/screen/tags_screen.dart';
import 'package:starter_codes/features/wallet/view/screen/wallet_screen.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  List<NavItem> _tabsFor(Country market) {
    return [
      const NavItem(
        label: 'Home',
        icon: PhosphorIconsRegular.house,
        activeIcon: PhosphorIconsFill.house,
        screen: BookingsScreen(),
      ),
      const NavItem(
        label: 'Shop',
        icon: PhosphorIconsRegular.storefront,
        activeIcon: PhosphorIconsFill.storefront,
        screen: TagsScreen(),
      ),
      const NavItem(
        label: 'Delivery',
        icon: PhosphorIconsRegular.truck,
        activeIcon: PhosphorIconsFill.truck,
        screen: DeliveryScreen(),
        guestGuard: GuestModeUtils.requireAuthForDelivery,
      ),
      if (market.hasCustomerWallet)
        const NavItem(
          label: 'Wallet',
          icon: PhosphorIconsRegular.wallet,
          activeIcon: PhosphorIconsFill.wallet,
          screen: WalletHistoryScreen(),
          guestGuard: GuestModeUtils.requireAuthForWallet,
        ),
      const NavItem(
        label: 'Profile',
        icon: PhosphorIconsRegular.user,
        activeIcon: PhosphorIconsFill.user,
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
        bottomNavigationBar: _Pod(
          tabs: tabs,
          currentIndex: navigationIndex,
          onSelect: (index) {
            // The guard travels with the tab. Keyed to the position it silently
            // moved to whichever tab happened to be third once one was hidden.
            final guard = tabs[index].guestGuard;
            if (guard != null && !guard(context)) return;
            ref.read(navigationIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }
}

/// The pod (D-08), docked: a white bar flush to the bottom edge in which the
/// active tab expands into a brand-blue pill and reveals its label, so the
/// selected state is carried by shape and text, not colour alone. Flush to the
/// edge, so it takes no radius and no margin; a hairline on top separates it
/// from the canvas (e0), and the safe area is inside it.
class _Pod extends StatelessWidget {
  const _Pod({
    required this.tabs,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<NavItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const Border(
        top: BorderSide(color: AppColors.lightgrey),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < tabs.length; i++)
                if (i == currentIndex)
                  // Loose-fit: the pill takes its own width and gives the
                  // label back to an ellipsis before the row can overflow at
                  // large text sizes.
                  Flexible(
                    child: _PodItem(
                      tab: tabs[i],
                      selected: true,
                      onTap: () => onSelect(i),
                    ),
                  )
                else
                  _PodItem(
                    tab: tabs[i],
                    selected: false,
                    onTap: () => onSelect(i),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodItem extends StatelessWidget {
  const _PodItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final NavItem tab;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : _duration;
    final foreground = selected ? AppColors.white : AppColors.darkgrey;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        animationDuration: duration,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            // 44pt minimum target; the pill is the same height selected or
            // not, so the row does not jump when the selection moves.
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected ? tab.activeIcon : tab.icon,
                    color: foreground,
                    size: 22,
                  ),
                  AnimatedSize(
                    duration: duration,
                    curve: _curve,
                    alignment: AlignmentDirectional.centerStart,
                    child: selected
                        ? Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 8),
                            child: Text(
                              tab.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: foreground,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final String label;
  final IconData icon;

  /// The filled counterpart of [icon], drawn inside the active pill.
  final IconData activeIcon;
  final Widget screen;

  /// Whether a guest may open this tab, or a prompt to sign in instead. Hangs
  /// off the tab rather than off its index so that hiding a tab cannot move
  /// the guard onto its neighbour.
  final bool Function(BuildContext context)? guestGuard;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
    this.guestGuard,
  });
}
