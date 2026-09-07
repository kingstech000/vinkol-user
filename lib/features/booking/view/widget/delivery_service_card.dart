import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

class DeliveryServiceCard extends ConsumerWidget {
  const DeliveryServiceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final state = ref.watch(rideLocationProvider);
    final notifier = ref.read(rideLocationProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Section eyebrow
          Padding(
            padding: const EdgeInsets.only(
              left: VinkolSpace.xs,
              bottom: VinkolSpace.md,
            ),
            child: Text(
              context.l10n.bookingChooseService.toUpperCase(),
              style: VinkolType.labelS.copyWith(
                color: v.textTertiary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          VinkolSurface(
            radius: VinkolRadius.brLg,
            color: v.surface,
            border: v.borderSubtle,
            shadows: VinkolElevation.e1(v),
            padding: const EdgeInsetsDirectional.fromSTEB(
              VinkolSpace.md,
              VinkolSpace.md,
              VinkolSpace.md,
              VinkolSpace.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final service in _Service.all) ...<Widget>[
                  _ServiceTile(
                    service: service,
                    selected: state.orderType == service.type,
                    onTap: () => notifier.convertOrderType(service.type),
                  ),
                  if (service != _Service.all.last)
                    const SizedBox(height: VinkolSpace.md),
                ],
                const SizedBox(height: VinkolSpace.md),
                _BookNowButton(onTap: () => _book(state.orderType)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Each service opens the editor built for its shape. Single Drop gets the two-stop
  /// composer; the multi-stop products get their own screens, because a stop list, its order
  /// and a recipient per stop have never fitted in a home-screen card.
  void _book(OrderType type) {
    switch (type) {
      case OrderType.standard:
        NavigationService.instance
            .navigateTo(NavigatorRoutes.bookingComposerScreen);
      case OrderType.bulk:
        NavigationService.instance
            .navigateTo(NavigatorRoutes.multidropStopsScreen);
      case OrderType.multi:
        NavigationService.instance.navigateTo(NavigatorRoutes.batchStopsScreen);
    }
  }
}

/// One bookable service. Artwork is optional on purpose: the illustration slots are filled
/// per service in `assets/images/`, and a service whose art has not landed yet falls back to
/// its glyph rather than to a broken box.
class _Service {
  const _Service(this.type, this.image, this.glyph);

  final OrderType type;
  final String image;
  final IconData glyph;

  static const List<_Service> all = <_Service>[
    _Service(OrderType.standard, ImageAsset.serviceSingleDrop,
        PhosphorIconsRegular.truck),
    _Service(OrderType.bulk, ImageAsset.serviceMultiDrop,
        PhosphorIconsRegular.arrowsSplit),
    _Service(OrderType.multi, ImageAsset.serviceBatchRun,
        PhosphorIconsRegular.stack),
  ];

  String title(BuildContext context) => switch (type) {
        OrderType.standard => context.l10n.bookingServiceSingleDrop,
        OrderType.bulk => context.l10n.bookingServiceMultiDrop,
        OrderType.multi => context.l10n.bookingServiceBatchRun,
      };

  String meta(BuildContext context) => switch (type) {
        OrderType.standard => context.l10n.bookingServiceSingleDropMeta,
        OrderType.bulk => context.l10n.bookingServiceMultiDropMeta,
        OrderType.multi => context.l10n.bookingServiceBatchRunMeta,
      };

  /// Contextual badge copy. Every service gets a short value-proposition pill.
  String badge(BuildContext context) => switch (type) {
        OrderType.standard => context.l10n.bookingServiceSingleDropBadge,
        OrderType.bulk => context.l10n.bookingServiceMultiDropBadge,
        OrderType.multi => context.l10n.bookingServiceBatchRunBadge,
      };

  /// Whether the badge should render in the success tint rather than the default surface.
  bool get badgeIsPromo => type == OrderType.multi;
}

/// A service row: artwork plate, name, what the job is, and the selection mark.
///
/// The selected row is filled with the brand and carries the card's weight. Selection is
/// still three signals rather than colour alone — the fill, the inverted mark and the
/// white artwork plate — so it survives greyscale and a colourblind reader (D-05).
class _ServiceTile extends StatefulWidget {
  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final _Service service;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final bool on = widget.selected;

    // Selected: the tile is the live object — brand gradient + glow.
    // Unselected: one step above the card so the tile reads as a pickable row.
    final Color ground = on
        ? v.brand
        : (_pressed ? v.surfaceStrong : (v.isDark ? v.surfaceAlt : v.surface));

    // Brand glow beneath the selected tile. Dark mode only — on light, the e1 shadow is
    // enough and a coloured glow reads as an error rather than as energy.
    final List<BoxShadow> tileShadows = on && v.isDark
        ? <BoxShadow>[
            BoxShadow(
              color: v.brand.withValues(alpha: 0.22),
              blurRadius: 16,
              spreadRadius: -2,
              offset: const Offset(0, 6),
            ),
          ]
        : VinkolElevation.e1(v);

    return Semantics(
      button: true,
      selected: on,
      label: widget.service.title(context),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: _GradientTileSurface(
          radius: VinkolRadius.brMd,
          baseColor: ground,
          border: on ? null : v.borderSubtle,
          shadows: tileShadows,
          duration: VinkolMotion.fast,
          child: Padding(
            padding: const EdgeInsets.all(VinkolSpace.md),
            child: Row(
              children: <Widget>[
                _ServiceArtwork(service: widget.service, selected: on),
                const SizedBox(width: VinkolSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.service.title(context),
                        style: VinkolType.h4.copyWith(
                          fontWeight: FontWeight.w700,
                          color: on ? v.onBrand : v.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: VinkolSpace.xs),
                      Text(
                        widget.service.meta(context),
                        style: VinkolType.bodyS.copyWith(
                          color: on
                              ? v.onBrand.withValues(alpha: 0.82)
                              : v.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: VinkolSpace.sm),
                _SelectionMark(selected: on),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The artwork plate. A square, one radius step below its row, and light enough that the
/// illustration reads on the saturated row as well as on the quiet ones.
class _ServiceArtwork extends StatelessWidget {
  const _ServiceArtwork({required this.service, required this.selected});

  final _Service service;
  final bool selected;

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return AnimatedContainer(
      duration: VinkolMotion.respecting(context, VinkolMotion.fast),
      curve: VinkolMotion.standard,
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color:
            selected ? v.surface : (v.isDark ? v.surfaceStrong : v.surfaceAlt),
        borderRadius: VinkolRadius.brSm,
        border: Border.all(
          color: selected ? v.brand.withValues(alpha: 0.30) : v.borderSubtle,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        service.image,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            Center(
          child: Icon(
            service.glyph,
            size: 28,
            color: selected ? v.brand : v.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Filled plate with a tick when selected, hollow ring when not. Shape, not just colour —
/// and inverted on the saturated row so it reads as a stamp rather than as a control.
class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    // Scale-pop: the mark bumps up when it becomes selected, giving a tactile "stamp" feel.
    return AnimatedScale(
      scale: selected ? 1.0 : 0.85,
      duration: VinkolMotion.respecting(context, VinkolMotion.fast),
      curve: VinkolMotion.standard,
      child: AnimatedContainer(
        duration: VinkolMotion.respecting(context, VinkolMotion.fast),
        curve: VinkolMotion.standard,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: selected ? v.onBrand : Colors.transparent,
          shape: BoxShape.circle,
          border:
              selected ? null : Border.all(color: v.borderStrong, width: 1.5),
        ),
        child: selected
            ? Icon(Icons.check_rounded, size: 15, color: v.brand)
            : null,
      ),
    );
  }
}

class _GradientTileSurface extends StatelessWidget {
  const _GradientTileSurface({
    required this.radius,
    required this.baseColor,
    this.gradient,
    this.sheenGradient,
    this.border,
    this.shadows = const <BoxShadow>[],
    this.duration,
    required this.child,
  });

  final BorderRadiusGeometry radius;

  /// Fallback solid color. Used when [gradient] is null and as the tween target for
  /// [TweenAnimationBuilder].
  final Color baseColor;

  /// When non-null, painted instead of [baseColor]. The gradient follows the tile's shape.
  final Gradient? gradient;

  /// An optional overlay gradient (the glass sheen) painted on top of the fill.
  final Gradient? sheenGradient;

  final Color? border;
  final List<BoxShadow> shadows;
  final Duration? duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radii = radius.resolve(Directionality.maybeOf(context));

    Widget content = child;

    // The tile surface: gradient or solid fill, then optional sheen, then child.
    Widget buildPainted(Color solidFallback) {
      return CustomPaint(
        painter: _GradientTilePainter(
          radii: radii,
          solidColor: solidFallback,
          gradient: gradient,
          sheenGradient: sheenGradient,
          border: border,
          shadows: shadows,
        ),
        child: content,
      );
    }

    final Duration? d = duration;
    if (d == null) return buildPainted(baseColor);

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: baseColor),
      duration: VinkolMotion.respecting(context, d),
      curve: VinkolMotion.standard,
      builder: (BuildContext context, Color? value, Widget? _) =>
          buildPainted(value ?? baseColor),
    );
  }
}

/// Painter for [_GradientTileSurface]. Draws shadows, gradient (or solid) fill, optional
/// sheen overlay, and the hairline border — all through the superellipse contour.
class _GradientTilePainter extends CustomPainter {
  const _GradientTilePainter({
    required this.radii,
    required this.solidColor,
    this.gradient,
    this.sheenGradient,
    this.border,
    this.shadows = const <BoxShadow>[],
  });

  final BorderRadius radii;
  final Color solidColor;
  final Gradient? gradient;
  final Gradient? sheenGradient;
  final Color? border;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    if (rect.isEmpty) return;

    // Shadows.
    for (final BoxShadow shadow in shadows) {
      final Rect box = rect.shift(shadow.offset).inflate(shadow.spreadRadius);
      if (box.isEmpty) continue;
      canvas.drawPath(
        VinkolShape.superellipse(
          box,
          VinkolShape.spread(radii, shadow.spreadRadius),
        ),
        shadow.toPaint(),
      );
    }

    // Fill: gradient when provided, solid otherwise.
    final Path contour = VinkolShape.superellipse(rect, radii);
    final Gradient? g = gradient;
    if (g != null) {
      canvas.drawPath(
        contour,
        Paint()
          ..shader = g.createShader(rect)
          ..isAntiAlias = true,
      );
    } else {
      canvas.drawPath(
        contour,
        Paint()
          ..color = solidColor
          ..isAntiAlias = true,
      );
    }

    // Sheen overlay.
    final Gradient? sheen = sheenGradient;
    if (sheen != null) {
      canvas.drawPath(
        contour,
        Paint()
          ..shader = sheen.createShader(rect)
          ..isAntiAlias = true,
      );
    }

    // Hairline border.
    final Color? edge = border;
    if (edge != null) {
      const double inset = 0.5;
      canvas.drawPath(
        VinkolShape.superellipse(
          rect.deflate(inset),
          VinkolShape.spread(radii, -inset),
        ),
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(_GradientTilePainter old) =>
      old.radii != radii ||
      old.solidColor != solidColor ||
      old.gradient != gradient ||
      old.sheenGradient != sheenGradient ||
      old.border != border ||
      shadows != old.shadows;
}

/// When the rider should collect. A quiet pill rather than a field, because it has a
/// sensible default — now — and most bookings never touch it.
class _PickupTimeChip extends StatefulWidget {
  const _PickupTimeChip({required this.pickupAt, required this.onTap});

  final DateTime? pickupAt;
  final VoidCallback onTap;

  @override
  State<_PickupTimeChip> createState() => _PickupTimeChipState();
}

class _PickupTimeChipState extends State<_PickupTimeChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final String value = formatPickupAt(context, widget.pickupAt);

    return Center(
      child: Semantics(
        button: true,
        label: '${context.l10n.bookingPickup}, $value',
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: VinkolSurface(
            radius: VinkolRadius.brFull,
            color: _pressed ? v.surfaceStrong : v.surfaceAlt,
            border: v.borderSubtle,
            duration: VinkolMotion.instant,
            padding: const EdgeInsetsDirectional.fromSTEB(
              VinkolSpace.lg,
              VinkolSpace.sm,
              VinkolSpace.md,
              VinkolSpace.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.schedule_rounded, size: 17, color: v.textSecondary),
                const SizedBox(width: VinkolSpace.sm),
                Flexible(
                  child: Text(
                    value,
                    style: VinkolType.label.copyWith(color: v.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: VinkolSpace.xs),
                Icon(Icons.expand_more_rounded,
                    size: 18, color: v.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The action. Inverse surface, so it is the black pill of the reference on a light screen
/// and its white peer in dark — the maximum contrast either register can offer, and the one
/// thing on the card that is not competing with the selected service.
class _BookNowButton extends StatefulWidget {
  const _BookNowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BookNowButton> createState() => _BookNowButtonState();
}

class _BookNowButtonState extends State<_BookNowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Semantics(
      button: true,
      label: context.l10n.bookingBookNow,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          child: VinkolSurface(
            radius: VinkolRadius.brFull,
            color: v.surfaceInverse,
            padding: const EdgeInsets.symmetric(
              horizontal: VinkolSpace.xxxl,
              vertical: VinkolSpace.lg,
            ),
            child: Center(
              child: Text(
                context.l10n.bookingBookNow,
                style: VinkolType.h4.copyWith(color: v.textInverse),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The pickup choice, in the user's locale. `null` is now.
///
/// Shared with the composer screen so both surfaces render the same choice the same way.
String formatPickupAt(BuildContext context, DateTime? at) {
  if (at == null) return context.l10n.bookingPickupNow;

  final String time = TimeOfDay.fromDateTime(at).format(context);
  final DateTime now = DateTime.now();
  final bool isToday =
      at.year == now.year && at.month == now.month && at.day == now.day;
  if (isToday) return context.l10n.bookingPickupToday(time);

  final String locale = Localizations.localeOf(context).toLanguageTag();
  return context.l10n
      .bookingPickupOnDate(DateFormat.MMMEd(locale).format(at), time);
}

/// Now, or a time the user picks. Two options, so it is a sheet and not a picker.
class _PickupTimeSheet extends StatelessWidget {
  const _PickupTimeSheet({required this.scheduled});

  final bool scheduled;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return VinkolSurface(
      radius: VinkolRadius.brSheet,
      color: v.surface,
      border: v.borderSubtle,
      shadows: VinkolElevation.e2(v),
      padding: EdgeInsetsDirectional.fromSTEB(
        VinkolSpace.xl,
        VinkolSpace.md,
        VinkolSpace.xl,
        VinkolSpace.xl + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: v.borderStrong,
                borderRadius: VinkolRadius.brFull,
              ),
            ),
          ),
          const SizedBox(height: VinkolSpace.lg),
          Text(
            context.l10n.bookingWhenShouldWeCollect,
            style: VinkolType.h3.copyWith(color: v.textPrimary),
          ),
          const SizedBox(height: VinkolSpace.lg),
          _PickupOption(
            icon: Icons.bolt_rounded,
            title: context.l10n.bookingPickupNow,
            meta: context.l10n.bookingPickupNowMeta,
            selected: !scheduled,
            onTap: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: VinkolSpace.sm),
          _PickupOption(
            icon: Icons.event_rounded,
            title: context.l10n.bookingScheduleForLater,
            meta: context.l10n.bookingScheduleForLaterMeta,
            selected: scheduled,
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}

class _PickupOption extends StatelessWidget {
  const _PickupOption({
    required this.icon,
    required this.title,
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String meta;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: VinkolSurface(
          radius: VinkolRadius.brMd,
          color: selected ? v.brand : v.surfaceAlt,
          border: selected ? null : v.borderSubtle,
          duration: VinkolMotion.fast,
          padding: const EdgeInsets.all(VinkolSpace.md),
          child: Row(
            children: <Widget>[
              Icon(icon,
                  size: 20, color: selected ? v.onBrand : v.textSecondary),
              const SizedBox(width: VinkolSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: VinkolType.h4.copyWith(
                        color: selected ? v.onBrand : v.textPrimary,
                      ),
                    ),
                    const SizedBox(height: VinkolSpace.xxs),
                    Text(
                      meta,
                      style: VinkolType.bodyS.copyWith(
                        color: selected
                            ? v.onBrand.withValues(alpha: 0.82)
                            : v.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: VinkolSpace.sm),
              _SelectionMark(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}
