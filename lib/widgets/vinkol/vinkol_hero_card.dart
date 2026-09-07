import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// A stop on the hero's route row.
class VinkolHeroStop {
  const VinkolHeroStop({required this.label, required this.place});

  /// The eyebrow: "From", "To".
  final String label;
  final String place;
}

/// Whoever is carrying the delivery, shown in the hero's foot row.
class VinkolHeroContact {
  const VinkolHeroContact({
    required this.name,
    required this.meta,
    this.initials,
    this.onCall,
  });

  final String name;

  /// One line under the name — the vehicle, the store, the shopper's role.
  final String meta;

  /// Falls back to the first letter of [name].
  final String? initials;

  /// Null hides the call action. The API exposes a phone number and nothing else, so
  /// calling is the only contact channel there is (D-10).
  final VoidCallback? onCall;
}

/// **The saturated hero** — the one object per screen allowed to wear the brand blue.
///
/// Direction A · Midnight (D-07) keeps every surface quiet *except* one, and that one always
/// carries the live thing: the open delivery, the wallet balance, the earned reward. If a
/// screen has two of these, the screen is wrong.
///
/// The gradient is the single sanctioned use of one outside the map scrim — it is what the
/// client's references all shared and what `.hero` in the prototype specifies. Everything
/// else in the system is flat.
class VinkolHeroCard extends StatelessWidget {
  const VinkolHeroCard({
    super.key,
    required this.eyebrow,
    this.reference,
    this.headline,
    this.headlineUnit,
    this.subtitle,
    this.badge,
    this.origin,
    this.destination,
    this.contact,
    this.actions = const <Widget>[],
    this.live = false,
    this.onTap,
  });

  /// Small-caps label at the top: "ACTIVE DELIVERY", "WALLET BALANCE".
  final String eyebrow;

  /// The order or tracking id. Rendered in tabular figures — it gets read aloud and
  /// transcribed.
  final String? reference;

  /// The number that matters. An ETA, a balance, a discount.
  ///
  /// Rendered in `num.xl` rather than the display face: it is a figure, not a title, and
  /// money has to be tabular so it does not jitter as the balance refreshes.
  final String? headline;

  /// The unit beside [headline], at reduced weight so the number stays the hero
  /// (signature #4).
  final String? headlineUnit;

  final String? subtitle;

  /// Optional pill in the top corner — the status, a courier name.
  final String? badge;

  final VinkolHeroStop? origin;
  final VinkolHeroStop? destination;
  final VinkolHeroContact? contact;

  /// Actions along the hero's foot, laid out in one equal-width row. This is where the two
  /// things you can do with a wallet balance live — anywhere else on the screen they would
  /// be competing with the number they act on.
  final List<Widget> actions;

  /// Pulses the eyebrow dot. Only true when something is actually moving.
  final bool live;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final onHero = v.onBrand;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: VinkolRadius.brLg,
        gradient: LinearGradient(
          // 145deg in CSS, measured from the top: down and to the end.
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[v.brand, v.brandDeep],
        ),
      ),
      child: ClipRRect(
        borderRadius: VinkolRadius.brLg,
        child: Stack(
          children: <Widget>[
            // The one piece of decoration in the system: a soft disc bleeding off the end
            // corner, which is what stops a saturated block reading as flat.
            PositionedDirectional(
              end: -55,
              top: -75,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: onHero.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(VinkolSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _top(context, onHero),
                  if (headline != null) ...<Widget>[
                    const SizedBox(height: VinkolSpace.md),
                    _headline(onHero),
                  ],
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: VinkolType.bodyS
                          .copyWith(color: onHero.withValues(alpha: 0.9)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (origin != null && destination != null) ...<Widget>[
                    const SizedBox(height: VinkolSpace.xl),
                    _RouteRow(
                      origin: origin!,
                      destination: destination!,
                      ink: onHero,
                    ),
                  ],
                  if (contact != null) ...<Widget>[
                    const SizedBox(height: VinkolSpace.lg),
                    _FootRow(
                        contact: contact!, ink: onHero, brandDeep: v.brandDeep),
                  ],
                  if (actions.isNotEmpty) ...<Widget>[
                    const SizedBox(height: VinkolSpace.xl),
                    Row(
                      children: <Widget>[
                        for (var i = 0; i < actions.length; i++) ...<Widget>[
                          if (i > 0) const SizedBox(width: VinkolSpace.sm),
                          Expanded(child: actions[i]),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return _Pressable(
        borderRadius: VinkolRadius.brLg, onTap: onTap, child: card);
  }

  Widget _top(BuildContext context, Color ink) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (live) ...<Widget>[
                    _LiveDot(color: ink),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      eyebrow.toUpperCase(),
                      style: VinkolType.labelS
                          .copyWith(color: ink.withValues(alpha: 0.8)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (reference != null) ...<Widget>[
                const SizedBox(height: VinkolSpace.xs),
                Text(
                  reference!,
                  style: VinkolType.numL.copyWith(color: ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (badge != null) ...<Widget>[
          const SizedBox(width: VinkolSpace.md),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: VinkolSpace.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: ink.withValues(alpha: 0.18),
              borderRadius: VinkolRadius.brFull,
            ),
            child: Text(
              badge!.toUpperCase(),
              style: VinkolType.labelS.copyWith(color: ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _headline(Color ink) {
    // Baseline-aligned so the unit sits on the number's baseline rather than its box.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Flexible(
          child: Text(
            headline!,
            style: VinkolType.numXl.copyWith(color: ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (headlineUnit != null) ...<Widget>[
          const SizedBox(width: 6),
          Text(
            headlineUnit!,
            style: VinkolType.h3.copyWith(color: ink.withValues(alpha: 0.9)),
          ),
        ],
      ],
    );
  }
}

/// The pulsing dot beside a live eyebrow. The only motion on the card.
class _LiveDot extends StatefulWidget {
  const _LiveDot({required this.color});

  final Color color;

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (VinkolMotion.reduced(context)) {
      _controller.stop();
      _controller.value = 0;
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
      builder: (context, _) => Opacity(
        opacity: 1 - (_controller.value * 0.65),
        child: Container(
          width: 7,
          height: 7,
          decoration:
              BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// From → to, with the Line's arrow terminus rendered horizontally.
class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.origin,
    required this.destination,
    required this.ink,
  });

  final VinkolHeroStop origin;
  final VinkolHeroStop destination;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(child: _stop(origin, TextAlign.start)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.md),
          child: SizedBox(
            width: 34,
            child: CustomPaint(
              size: const Size(34, 8),
              painter: _ArrowPainter(color: ink.withValues(alpha: 0.35)),
            ),
          ),
        ),
        Flexible(child: _stop(destination, TextAlign.end)),
      ],
    );
  }

  Widget _stop(VinkolHeroStop stop, TextAlign align) {
    final cross = align == TextAlign.start
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
    return Column(
      crossAxisAlignment: cross,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          stop.label,
          style:
              VinkolType.caption.copyWith(color: ink.withValues(alpha: 0.78)),
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          stop.place,
          style: VinkolType.h4.copyWith(color: ink),
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, y), Offset(size.width - 5, y), paint);
    canvas.drawPath(
      Path()
        ..moveTo(size.width, y)
        ..lineTo(size.width - 6, y - 3.5)
        ..lineTo(size.width - 6, y + 3.5)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

/// Rider or shopper, plus the one contact action the backend supports.
class _FootRow extends StatelessWidget {
  const _FootRow({
    required this.contact,
    required this.ink,
    required this.brandDeep,
  });

  final VinkolHeroContact contact;
  final Color ink;
  final Color brandDeep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(top: VinkolSpace.lg),
      decoration: BoxDecoration(
        border: BorderDirectional(
          top: BorderSide(color: ink.withValues(alpha: 0.22)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ink.withValues(alpha: 0.18),
            ),
            child: Text(
              contact.initials ??
                  (contact.name.isEmpty ? '?' : contact.name.characters.first),
              style: VinkolType.h4.copyWith(color: ink),
            ),
          ),
          const SizedBox(width: VinkolSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  contact.name,
                  style: VinkolType.h4.copyWith(color: ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  contact.meta,
                  style: VinkolType.caption
                      .copyWith(color: ink.withValues(alpha: 0.8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (contact.onCall != null) ...<Widget>[
            const SizedBox(width: VinkolSpace.md),
            _Pressable(
              borderRadius: VinkolRadius.brFull,
              onTap: contact.onCall,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: ink),
                child: Icon(Icons.call_outlined, size: 20, color: brandDeep),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Press feedback for the hero and its call button: a brief dim, no shadow, no scale bounce.
class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.child,
    required this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return Semantics(
      button: true,
      enabled: !disabled,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          opacity: disabled ? 0.5 : (_pressed ? 0.82 : 1),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A button on the hero's foot.
///
/// It cannot be a [VinkolPrimaryButton]: that resolves its fill from the theme, and on a
/// saturated ground the only two legible tones are the on-brand ink itself and a wash of it.
/// [filled] is the primary of the pair — one per hero.
class VinkolHeroAction extends StatefulWidget {
  const VinkolHeroAction({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Solid on-brand ink with the deep brand as the label — the stronger of the two.
  final bool filled;

  @override
  State<VinkolHeroAction> createState() => _VinkolHeroActionState();
}

class _VinkolHeroActionState extends State<VinkolHeroAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final on = v.onBrand;
    final disabled = widget.onPressed == null;

    final Color fill = widget.filled
        ? on.withValues(alpha: _pressed ? 0.86 : 1)
        : on.withValues(alpha: _pressed ? 0.28 : 0.18);
    final Color ink =
        widget.filled ? v.brandDeep : on.withValues(alpha: disabled ? 0.55 : 1);

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          constraints: const BoxConstraints(minHeight: 46),
          alignment: Alignment.center,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: VinkolSpace.md,
            vertical: VinkolSpace.sm,
          ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: VinkolRadius.brFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(widget.icon, size: 17, color: ink),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: VinkolType.button.copyWith(color: ink),
                  textAlign: TextAlign.center,
                  // French runs ~40% longer; the label wraps rather than clipping.
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
