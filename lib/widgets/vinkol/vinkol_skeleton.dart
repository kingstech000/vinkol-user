import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// A skeleton block.
///
/// **A skeleton beats a spinner wherever the layout is known.** A spinner says "wait"; a
/// skeleton says "wait, and here is the shape of what is coming", which stops the screen
/// jumping when the data lands and makes the wait feel shorter for the same duration.
///
/// The shimmer is a 1200ms linear loop (`04-tokens.md` §6) and is the one animation in the
/// system that runs indefinitely. Under reduced motion it does not run at all — the block
/// still holds the space, which is the part that matters.
class VinkolSkeleton extends StatelessWidget {
  const VinkolSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = VinkolRadius.brSm,
  });

  /// A skeleton line of text, sized as a fraction of the available width so a list of them
  /// reads as ragged prose rather than a set of identical bars.
  const VinkolSkeleton.line({super.key, this.width, this.height = 14})
      : radius = VinkolRadius.brSm;

  /// A circular block — an avatar or an icon well.
  const VinkolSkeleton.circle({super.key, double size = 40})
      : width = size,
        height = size,
        radius = VinkolRadius.brFull;

  final double? width;
  final double height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          // The base tone is a surface step, not an opacity of the text colour — depth in
          // Midnight is surface lightness.
          color: context.vinkol.surfaceAlt,
          borderRadius: radius,
        ),
      ),
    );
  }
}

/// Sweeps a highlight across its child. One controller per skeleton group rather than one
/// per block would be cheaper, but every block here is inside the same subtree and Flutter
/// coalesces the repaints; keeping it local means a skeleton works anywhere with no setup.
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
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
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (VinkolMotion.reduced(context)) return widget.child;

    final v = context.vinkol;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (Rect bounds) {
          // Sweeps from off-start to off-end so the highlight enters and leaves rather than
          // appearing in place.
          final t = _controller.value * 3 - 1;
          return LinearGradient(
            begin: AlignmentDirectional.centerStart.resolve(TextDirection.ltr),
            end: AlignmentDirectional.centerEnd.resolve(TextDirection.ltr),
            colors: <Color>[
              v.surfaceAlt,
              v.surfaceStrong,
              v.surfaceAlt,
            ],
            stops: <double>[
              (t - 0.3).clamp(0.0, 1.0),
              t.clamp(0.0, 1.0),
              (t + 0.3).clamp(0.0, 1.0),
            ],
          ).createShader(bounds);
        },
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// A skeleton shaped like a [VinkolRow] — icon well, two lines of text, a value on the end
/// axis. Use it wherever a `VinkolRowGroup` is about to appear.
class VinkolRowSkeleton extends StatelessWidget {
  const VinkolRowSkeleton(
      {super.key, this.showIcon = true, this.showValue = true});

  final bool showIcon;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: 14,
      ),
      child: Row(
        children: <Widget>[
          if (showIcon) ...<Widget>[
            const VinkolSkeleton(width: 40, height: 40),
            const SizedBox(width: 13),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 0.62,
                  child: VinkolSkeleton.line(height: 15),
                ),
                SizedBox(height: VinkolSpace.sm),
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 0.38,
                  child: VinkolSkeleton.line(height: 12),
                ),
              ],
            ),
          ),
          if (showValue) ...<Widget>[
            const SizedBox(width: VinkolSpace.md),
            const VinkolSkeleton(width: 64, height: 15),
          ],
        ],
      ),
    );
  }
}

/// A skeleton shaped like a [VinkolRecordCard].
class VinkolRecordSkeleton extends StatelessWidget {
  const VinkolRecordSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: 0.22,
                      child: VinkolSkeleton.line(height: 11),
                    ),
                    SizedBox(height: VinkolSpace.xs),
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: 0.52,
                      child: VinkolSkeleton.line(height: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(width: VinkolSpace.md),
              VinkolSkeleton(
                  width: 88, height: 26, radius: VinkolRadius.brFull),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: v.borderSubtle),
          const SizedBox(height: 14),
          const Row(
            children: <Widget>[
              Expanded(child: VinkolSkeleton.line(height: 15)),
              SizedBox(width: VinkolSpace.md),
              Expanded(child: VinkolSkeleton.line(height: 15)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A list of skeletons, for a screen whose row shape is known before its data is.
///
/// [count] defaults to 6 because that is the density target: a logistics list should show
/// 6–8 rows on a standard phone, so a shorter skeleton would understate the page.
class VinkolSkeletonList extends StatelessWidget {
  const VinkolSkeletonList({
    super.key,
    this.count = 6,
    this.shape = VinkolSkeletonShape.row,
    this.padding =
        const EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
  });

  final int count;
  final VinkolSkeletonShape shape;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    // The announcement wraps the exclusion, not the other way round: a screen reader should
    // hear "Loading" once and none of the placeholder rows.
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      container: true,
      child: ExcludeSemantics(
        child: switch (shape) {
          VinkolSkeletonShape.row => Padding(
              padding: padding,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: v.surface,
                  borderRadius: VinkolRadius.brLg,
                  border: VinkolElevation.hairline(v),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (var i = 0; i < count; i++) ...<Widget>[
                      if (i > 0) Container(height: 1, color: v.borderSubtle),
                      const VinkolRowSkeleton(),
                    ],
                  ],
                ),
              ),
            ),
          VinkolSkeletonShape.record => ListView.separated(
              padding: padding,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => const VinkolRecordSkeleton(),
            ),
        },
      ),
    );
  }
}

enum VinkolSkeletonShape { row, record }
