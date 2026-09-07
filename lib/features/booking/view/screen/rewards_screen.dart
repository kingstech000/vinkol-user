import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/booking/view/widget/reward_widgets.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The rewards screen.
///
/// Two states, because the API has two: earning, and earned. There is no history and no
/// lifetime-savings figure — `hasCoupon` and `ordersSincePromo` are the only fields that
/// exist (`.claude/design/08-backend-gaps.md`), and inventing a ledger here would be
/// inventing data.
///
/// The earned reward takes the saturated treatment on this screen and nowhere else: here it
/// *is* the subject. On home it stays a bordered card, because home's one saturated object
/// belongs to the open order (D-07).
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: MiniAppBar(title: l10n.rewardTitle),
      body: user == null
          ? const _SignedOut(percentOff: RewardTerms.percentOff)
          : _Rewards(progress: RewardProgress.of(user)),
    );
  }
}

class _Rewards extends StatelessWidget {
  const _Rewards({required this.progress});

  final RewardProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        VinkolSpace.pageMargin,
        VinkolSpace.lg,
        VinkolSpace.pageMargin,
        VinkolSpace.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (progress.earned) ...<Widget>[
            RewardEarnedCard(progress: progress),
            const SizedBox(height: VinkolSpace.md),
            VinkolPrimaryButton(
              label: l10n.rewardUseOnBooking,
              // The reward is spent by booking, and booking is home. Popping rather than
              // pushing keeps the back stack honest: there is no third screen here.
              onPressed: () => NavigationService.instance.goBack(),
            ),
          ] else ...<Widget>[
            VinkolSectionHeader(
              label: l10n.rewardYourProgress,
              meta: l10n.rewardCountOfTarget(progress.done, progress.target),
            ),
            RewardCard(progress: progress),
          ],
          VinkolSectionHeader(label: l10n.rewardHowItWorks),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.local_shipping_outlined,
                title: l10n.rewardHowDeliveriesTitle(progress.target),
                meta: l10n.rewardHowDeliveriesBody,
                metaMaxLines: 2,
              ),
              VinkolRow(
                icon: Icons.star_outline,
                title: l10n.rewardHowUnlockTitle(progress.percentOff),
                meta: l10n.rewardHowUnlockBody,
                metaMaxLines: 2,
              ),
              VinkolRow(
                icon: Icons.autorenew_outlined,
                title: l10n.rewardHowAgainTitle,
                meta: l10n.rewardHowAgainBody,
                metaMaxLines: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A guest has no reward to show — the count is per account.
class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.percentOff});

  final int percentOff;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VinkolStateView.empty(
      icon: Icons.star_outline,
      title: l10n.rewardSignedOutTitle,
      message: l10n.rewardSignedOutBody(percentOff),
      action: VinkolStateAction(
        label: l10n.authLoginAction,
        onPressed: () => GuestModeUtils.requireAuthForAction(
          context,
          title: l10n.rewardSignedOutTitle,
          message: l10n.rewardSignedOutBody(percentOff),
        ),
      ),
    );
  }
}
