/// The reward mechanic, drawn as a route.
///
/// Three bookings unlock a discount on the next one. The old banner drew that as a
/// percentage bar; this draws it as **the Line** (design signature #1) turned horizontal —
/// each booking is a stop, and the reward is the destination rendered as the same diamond
/// terminus the rail uses everywhere else. Discrete stops beat a bar because the goal is a
/// *count*: three deliveries a user can see themselves completing, not a bar sitting at 66%.
library;

import 'dart:math' show cos, pi, sin;
import 'dart:ui' show FontFeature, PathMetric;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/auth/model/user_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

part 'reward_widgets/reward_route_nodes.dart';
part 'reward_widgets/reward_cards.dart';
part 'reward_widgets/reward_meter_card.dart';

/// The mechanic's two numbers, in one place.
///
/// Both are product constants rather than API fields — the backend exposes only
/// `hasCoupon` and `ordersSincePromo` (`.claude/design/08-backend-gaps.md`), so nothing here
/// may claim a reward history, an expiry date or a lifetime saving.
abstract final class RewardTerms {
  static const int bookings = 3;
  static const int percentOff = 20;
}

/// How far along the route the user is.
@immutable
class RewardProgress {
  const RewardProgress({
    required this.completed,
    required this.earned,
    this.target = RewardTerms.bookings,
    this.percentOff = RewardTerms.percentOff,
  });

  /// Built from the only two fields that exist.
  factory RewardProgress.of(User user) => RewardProgress(
        // `ordersSincePromo` arrives as a string and has been seen empty. `tryParse`, not
        // `parse`: a malformed count is a card that reads zero, never a crash on the home
        // screen.
        completed: int.tryParse(user.ordersSincePromo.trim()) ?? 0,
        earned: user.hasCoupon,
      );

  /// Bookings counted since the last reward. Store orders count toward it.
  final int completed;

  /// The discount is unlocked and waiting to be spent.
  final bool earned;

  final int target;
  final int percentOff;

  /// Stops filled in on the route, clamped — the server keeps counting past the target.
  int get done => earned ? target : completed.clamp(0, target);

  int get remaining => (target - done).clamp(0, target);
}

/// Where the meter's waterline sits, as a fraction of the gift artwork's frame.
///
/// The artwork is a 500px canvas whose box only occupies y 114..430 — 23% down from the top,
/// 14% up from the bottom. The meter fills *that* band and not the canvas: clipping to the
/// canvas would leave an untouched reward showing a third of the box already coloured.
double rewardMeterFillTop(RewardProgress p) {
  const double top = 0.23;
  const double bottom = 0.14;
  if (p.earned) return top;
  final double done = p.target == 0 ? 1 : p.done / p.target;
  return top + (1 - done) * (1 - top - bottom);
}

/// The reward route — the Line laid flat, with every stop named.
///
/// Four places in a row: one per booking, then the destination. Each carries a label under
/// it, so the mechanic reads without the copy — you can see that two stops are behind you,
/// which one you are standing on, and that the thing at the end is a prize rather than a
/// fourth delivery. The destination is the rail's diamond terminus, dashed while it is still
/// locked and filled once it is yours.
///
/// Set [onSaturatedGround] when it sits on the brand-filled card, where the only ink
/// available is the white the card already carries.
class RewardRoute extends StatelessWidget {
  const RewardRoute({
    super.key,
    required this.progress,
    this.onSaturatedGround = false,
  });

  final RewardProgress progress;
  final bool onSaturatedGround;

  /// The band the nodes live in. Tall enough to hold the current stop's halo, so the row
  /// does not grow by 8pt the moment a stop becomes live.
  static const double _band = 32;

  /// The disc a booking stop is drawn as, and the box its diamond destination fills.
  static const double _node = 22;
  static const double _goal = 26;

  /// A label is allowed to be wider than its node but not wide enough to starve the
  /// connectors. Past this it ellipsises and the node shape carries the meaning alone.
  static const double _labelMax = 68;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final _RouteInk ink = _RouteInk.of(v, onSaturatedGround);

    final int target = progress.target;
    final int done = progress.done;
    final bool earned = progress.earned;

    final List<Widget> row = <Widget>[];
    for (int i = 0; i <= target; i++) {
      if (i > 0) {
        // The leg into a stop you have reached is solid; everything past it is dashed,
        // because a solid line to a place you have not been claims a delivery you have not
        // made.
        row.add(
          Expanded(
            child: SizedBox(
              height: _band,
              child: Center(
                child: _RouteLeg(reached: i <= done, ink: ink),
              ),
            ),
          ),
        );
      }

      final bool isGoal = i == target;
      final bool isDone = earned || i < done;
      final bool isNow = !earned && !isGoal && i == done;

      row.add(
        _RouteStop(
          band: _band,
          size: isGoal ? _goal : _node,
          labelMax: _labelMax,
          ink: ink,
          state: isGoal
              ? (earned ? _StopState.won : _StopState.goal)
              : isDone
                  ? _StopState.done
                  : (isNow ? _StopState.now : _StopState.ahead),
          // A stop still ahead of you carries its number, so the count is legible even
          // before the route fills. The goal carries a star, never a number.
          number: isGoal ? null : '${i + 1}',
          label: switch ((isGoal, isDone, isNow)) {
            (true, _, _) => earned ? l10n.rewardStopYours : l10n.rewardStopGoal,
            (_, true, _) => l10n.rewardStopDone,
            (_, _, true) => l10n.rewardStopNext,
            // Deliveries beyond the one you are on need no word: the number is the label.
            _ => '',
          },
        ),
      );
    }

    return Semantics(
      label: earned
          ? l10n.rewardEarnedSemantics
          : l10n.rewardProgressSemantics(done, target),
      excludeSemantics: true,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: row),
    );
  }
}

/// The route's palette, resolved once per build.
///
/// Two grounds, one geometry. On the saturated card the only ink available is the white it
/// already carries, so its steps are alpha rather than ramp steps.
@immutable
class _RouteInk {
  const _RouteInk({
    required this.line,
    required this.lineOn,
    required this.nodeGround,
    required this.nodeEdge,
    required this.nodeText,
    required this.liveGround,
    required this.liveEdge,
    required this.liveText,
    required this.halo,
    required this.fill,
    required this.onFill,
    required this.label,
    required this.labelOn,
  });

  factory _RouteInk.of(VinkolColors v, bool saturated) {
    if (!saturated) {
      return _RouteInk(
        line: v.borderStrong,
        lineOn: v.brand,
        nodeGround: v.surfaceAlt,
        nodeEdge: v.borderStrong,
        nodeText: v.textTertiary,
        liveGround: v.surface,
        liveEdge: v.brand,
        liveText: v.textBrand,
        halo: v.brandHalo,
        fill: v.brand,
        onFill: v.onBrand,
        label: v.textTertiary,
        labelOn: v.textBrand,
      );
    }
    final Color ink = v.onBrand;
    return _RouteInk(
      line: ink.withValues(alpha: 0.40),
      lineOn: ink.withValues(alpha: 0.75),
      nodeGround: ink.withValues(alpha: 0.22),
      nodeEdge: ink.withValues(alpha: 0.50),
      nodeText: ink,
      liveGround: ink.withValues(alpha: 0.22),
      liveEdge: ink,
      liveText: ink,
      halo: ink.withValues(alpha: 0.18),
      fill: ink,
      onFill: v.brandDeep,
      label: ink.withValues(alpha: 0.80),
      labelOn: ink,
    );
  }

  final Color line;
  final Color lineOn;
  final Color nodeGround;
  final Color nodeEdge;
  final Color nodeText;
  final Color liveGround;
  final Color liveEdge;
  final Color liveText;
  final Color halo;
  final Color fill;
  final Color onFill;
  final Color label;
  final Color labelOn;
}

/// What a stop on the route is.
enum _StopState {
  /// A booking you have made.
  done,

  /// The booking you are on.
  now,

  /// A booking still to come.
  ahead,

  /// The prize, still locked.
  goal,

  /// The prize, unlocked.
  won,
}
