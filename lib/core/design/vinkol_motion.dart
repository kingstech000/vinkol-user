import 'package:flutter/material.dart';

/// Vinkol motion. Source of truth: `.claude/design/04-tokens.md` §6.
///
/// Motion exists to explain a change, never to decorate one. No bounce, no elastic, no
/// overshoot, and nothing longer than [deliberate].
abstract final class VinkolMotion {
  static const instant = Duration(milliseconds: 80); // press feedback
  static const fast = Duration(milliseconds: 140); // toggles, chips, checkboxes
  static const base = Duration(milliseconds: 200); // page and sheet transitions
  static const slow = Duration(milliseconds: 320); // map camera, live status changes
  static const deliberate = Duration(milliseconds: 480); // the ceiling

  static const standard = Curves.easeOutCubic;
  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const emphasized = Cubic(0.2, 0, 0, 1);

  static const skeletonPeriod = Duration(milliseconds: 1200);

  /// Whether this context has asked for reduced motion.
  ///
  /// Reduced motion means cross-fade or no transition — never a shortened bounce. Check this
  /// before every non-trivial animation.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// A duration that collapses to zero when the user has asked for reduced motion.
  static Duration respecting(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
