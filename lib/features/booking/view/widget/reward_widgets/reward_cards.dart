// The reward summary card and the card shown once a reward is earned.
part of '../reward_widgets.dart';

/// The reward card.
///
/// One card, read top to bottom: what this is and what it is worth, the route you are on,
/// then the sentence that says what happens next. The route carries the work — four named
/// stops show how far you have come, which booking you are standing on and that the thing at
/// the end is a prize, without the copy having to say any of it.
///
/// Everything on it is one of the two fields the API actually exposes — there is no expiry
/// date and no reward history to draw (D-10).
///
/// It is tinted rather than saturated. Home's one saturated object is the primary action,
/// and a reward competing with it for the eye would be the wrong screen (D-07); a hairline
/// card with a brand-tinted corner puts it in the family without claiming that rank.
class RewardCard extends StatefulWidget {
  const RewardCard({super.key, required this.progress, this.onTap});

  final RewardProgress progress;
  final VoidCallback? onTap;

  @override
  State<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<RewardCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final RewardProgress p = widget.progress;

    final Widget card = VinkolSurface(
      radius: VinkolRadius.brLg,
      color: v.surface,
      border: v.borderSubtle,
      shadows: VinkolElevation.e1(v),
      clipChild: true,
      child: Stack(
        children: <Widget>[
          // The one piece of decoration: a soft brand disc bleeding off the top end corner,
          // the same object the saturated card carries, so the two read as one family.
          _CornerDisc(color: v.brandSubtle),
          Padding(
            padding: const EdgeInsets.all(VinkolSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CardTop(
                  eyebrow: p.earned
                      ? l10n.rewardEarnedEyebrow
                      : l10n.rewardNextReward,
                  eyebrowInk: v.textTertiary,
                  // The prize sits in the chip while it is still being earned, so the card
                  // answers "what do I get" before the route answers "how far am I".
                  chip: p.earned
                      ? l10n.rewardReady
                      : l10n.rewardPercentOffShort(p.percentOff),
                  chipInk: v.textBrand,
                  chipGround: v.brandSubtle,
                ),
                const SizedBox(height: VinkolSpace.xl),
                RewardRoute(progress: p),
                const SizedBox(height: VinkolSpace.xl),
                Text(
                  p.earned
                      ? l10n.rewardReadyHeadline(p.percentOff)
                      : l10n.rewardRemaining(p.remaining),
                  style: VinkolType.h4.copyWith(color: v.textPrimary),
                ),
                const SizedBox(height: VinkolSpace.xs),
                Text(
                  p.earned
                      ? l10n.rewardAppliedAutomatically
                      : l10n.rewardStoreOrdersCount,
                  style: VinkolType.bodyS.copyWith(color: v.textSecondary),
                ),
                if (widget.onTap != null) ...<Widget>[
                  const SizedBox(height: VinkolSpace.md),
                  _DetailsAction(label: l10n.rewardDetails),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.onTap == null) return card;

    return Semantics(
      button: true,
      label: l10n.rewardDetails,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        // Scale is the press feedback rather than a second ground: the card already sits on
        // `surface`, and there is no step below it that does not read as disabled.
        child: AnimatedScale(
          scale: _pressed ? 0.99 : 1,
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          child: card,
        ),
      ),
    );
  }
}

/// The forward affordance: a word and an arrow, in brand ink.
///
/// The whole card is the tap target — this is the label that says so, and it replaces the
/// disc that used to hang off the card's edge. A 56pt button on a card that is itself
/// tappable was two controls for one action.
class _DetailsAction extends StatelessWidget {
  const _DetailsAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            style: VinkolType.label.copyWith(
              color: v.textBrand,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: VinkolSpace.xs),
        Icon(PhosphorIconsBold.arrowRight, size: 15, color: v.textBrand),
      ],
    );
  }
}

/// The earned reward, saturated.
///
/// This treatment is reserved for the rewards screen, where the reward *is* the subject. The
/// gradient and the corner disc are the hero's, so the two read as one object family.
class RewardEarnedCard extends StatelessWidget {
  const RewardEarnedCard({super.key, required this.progress});

  final RewardProgress progress;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final Color ink = v.onBrand;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: VinkolRadius.brLg,
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[v.brand, v.brandDeep],
        ),
      ),
      child: ClipRRect(
        borderRadius: VinkolRadius.brLg,
        child: Stack(
          children: <Widget>[
            _CornerDisc(color: ink.withValues(alpha: 0.08)),
            Padding(
              padding: const EdgeInsets.all(VinkolSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _CardTop(
                    eyebrow: l10n.rewardEarnedEyebrow,
                    eyebrowInk: ink.withValues(alpha: 0.8),
                    chip: l10n.rewardReady,
                    chipInk: ink,
                    chipGround: ink.withValues(alpha: 0.18),
                  ),
                  const SizedBox(height: VinkolSpace.xl),
                  RewardRoute(progress: progress, onSaturatedGround: true),
                  const SizedBox(height: VinkolSpace.xl),
                  // Flush numerics: the figure is the hero and the unit sits on its
                  // baseline at reduced weight.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          l10n.rewardPercentNumber(progress.percentOff),
                          style: VinkolType.numXl.copyWith(color: ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.rewardOff,
                          style: VinkolType.h3
                              .copyWith(color: ink.withValues(alpha: 0.9)),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VinkolSpace.xs),
                  Text(
                    l10n.rewardAppliedAutomatically,
                    style: VinkolType.bodyS
                        .copyWith(color: ink.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Eyebrow on the start edge, the prize as a pill on the end.
class _CardTop extends StatelessWidget {
  const _CardTop({
    required this.eyebrow,
    required this.eyebrowInk,
    required this.chip,
    required this.chipInk,
    required this.chipGround,
  });

  final String eyebrow;
  final Color eyebrowInk;
  final String chip;
  final Color chipInk;
  final Color chipGround;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            eyebrow.toUpperCase(),
            style: VinkolType.labelS
                .copyWith(color: eyebrowInk, letterSpacing: 0.6),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: VinkolSpace.sm),
        Flexible(
          child: Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: VinkolSpace.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: chipGround,
              borderRadius: VinkolRadius.brFull,
            ),
            child: Text(
              chip,
              style: VinkolType.labelS
                  .copyWith(color: chipInk, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

/// The soft disc bleeding off the end corner — the one piece of decoration both reward cards
/// carry, so they read as the same object in two registers.
class _CornerDisc extends StatelessWidget {
  const _CornerDisc({required this.color});

  final Color color;

  static const double size = 170;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      end: -70,
      top: -70,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
