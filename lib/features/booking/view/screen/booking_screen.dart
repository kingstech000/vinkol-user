import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/booking/view/widget/maps_display.dart';
import 'package:starter_codes/features/booking/view/widget/promotion_banner.dart';
import 'package:starter_codes/features/booking/view/widget/reward_widgets.dart';
import 'package:starter_codes/features/booking/view/widget/delivery_service_card.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/nav_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_pod.dart';

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
        padding: EdgeInsets.only(bottom: VinkolPod.bodyInsetOf(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MapDisplay(),
            Gap.h10,
            const DeliveryServiceCard(),
            Gap.h16,
            if (user != null)
              PromotionBanner(progress: RewardProgress.of(user)),
          ],
        ),
      ),
    );
  }
}
