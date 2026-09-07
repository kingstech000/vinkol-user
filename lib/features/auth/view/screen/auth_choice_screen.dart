import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;

    return Scaffold(
      // White, not the canvas grey: the artwork is drawn on white and any tint behind it
      // shows as a rectangle around the illustration.
      backgroundColor: v.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // The artwork owns the upper field and is the first thing that shrinks when the
            // user's text size grows.
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: VinkolSpace.pageMargin,
                    ),
                    child: SvgPicture.asset(
                      ImageAsset.onboarding,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: VinkolSpace.pageMargin,
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    l10n.authChoiceTitle,
                    style: VinkolType.displayL
                        .copyWith(color: v.textPrimary, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: VinkolSpace.lg),
                  Text(
                    l10n.authChoiceBody,
                    style: VinkolType.bodyL
                        .copyWith(color: v.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: VinkolSpace.sectionGapHero),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                VinkolSpace.pageMargin,
                VinkolSpace.none,
                VinkolSpace.pageMargin,
                VinkolSpace.bottomActionGap,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _GetStartedButton(
                    label: l10n.onboardingGetStarted,
                    onPressed: () => NavigationService.instance
                        .navigateTo(NavigatorRoutes.signupScreen),
                  ),
                  const SizedBox(height: VinkolSpace.sm),
                  VinkolPrimaryButton(
                    label: l10n.authContinueAsGuest,
                    tone: VinkolButtonTone.plain,
                    onPressed: () async {
                      await locator<LocalCache>().setGuestMode(true);
                      NavigationService.instance.navigateToReplaceAll(
                        NavigatorRoutes.dashboardScreen,
                      );
                    },
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

/// The primary action: a full-bleed brand pill with the label set flush to the start and a
/// white chip carrying the forward chevrons at the end.
///
/// It is not a [VinkolPrimaryButton] because that centres a single label; this one is the
/// hero variant of the same pill — same `full` radius, same brand fill, same pressed step to
/// `brandDeep` — with an inset affordance the ordinary dock button does not have.
class _GetStartedButton extends StatefulWidget {
  const _GetStartedButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsetsDirectional.fromSTEB(
            VinkolSpace.xxl,
            VinkolSpace.sm,
            VinkolSpace.sm,
            VinkolSpace.sm,
          ),
          decoration: BoxDecoration(
            color: _pressed ? v.brandDeep : v.brand,
            borderRadius: VinkolRadius.brFull,
          ),
          // Centred, not stretched: the pill's height is a minimum, not a fixed value, so a
          // stretched cross-axis would resolve to an unbounded height. The chip carries its
          // own height instead.
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.label,
                  style: VinkolType.h2.copyWith(color: v.onBrand, fontSize: 16),
                  // French runs ~40% longer than English; the label wraps, never clips.
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: VinkolSpace.md),
              const _ChevronChip(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The white chip inside the pill, with the chevrons running forward through it.
///
/// The chase is a 1200ms linear loop — the same [VinkolMotion.skeletonPeriod] the skeleton
/// shimmer uses, and the only other animation in the system allowed to run indefinitely. Each
/// chevron is phase-shifted by a fifth of the cycle so the brightness travels toward the end
/// of the pill: the direction the tap takes you. No bounce, no overshoot, and a 2pt slide
/// rather than anything that reads as a jump.
///
/// Under reduced motion it does not run at all; the chevrons sit at full strength, which is
/// the part that carries the meaning.
///
/// The chip's ground is fixed white in both themes because it sits on the brand fill, so its
/// chevrons take literal steps of the brand ramp rather than the theme-resolved accent — a
/// theme-resolved blue would be the dark-mode accent on a white ground and lose its contrast.
class _ChevronChip extends StatefulWidget {
  const _ChevronChip();

  @override
  State<_ChevronChip> createState() => _ChevronChipState();
}

class _ChevronChipState extends State<_ChevronChip>
    with SingleTickerProviderStateMixin {
  static const _chevrons = <(double, Color)>[
    (16, VinkolPalette.brand200),
    (19, VinkolPalette.brand300),
    (23, VinkolPalette.brand500),
  ];

  /// How far apart in the cycle two neighbouring chevrons sit.
  static const _stagger = 0.2;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: VinkolMotion.skeletonPeriod,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (VinkolMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A 0 -> 1 -> 0 triangle over one cycle, eased so the peak is not a corner.
  double _pulse(double phase) {
    final t = phase % 1.0;
    return VinkolMotion.standard.transform(t < 0.5 ? t * 2 : (1 - t) * 2);
  }

  /// One chevron at its point in the chase. [i] is both its ramp step and its phase offset,
  /// so the last chevron — the darkest — is the one the wave arrives at.
  Widget _chevron(int i, bool reduced) {
    final (double size, Color color) = _chevrons[i];
    final double p = reduced ? 1 : _pulse(_controller.value - i * _stagger);
    return Transform.translate(
      offset: Offset(2 * p, 0),
      child: Opacity(
        opacity: 0.3 + 0.7 * p,
        child: Icon(Icons.chevron_right_rounded, size: size, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final reduced = VinkolMotion.reduced(context);

    return Container(
      width: 76,
      // 68pt pill less its 8pt inset on each side.
      height: 52,
      decoration: BoxDecoration(
        color: v.onBrand,
        borderRadius: VinkolRadius.brFull,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < _chevrons.length; i++) _chevron(i, reduced),
          ],
        ),
      ),
    );
  }
}
