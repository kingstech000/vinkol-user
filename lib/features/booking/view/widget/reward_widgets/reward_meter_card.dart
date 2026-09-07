// The compact reward card: the gift box *is* the progress meter.
part of '../reward_widgets.dart';

/// The reward on home, in one row.
///
/// Home is a map, a service picker and then this. Anything two hundred points tall puts
/// itself below the fold and gets scrolled past, so the route, the labels and the headline
/// stack are all gone. What replaces them is the artwork doing a job only artwork can do:
/// **colour rises through the gift box as deliveries land**. One object carries the count,
/// the prize and the state at once.
///
/// Colour temperature is the second signal. The card is cool and quiet at zero and heats
/// through amber to a full celebration at three — every part of that reads off one number,
/// [_heat], so "warmer" is a single decision rather than four. The palette comes from the
/// artwork itself ([VinkolRewardInk]); a warm card built from the gift's own gold and ribbon
/// red still reads as Vinkol.
///
/// Nothing on it is invented: `hasCoupon` and `ordersSincePromo` are the only two fields the
/// API exposes, so there is no expiry, no history and no lifetime saving to draw (D-10).
class RewardMeterCard extends StatefulWidget {
  const RewardMeterCard({super.key, required this.progress, this.onTap});

  final RewardProgress progress;
  final VoidCallback? onTap;

  @override
  State<RewardMeterCard> createState() => _RewardMeterCardState();
}

class _RewardMeterCardState extends State<RewardMeterCard> {
  bool _pressed = false;

  /// How warm the card runs, per stop completed.
  ///
  /// Zero is not zero: a card that starts fully grey reads as *disabled* rather than as *not
  /// yet*, so even an untouched reward carries a little colour.
  static const List<double> _heat = <double>[0.16, 0.42, 0.68, 1.0];

  double get _heatOf {
    final RewardProgress p = widget.progress;
    if (p.earned) return 1;
    final int i = p.done.clamp(0, _heat.length - 1);
    return _heat[i];
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final VinkolRewardInk warm = VinkolRewardInk.of(v);
    final RewardProgress p = widget.progress;
    final bool won = p.earned;

    // The count chip turns gold before the reward does: the card starts warming at two of
    // three, so the last delivery feels like the last one.
    final bool hot = won || p.done >= p.target - 1;

    final Widget row = Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      (won ? l10n.rewardReady : l10n.rewardShortLabel)
                          .toUpperCase(),
                      style: VinkolType.labelS.copyWith(
                        color: won ? warm.onFestiveMuted : v.textTertiary,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: VinkolSpace.sm),
                  _CountChip(
                    label: l10n.rewardCountOfTarget(p.done, p.target),
                    ink: won ? warm.onFestive : (hot ? warm.gold : v.textBrand),
                    ground: won
                        ? warm.onFestive.withValues(alpha: 0.22)
                        : (hot ? warm.goldDim : v.brandSubtle),
                  ),
                ],
              ),
              const SizedBox(height: VinkolSpace.xs),
              Text(
                won
                    ? l10n.rewardReadyHeadline(p.percentOff)
                    : l10n.rewardRemaining(p.remaining),
                style: VinkolType.h4.copyWith(
                  color: won ? warm.onFestive : v.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                // Two lines, not one. The card is compact by design, but truncating the
                // sentence that says what happens next is not a saving.
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: VinkolSpace.xxs),
              Text(
                won
                    ? l10n.rewardAppliedAutomatically
                    : l10n.rewardStoreOrdersCount,
                style: VinkolType.caption.copyWith(
                  color: won ? warm.onFestiveMuted : v.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: VinkolSpace.md),
        _GiftMeter(progress: p, heat: _heatOf, warm: warm),
      ],
    );

    final Widget card = ClipRRect(
      borderRadius: VinkolRadius.brMd,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: v.surface,
          border: won ? null : Border.all(color: v.borderSubtle),
          borderRadius: VinkolRadius.brMd,
        ),
        child: Stack(
          children: <Widget>[
            // The ground. Earned takes the festive gradient outright; everything before it
            // takes the same wash at the card's heat, so the two are one object warming up
            // rather than two designs.
            Positioned.fill(
              child: _Wash(
                heat: _heatOf,
                colors: won ? warm.festive : warm.wash,
                opaque: won,
              ),
            ),
            if (won) const Positioned.fill(child: _Confetti()),
            Padding(padding: const EdgeInsets.all(VinkolSpace.lg), child: row),
          ],
        ),
      ),
    );

    if (widget.onTap == null) return card;

    return Semantics(
      button: true,
      label: won
          ? l10n.rewardEarnedSemantics
          : l10n.rewardProgressSemantics(p.done, p.target),
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
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

/// The progress wash: cool on the start edge, warm on the end, so the card is warmer nearer
/// the prize. Its strength is the card's heat, and it moves when the count does.
class _Wash extends StatelessWidget {
  const _Wash({
    required this.heat,
    required this.colors,
    required this.opaque,
  });

  final double heat;
  final List<Color> colors;

  /// The earned ground is the gradient itself, not a veil over the surface.
  final bool opaque;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: opaque ? 1 : heat),
      duration: VinkolMotion.respecting(context, VinkolMotion.slow),
      curve: VinkolMotion.standard,
      builder: (BuildContext context, double t, Widget? _) => Opacity(
        opacity: t,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const AlignmentDirectional(-1, -0.4),
              end: const AlignmentDirectional(1, 0.4),
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }
}

/// The count, as a pill. Brand while the card is cool, gold once it is warming, white on the
/// festive ground — the chip is the first thing to change colour, so the turn is visible a
/// delivery before it happens.
class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.ink,
    required this.ground,
  });

  final String label;
  final Color ink;
  final Color ground;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: VinkolMotion.respecting(context, VinkolMotion.slow),
      curve: VinkolMotion.standard,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VinkolSpace.sm,
        vertical: VinkolSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: ground,
        borderRadius: VinkolRadius.brFull,
      ),
      child: Text(
        label,
        style: VinkolType.labelS.copyWith(
          color: ink,
          fontWeight: FontWeight.w800,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// The meter itself.
///
/// One image painted twice: the lower copy is greyscale and is the whole box, the upper is
/// full colour clipped to the fill line. Colour rises through the object as the count does.
class _GiftMeter extends StatefulWidget {
  const _GiftMeter({
    required this.progress,
    required this.heat,
    required this.warm,
  });

  final RewardProgress progress;
  final double heat;
  final VinkolRewardInk warm;

  static const double side = 66;

  @override
  State<_GiftMeter> createState() => _GiftMeterState();
}

class _GiftMeterState extends State<_GiftMeter> with TickerProviderStateMixin {
  /// The ray burst's rotation. Slow enough to be light rather than a spinner.
  AnimationController? _slow;

  /// Shine, bob and confetti drift all ride this one.
  AnimationController? _beat;

  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ambient loops exist only while there is something to celebrate, and never when the
    // user has asked for less motion.
    final bool want = widget.progress.earned && !VinkolMotion.reduced(context);
    if (want == _running) return;
    _running = want;
    if (want) {
      _slow = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 26),
      )..repeat();
      _beat = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3600),
      )..repeat();
    } else {
      _slow?.dispose();
      _beat?.dispose();
      _slow = null;
      _beat = null;
    }
  }

  @override
  void didUpdateWidget(_GiftMeter old) {
    super.didUpdateWidget(old);
    if (old.progress.earned != widget.progress.earned) didChangeDependencies();
  }

  @override
  void dispose() {
    _slow?.dispose();
    _beat?.dispose();
    super.dispose();
  }

  /// Greyscale by luminance. The locked box has no colour and barely any presence — it is a
  /// promise, not a possession.
  static const ColorFilter _grey = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final RewardProgress p = widget.progress;
    final bool won = p.earned;
    final double top = rewardMeterFillTop(p);

    final Widget art = Image.asset(
      ImageAsset.giftBox,
      fit: BoxFit.contain,
      // A missing asset must cost the card its meter, never the whole home screen.
      errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
          const SizedBox.shrink(),
    );

    return SizedBox(
      width: _GiftMeter.side,
      height: _GiftMeter.side,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // The light the box throws onto the card, growing with heat.
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: widget.heat),
              duration: VinkolMotion.respecting(context, VinkolMotion.slow),
              curve: VinkolMotion.standard,
              builder: (BuildContext context, double t, Widget? _) => Opacity(
                opacity: t,
                child: _Glow(color: widget.warm.glow),
              ),
            ),
          ),
          if (_slow != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _slow!,
                  builder: (BuildContext context, Widget? _) => CustomPaint(
                    painter: _RaysPainter(
                      turn: _slow!.value,
                      gold: widget.warm.gold,
                      rose: widget.warm.rose,
                    ),
                  ),
                ),
              ),
            ),
          // The box, bobbing gently once it is won.
          Positioned.fill(
            child: _Bob(
              beat: _beat,
              child: Stack(
                children: <Widget>[
                  if (!won)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.28,
                        child: ColorFiltered(colorFilter: _grey, child: art),
                      ),
                    ),
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: top),
                      duration:
                          VinkolMotion.respecting(context, VinkolMotion.slow),
                      curve: VinkolMotion.standard,
                      builder: (BuildContext context, double t, Widget? _) =>
                          ClipRect(clipper: _FillClipper(t), child: art),
                    ),
                  ),
                  if (_beat != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _Shine(
                          beat: _beat!,
                          color: widget.warm.shine,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // The waterline. A bloom rather than a rule, so it reads as a level.
          if (!won)
            Positioned.fill(
              child: IgnorePointer(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: top),
                  duration: VinkolMotion.respecting(context, VinkolMotion.slow),
                  curve: VinkolMotion.standard,
                  builder: (BuildContext context, double t, Widget? _) =>
                      CustomPaint(
                    painter: _WaterlinePainter(
                      top: t,
                      cool: context.vinkol.brand,
                      warm: widget.warm.goldDeep,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Clips the coloured copy of the artwork to everything below [top].
class _FillClipper extends CustomClipper<Rect> {
  const _FillClipper(this.top);

  final double top;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * top, size.width, size.height);

  @override
  bool shouldReclip(_FillClipper old) => old.top != top;
}

/// The gold the box casts on the card.
class _Glow extends StatelessWidget {
  const _Glow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
            stops: const <double>[0, 0.7],
          ),
        ),
      ),
    );
  }
}

/// The ray burst behind a won gift. Masked to a ring so it reads as light rather than as a
/// starburst sticker, and slow enough that it never asks to be watched.
class _RaysPainter extends CustomPainter {
  const _RaysPainter({
    required this.turn,
    required this.gold,
    required this.rose,
  });

  final double turn;
  final Color gold;
  final Color rose;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Offset centre = size.center(Offset.zero);
    final double outer = size.longestSide * 0.86;
    final double inner = size.longestSide * 0.40;

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(turn * 2 * pi);
    canvas.translate(-centre.dx, -centre.dy);

    // The ring the rays live in. Painting into it rather than over the box keeps the artwork
    // untouched by the decoration behind it.
    final Path ring = Path()
      ..addOval(Rect.fromCircle(center: centre, radius: outer))
      ..addOval(Rect.fromCircle(center: centre, radius: inner))
      ..fillType = PathFillType.evenOdd;
    canvas.save();
    canvas.clipPath(ring);

    const List<double> spokes = <double>[0, 90, 150, 240, 300];
    for (int i = 0; i < spokes.length; i++) {
      final double a = spokes[i] * pi / 180;
      final Paint paint = Paint()
        ..color = (i.isEven ? gold : rose).withValues(alpha: 0.34)
        ..style = PaintingStyle.stroke
        ..strokeWidth = i.isEven ? 5 : 3
        ..isAntiAlias = true;
      canvas.drawLine(
        centre + Offset(cos(a) * inner, sin(a) * inner),
        centre + Offset(cos(a) * outer, sin(a) * outer),
        paint,
      );
    }
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RaysPainter old) =>
      old.turn != turn || old.gold != gold || old.rose != rose;
}

/// The waterline: a soft blue-to-gold bar sitting across the box's own width, with a bloom
/// under it. Drawn, not shadowed, so it stays one paint.
class _WaterlinePainter extends CustomPainter {
  const _WaterlinePainter({
    required this.top,
    required this.cool,
    required this.warm,
  });

  final double top;
  final Color cool;
  final Color warm;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    // The artwork's box spans x 117..441 of 500. The line stops where the box does, so it
    // reads as a level in an object rather than a rule drawn over the card.
    final Rect bar = Rect.fromLTWH(
      size.width * 0.20,
      size.height * top - 1,
      size.width * 0.70,
      2,
    );
    final Shader shader =
        LinearGradient(colors: <Color>[cool, warm]).createShader(bar);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bar.inflate(3), const Radius.circular(4)),
      Paint()
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..isAntiAlias = true,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(1)),
      Paint()
        ..shader = shader
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_WaterlinePainter old) =>
      old.top != top || old.cool != cool || old.warm != warm;
}

/// The won box's slow rise and fall. Three points of travel — enough to be alive, not enough
/// to be a toy.
class _Bob extends StatelessWidget {
  const _Bob({required this.beat, required this.child});

  final AnimationController? beat;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AnimationController? c = beat;
    if (c == null) return child;
    return AnimatedBuilder(
      animation: c,
      builder: (BuildContext context, Widget? inner) => Transform.translate(
        offset: Offset(0, -3 * sin(c.value * 2 * pi)),
        child: inner,
      ),
      child: child,
    );
  }
}

/// One sweep of shine across a won box.
class _Shine extends StatelessWidget {
  const _Shine({required this.beat, required this.color});

  final AnimationController beat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: beat,
      builder: (BuildContext context, Widget? _) {
        // The sweep crosses in the first 55% of the beat and rests for the remainder, so the
        // box is still most of the time.
        final double t = (beat.value / 0.55).clamp(0.0, 1.0);
        return ClipRect(
          child: FractionalTranslation(
            translation: Offset(-1.4 + t * 2.8, 0),
            child: Transform.rotate(
              angle: 0.21,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      color.withValues(alpha: 0),
                      color,
                      color.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Four flecks in the artwork's own hues, drifting. Four, deliberately: past that it stops
/// being celebration and becomes noise.
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  AnimationController? _drift;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool want = !VinkolMotion.reduced(context);
    if (want == (_drift != null)) return;
    if (want) {
      _drift = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 5500),
      )..repeat();
    } else {
      _drift?.dispose();
      _drift = null;
    }
  }

  @override
  void dispose() {
    _drift?.dispose();
    super.dispose();
  }

  /// Position as a fraction of the card, and the phase each fleck drifts on.
  static const List<Offset> _at = <Offset>[
    Offset(0.22, 0.18),
    Offset(0.47, 0.70),
    Offset(0.63, 0.24),
    Offset(0.80, 0.74),
  ];
  static const List<double> _phase = <double>[0.07, 0.33, 0.56, 0.42];

  @override
  Widget build(BuildContext context) {
    final VinkolRewardInk warm = VinkolRewardInk.of(context.vinkol);
    final AnimationController? c = _drift;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          Widget flecks(double t) => Stack(
                children: <Widget>[
                  for (int i = 0; i < _at.length; i++)
                    Positioned(
                      left: box.maxWidth * _at[i].dx,
                      top: box.maxHeight * _at[i].dy -
                          7 * sin((t + _phase[i]) * 2 * pi),
                      child: Transform.rotate(
                        angle: 0.38 * sin((t + _phase[i]) * 2 * pi),
                        child: Container(
                          width: 5,
                          height: 9,
                          decoration: BoxDecoration(
                            color: warm.confetti[i],
                            borderRadius: VinkolRadius.brXs,
                          ),
                        ),
                      ),
                    ),
                ],
              );

          if (c == null) return flecks(0);
          return AnimatedBuilder(
            animation: c,
            builder: (BuildContext context, Widget? _) => flecks(c.value),
          );
        },
      ),
    );
  }
}
