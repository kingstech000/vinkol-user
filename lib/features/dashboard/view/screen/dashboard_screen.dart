import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/booking/view/screen/booking_screen.dart';
import 'package:starter_codes/features/delivery/view/screen/delivery_screen.dart';
import 'package:starter_codes/features/profile/view/screen/profile_screen.dart';
import 'package:starter_codes/features/store/view/screen/tags_screen.dart';
import 'package:starter_codes/features/wallet/view/screen/wallet_screen.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_pod.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const List<VinkolPodTab> _tabs = <VinkolPodTab>[
    VinkolPodTab(icon: Icons.home_outlined, label: 'Home'),
    VinkolPodTab(icon: Icons.storefront_outlined, label: 'Shop'),
    VinkolPodTab(icon: Icons.inventory_2_outlined, label: 'Records'),
    VinkolPodTab(icon: Icons.account_balance_wallet_outlined, label: 'Wallet'),
    VinkolPodTab(icon: Icons.person_outline, label: 'Profile'),
  ];

  static const Set<int> _authRequired = <int>{2, 3};
  final Set<int> _built = <int>{};

  Widget _screenAt(int index) {
    switch (index) {
      case 0:
        return const BookingsScreen();
      case 1:
        return const TagsScreen();
      case 2:
        return const DeliveryScreen();
      case 3:
        return const WalletHistoryScreen();
      default:
        return const ProfileScreen();
    }
  }

  void _select(int index) {
    if (_authRequired.contains(index)) {
      final allowed = index == 2
          ? GuestModeUtils.requireAuthForDelivery(context)
          : GuestModeUtils.requireAuthForWallet(context);
      if (!allowed) return;
    }
    ref.read(navigationIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(navigationIndexProvider);
    _built.add(index);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.vinkol.canvas,
        // The body runs behind the pod; the pod is a floating object in the stack.
        body: Stack(
          children: <Widget>[
            IndexedStack(
              index: index,
              children: <Widget>[
                for (var i = 0; i < _tabs.length; i++)
                  _built.contains(i) ? _screenAt(i) : const SizedBox.shrink(),
              ],
            ),
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              child: VinkolPod(
                tabs: _tabs,
                currentIndex: index,
                onSelected: _select,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
