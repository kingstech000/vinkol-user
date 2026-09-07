// The stops and connectors along the reward route.
part of '../reward_widgets.dart';

/// One place on the route: its node, and the word for what it is.
///
/// The node is centred in a fixed band so the row keeps its height whether or not a stop is
/// live, and the label sits under it in the same column — three signals for the same fact
/// (shape, colour, word), which is what keeps the route readable in greyscale and to a
/// colourblind reader (D-05).
class _RouteStop extends StatelessWidget {
  const _RouteStop({
    required this.band,
    required this.size,
    required this.labelMax,
    required this.ink,
    required this.state,
    required this.number,
    required this.label,
  });

  final double band;
  final double size;
  final double labelMax;
  final _RouteInk ink;
  final _StopState state;

  /// The booking's position in the count. Null on the destination, which is a prize and not
  /// a delivery.
  final String? number;

  final String label;

  @override
  Widget build(BuildContext context) {
    final bool live = state == _StopState.now || state == _StopState.won;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: band,
          child: Center(
            child: _RouteNode(
              size: size,
              ink: ink,
              state: state,
              number: number,
            ),
          ),
        ),
        const SizedBox(height: VinkolSpace.sm),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: labelMax),
          child: Text(
            label,
            style: VinkolType.labelS.copyWith(
              color: live ? ink.labelOn : ink.label,
              fontWeight: live ? FontWeight.w700 : FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// The node itself: a disc for a booking, a diamond for the prize.
///
/// The shape change at the end of the route is the point — a fourth disc would read as a
/// fourth delivery, and the thing waiting there is not one.
class _RouteNode extends StatelessWidget {
  const _RouteNode({
    required this.size,
    required this.ink,
    required this.state,
    required this.number,
  });

  final double size;
  final _RouteInk ink;
  final _StopState state;
  final String? number;

  /// The ring of tint the live node stands in. Drawn as a second circle rather than a
  /// shadow, so it stays a token colour at a token size.
  static const double _halo = 5;

  @override
  Widget build(BuildContext context) {
    final bool diamond = state == _StopState.goal || state == _StopState.won;
    final bool filled = state == _StopState.done || state == _StopState.won;
    final bool live = state == _StopState.now || state == _StopState.won;

    final Color ground = switch (state) {
      _StopState.done || _StopState.won => ink.fill,
      _StopState.now => ink.liveGround,
      _StopState.ahead || _StopState.goal => ink.nodeGround,
    };
    final Color edge = switch (state) {
      _StopState.done || _StopState.won => ink.fill,
      _StopState.now => ink.liveEdge,
      _StopState.ahead || _StopState.goal => ink.nodeEdge,
    };
    final Color content = switch (state) {
      _StopState.done || _StopState.won => ink.onFill,
      _StopState.now => ink.liveText,
      _StopState.ahead || _StopState.goal => ink.nodeText,
    };

    // A stop you have made is a tick; the prize is a star; everything else carries its
    // number, tabular so the row does not jitter as the count moves.
    final Widget mark = switch (state) {
      _StopState.done =>
        Icon(PhosphorIconsBold.check, size: 12, color: content),
      _StopState.goal ||
      _StopState.won =>
        Icon(PhosphorIconsFill.star, size: 12, color: content),
      _StopState.now || _StopState.ahead => Text(
          number ?? '',
          // `labelS` is the 11pt step the disc is sized for; the tabular figures come
          // from the numeric family, because a count that shifts as it grows is the one
          // thing a progress route may not do.
          style: VinkolType.labelS.copyWith(
            color: content,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
          maxLines: 1,
        ),
    };

    final Widget node = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RouteNodePainter(
          diamond: diamond,
          ground: ground,
          edge: edge,
          // The locked destination is the one node drawn with a broken edge: it is the only
          // place on the route that is not yet a real place.
          dashed: state == _StopState.goal,
          filled: filled,
        ),
        child: Center(child: mark),
      ),
    );

    if (!live) return node;

    return DecoratedBox(
      decoration: BoxDecoration(color: ink.halo, shape: BoxShape.circle),
      child: Padding(padding: const EdgeInsets.all(_halo), child: node),
    );
  }
}

/// Paints a stop: a circle, or the rail's diamond terminus, with a solid or broken edge.
class _RouteNodePainter extends CustomPainter {
  const _RouteNodePainter({
    required this.diamond,
    required this.ground,
    required this.edge,
    required this.dashed,
    required this.filled,
  });

  final bool diamond;
  final Color ground;
  final Color edge;
  final bool dashed;
  final bool filled;

  /// The node's edge. Two points, so the ring reads at 22pt without becoming a fill.
  static const double _stroke = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    if (rect.isEmpty) return;

    final Path contour = diamond
        ? (Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.center.dy)
          ..lineTo(rect.center.dx, rect.bottom)
          ..lineTo(rect.left, rect.center.dy)
          ..close())
        : (Path()..addOval(rect));

    canvas.drawPath(
      contour,
      Paint()
        ..color = ground
        ..isAntiAlias = true,
    );

    // A filled node is its own edge; stroking it again only darkens the rim.
    if (filled) return;

    final Path inner = diamond
        ? (Path()
          ..moveTo(rect.center.dx, rect.top + _stroke)
          ..lineTo(rect.right - _stroke, rect.center.dy)
          ..lineTo(rect.center.dx, rect.bottom - _stroke)
          ..lineTo(rect.left + _stroke, rect.center.dy)
          ..close())
        : (Path()..addOval(rect.deflate(_stroke / 2)));

    final Paint stroke = Paint()
      ..color = edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..isAntiAlias = true;

    canvas.drawPath(dashed ? _dash(inner) : inner, stroke);
  }

  /// Walks [path] and keeps every other 3pt run — the broken edge of a locked destination.
  static Path _dash(Path path) {
    const double on = 3;
    const double off = 3;
    final Path out = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double start = 0;
      while (start < metric.length) {
        final double end = (start + on).clamp(0, metric.length).toDouble();
        out.addPath(metric.extractPath(start, end), Offset.zero);
        start = end + off;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(_RouteNodePainter old) =>
      old.diamond != diamond ||
      old.ground != ground ||
      old.edge != edge ||
      old.dashed != dashed ||
      old.filled != filled;
}

/// The leg between two stops. Solid behind you, broken ahead of you.
class _RouteLeg extends StatelessWidget {
  const _RouteLeg({required this.reached, required this.ink});

  final bool reached;
  final _RouteInk ink;

  static const double _thickness = 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _thickness,
      child: CustomPaint(
        painter: _RouteLegPainter(
          color: reached ? ink.lineOn : ink.line,
          dashed: !reached,
        ),
      ),
    );
  }
}

class _RouteLegPainter extends CustomPainter {
  const _RouteLegPainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final double y = size.height / 2;

    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }

    const double on = 3;
    const double off = 4;
    for (double x = 0; x < size.width; x += on + off) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + on).clamp(0, size.width).toDouble(), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RouteLegPainter old) =>
      old.color != color || old.dashed != dashed;
}
