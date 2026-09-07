import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// Every Vinkol surface, cut from the superellipse contour.
///
/// Use this anywhere a `Container` with a `BoxDecoration` would otherwise go: cards, rows,
/// artwork plates, chips, pills. It paints elevation, fill and hairline through
/// [VinkolSurfacePainter], so a surface's edge is continuous where a `BorderRadius` would
/// break curvature — see `vinkol_shape.dart` for why that is visible at Midnight's radii.
///
/// [duration] cross-fades the fill when it changes, which is what a selectable row needs and
/// what an [AnimatedContainer] would otherwise have provided.
class VinkolSurface extends StatelessWidget {
  const VinkolSurface({
    super.key,
    required this.radius,
    required this.color,
    this.border,
    this.shadows = const <BoxShadow>[],
    this.padding,
    this.width,
    this.height,
    this.clipChild = false,
    this.duration,
    this.child,
  });

  final BorderRadiusGeometry radius;
  final Color color;

  /// The hairline. Null draws no edge — correct on a filled surface, where the fill is the
  /// edge.
  final Color? border;

  /// From [VinkolElevation]. Empty is e0, the default across the app.
  final List<BoxShadow> shadows;

  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  /// Clips [child] to the contour. Needed for artwork and maps, skipped otherwise: a clip
  /// costs a saveLayer that a text row has no use for.
  final bool clipChild;

  /// Honours reduced motion through [VinkolMotion.respecting].
  final Duration? duration;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radii = radius.resolve(Directionality.maybeOf(context));

    Widget? content = child;
    if (content != null && padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (content != null && clipChild) {
      content = ClipPath(
        clipper: VinkolSurfaceClipper(radii),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    Widget paint(Color fill) => CustomPaint(
          painter: VinkolSurfacePainter(
            radii: radii,
            color: fill,
            border: border,
            shadows: shadows,
          ),
          // CustomPaint only consults `size` when it has no child; with one it takes the
          // child's size, which is what every caller here wants.
          size: content == null ? Size(width ?? 0, height ?? 0) : Size.zero,
          child: content,
        );

    final Duration? d = duration;
    final Widget painted = d == null
        ? paint(color)
        : TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: color),
            duration: VinkolMotion.respecting(context, d),
            curve: VinkolMotion.standard,
            builder: (BuildContext context, Color? value, Widget? _) =>
                paint(value ?? color),
          );

    if (width == null && height == null) return painted;
    return SizedBox(width: width, height: height, child: painted);
  }
}
