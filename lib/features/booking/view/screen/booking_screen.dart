import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/booking/view/widget/maps_display.dart';
import 'package:starter_codes/features/booking/view/widget/promotion_banner.dart';
import 'package:starter_codes/features/booking/view/widget/ride_detail_input_field.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/nav_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: const NavAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Padding(
            //   padding:
            //       EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            //   child: LocationTags(),
            // ),
            Gap.h16,
            const MapDisplay(),
            Gap.h16,
            const RideDetailsInput(),
            Gap.h16,
            if (user != null)
              user.hasCoupon
                  ? PromotionBanner(
                      hasPromotion: true,
                      discountPercentage: 20,
                      onTap: () {},
                    )
                  : PromotionBanner(
                      hasPromotion: false,
                      completedBookings: user.ordersSincePromo.isEmpty
                          ? 0
                          : int.parse(user.ordersSincePromo),
                      requiredBookings: 3,
                      discountPercentage: 20,
                      onTap: () {},
                    ),
          ],
        ),
      ),
    );
  }
}
