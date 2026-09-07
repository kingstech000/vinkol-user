import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/design/design.dart';

/// The shell every quote screen shares: a full-bleed map with a draggable sheet over it.
///
/// The three quote screens each carried their own copy of this — three `Scaffold`s, three
/// transparent `AppBar`s wrapping a hand-built back button, three `DraggableScrollableSheet`s
/// with a hand-drawn grip, at three different radii. They are one widget now, so the map
/// chrome is defined once and the screens only supply what is actually different: the
/// geometry they plot and the rows they list.
///
/// Chrome follows signature #5: controls sit on a hairline-bordered surface, never on a
/// floating shadowed card, because a drop shadow over map tiles reads as dirt.
class QuoteMapScaffold extends StatelessWidget {
  const QuoteMapScaffold({
    super.key,
    required this.initialCameraPosition,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
    required this.children,
    this.initialSheetSize = 0.62,
    this.minSheetSize = 0.42,
    this.maxSheetSize = 0.92,
    this.onBack,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final ValueChanged<GoogleMapController> onMapCreated;

  /// The sheet's contents. The scaffold owns the scroll view so the sheet drags correctly;
  /// callers pass a flat list and never touch the controller.
  final List<Widget> children;

  final double initialSheetSize;
  final double minSheetSize;
  final double maxSheetSize;

  /// Defaults to popping the route.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: v.canvas,
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: onMapCreated,
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            // Keep the plotted route in the strip of map the sheet does not cover.
            padding:
                EdgeInsets.only(bottom: media.size.height * initialSheetSize),
          ),
          PositionedDirectional(
            top: media.padding.top + VinkolSpace.sm,
            start: VinkolSpace.pageMargin,
            child: QuoteMapControl(
              icon: Icons.arrow_back,
              semanticLabel:
                  MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: initialSheetSize,
            minChildSize: minSheetSize,
            maxChildSize: maxSheetSize,
            builder: (BuildContext context, ScrollController scrollController) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: v.surface,
                  borderRadius: VinkolRadius.brSheet,
                  border: Border(top: BorderSide(color: v.borderSubtle)),
                  boxShadow: VinkolElevation.e2(v),
                ),
                child: ClipRRect(
                  borderRadius: VinkolRadius.brSheet,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                      VinkolSpace.pageMargin,
                      VinkolSpace.md,
                      VinkolSpace.pageMargin,
                      VinkolSpace.xxl + media.padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const _SheetGrip(),
                        ...children,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A single map control. e0 — hairline border, no shadow.
class QuoteMapControl extends StatelessWidget {
  const QuoteMapControl({
    super.key,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: v.surface,
        shape: RoundedRectangleBorder(
          borderRadius: VinkolRadius.brSm,
          side: BorderSide(color: v.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            // 44pt: the minimum comfortable touch target, and the size the prototype's
            // `.ico` control resolves to.
            width: 44,
            height: 44,
            child: Icon(icon, size: 19, color: v.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _SheetGrip extends StatelessWidget {
  const _SheetGrip();

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: VinkolSpace.lg),
        decoration: BoxDecoration(
          color: v.borderStrong,
          borderRadius: VinkolRadius.brFull,
        ),
      ),
    );
  }
}
