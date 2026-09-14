import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_motion.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/gap.dart';

/// A block of the layout that has not arrived yet. Pulses between two neutral
/// steps; holds still when the OS asks for reduced motion.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = VinkolRadius.brSm,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
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
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(
          VinkolPalette.neutral100,
          VinkolPalette.neutral200,
          Curves.easeInOut.transform(_controller.value),
        );
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// Empty and error states share one shape: a glyph, a sentence that says what
/// happened, one that says what to do, and the action to do it. Errors carry
/// a reason and a retry; empties carry a way out.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VinkolSpace.xxxl,
          vertical: VinkolSpace.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color:
                  isError ? VinkolPalette.dangerText : VinkolPalette.neutral400,
            ),
            Gap.h16,
            AppText.h3(
              title,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: VinkolPalette.neutral900,
              centered: true,
            ),
            Gap.h6,
            AppText.body(
              message,
              fontSize: 14,
              color: VinkolPalette.neutral500,
              centered: true,
              lineHeight: 1.45,
            ),
            if (actionLabel != null && onAction != null) ...[
              Gap.h20,
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: VinkolPalette.brand600,
                  side: const BorderSide(color: VinkolPalette.neutral200),
                  shape: const RoundedRectangleBorder(
                    borderRadius: VinkolRadius.brSm,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: VinkolSpace.xl,
                    vertical: VinkolSpace.md,
                  ),
                ),
                child: AppText.button(
                  actionLabel!,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.brand600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lets a state view live inside a pull-to-refresh, which needs a scrollable.
class RefreshableFill extends StatelessWidget {
  const RefreshableFill({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: VinkolPalette.brand500,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}
