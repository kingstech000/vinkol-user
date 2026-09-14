import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/auth/data/auth_service.dart';
import 'package:starter_codes/features/booking/view/widget/maps_display.dart';
import 'package:starter_codes/features/booking/view/widget/promotion_banner.dart';
import 'package:starter_codes/features/booking/view/widget/quick_actions.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/nav_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  /// The least map worth showing; the address card alone needs most of it.
  static const double _mapMinHeight = 160;

  @override
  void initState() {
    super.initState();
    // The dashboard rebuilds this tab on every visit, so this keeps the
    // promotion banner in step with the backend after a booking.
    Future.microtask(() {
      if (!mounted || ref.read(userProvider) == null) return;
      ref.read(authServiceProvider).getUserProfile().then<void>(
            (_) {},
            onError: (Object e) =>
                debugPrint('[BookingsScreen] Profile refresh failed: $e'),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: const NavAppBar(userRole: 'What would you like to do today?'),
      // The map takes whatever height the quick actions and the promotion
      // banner leave, so the whole screen fits without scrolling. The scroll
      // view only engages when a large text scale makes the fixed content
      // taller than the viewport; the map then holds its minimum height.
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap.h10,
                  const Expanded(
                    child: SizedBox(
                      height: _mapMinHeight,
                      child: MapDisplay(),
                    ),
                  ),
                  Gap.h16,
                  const QuickActions(),
                  Gap.h12,
                  if (user != null)
                    user.hasCoupon
                        ? PromotionBanner(
                            hasPromotion: true,
                            discountPercentage: 20,
                            onTap: () {
                              NavigationService.instance.navigateTo(
                                  NavigatorRoutes.deliveryTypeScreen);
                            },
                          )
                        : PromotionBanner(
                            hasPromotion: false,
                            completedBookings: user.ordersSincePromo.isEmpty
                                ? 0
                                : int.parse(user.ordersSincePromo),
                            requiredBookings: 3,
                            discountPercentage: 20,
                            onTap: () {
                              NavigationService.instance.navigateTo(
                                  NavigatorRoutes.deliveryTypeScreen);
                            },
                          ),
                  Gap.h16,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
