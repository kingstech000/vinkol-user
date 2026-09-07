import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/booking/view/widget/reward_widgets.dart';

/// The reward on home: a section heading and one bordered card.
///
/// What it replaces was a gradient block with an emoji, an exclamation mark and a percentage
/// bar, in a green that is not in the Vinkol palette. The mechanic is unchanged — three
/// bookings unlock a discount on the next one — and the drawing is now the Line: each booking
/// is a stop and the reward is the destination.
///
/// It is deliberately *not* saturated. Home's one saturated object is the open order, and a
/// reward competing with a live delivery for the eye would be the wrong screen (D-07). The
/// earned reward gets the saturated treatment on the rewards screen, where it is the subject.
class PromotionBanner extends StatelessWidget {
  const PromotionBanner({super.key, required this.progress});

  final RewardProgress progress;

  @override
  Widget build(BuildContext context) {
    void openRewards() =>
        NavigationService.instance.navigateTo(NavigatorRoutes.rewardsScreen);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
      child: RewardMeterCard(progress: progress, onTap: openRewards),
    );
  }
}
