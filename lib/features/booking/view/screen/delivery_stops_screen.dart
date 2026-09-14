import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/view/widget/ride_detail_input_field.dart';
import 'package:starter_codes/provider/location_provider.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/widgets/content_sized_sheet.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/map_control.dart';

/// Step two of a booking: where it starts and where it ends. Map-first, as
/// every booking surface is (`02-do-not-lose.md` #6): the stops are pinned on
/// a full-bleed map and the form sits in a sheet that is only ever as tall as
/// the form, so the map keeps whatever room the form does not need.
class DeliveryStopsScreen extends ConsumerStatefulWidget {
  const DeliveryStopsScreen({super.key});

  @override
  ConsumerState<DeliveryStopsScreen> createState() =>
      _DeliveryStopsScreenState();
}

class _DeliveryStopsScreenState extends ConsumerState<DeliveryStopsScreen> {
  /// Past this extent the sheet is under the map controls, so they step aside.
  static const _controlsHideAt = 0.82;

  /// Where the sheet rests when the form is tall enough to need it. The map
  /// treats that band as covered, so pins are framed in the part still seen.
  static const _restingSize = 0.6;

  bool _controlsHidden = false;

  void _onSheetExtent(double extent) {
    final hidden = extent >= _controlsHideAt;
    if (hidden != _controlsHidden) setState(() => _controlsHidden = hidden);
  }

  @override
  Widget build(BuildContext context) {
    final stops = ref.watch(rideLocationProvider).stops;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 76.w,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(start: 20.w),
          child: Center(
            child: MapControl(
              icon: PhosphorIconsRegular.caretLeft,
              semanticLabel: 'Back',
              hidden: _controlsHidden,
              onTap: NavigationService.instance.goBack,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _StopsMap(
              stops: stops,
              // The status bar and the back control above; the sheet below.
              coveredTop: MediaQuery.paddingOf(context).top + 72.h,
              coveredBottom: MediaQuery.sizeOf(context).height * _restingSize,
            ),
          ),
          ContentSizedSheet(
            color: VinkolPalette.white,
            restingSize: _restingSize,
            onExtentChanged: _onSheetExtent,
            child: Padding(
              padding: EdgeInsets.only(
                top: 4.h,
                bottom: 16.h + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RideDetailsInput(),
                  Gap.h24,
                  const FindRiderAction(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The stops that have an address, pinned. Frames them when there are any;
/// otherwise rests on the customer's own location, or the market's centre
/// while that is still unknown. No route line: a route needs a quote first.
class _StopsMap extends ConsumerStatefulWidget {
  const _StopsMap({
    required this.stops,
    required this.coveredTop,
    required this.coveredBottom,
  });

  final List<StopModel> stops;

  /// How much of the map the chrome above and the sheet below cover, so the
  /// camera frames pins in the part the customer can actually see.
  final double coveredTop;
  final double coveredBottom;

  @override
  ConsumerState<_StopsMap> createState() => _StopsMapState();
}

class _StopsMapState extends ConsumerState<_StopsMap> {
  GoogleMapController? _controller;

  List<LatLng> get _pinned => [
        for (final stop in widget.stops)
          if (stop.location?.coordinates != null) stop.location!.coordinates!,
      ];

  @override
  void didUpdateWidget(covariant _StopsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _frame();
  }

  Future<void> _frame() async {
    final controller = _controller;
    if (controller == null) return;
    final points = _pinned;
    if (points.isEmpty) return;
    if (points.length == 1) {
      await controller
          .animateCamera(CameraUpdate.newLatLngZoom(points.first, 15));
      return;
    }
    var minLat = points.first.latitude, maxLat = points.first.latitude;
    var minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    await controller.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      64.w,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final points = _pinned;
    final here = ref.watch(locationControllerProvider).currentLatLng;
    final market = ref.watch(marketProfileProvider);
    final start = points.isNotEmpty
        ? points.first
        : here ?? LatLng(market.defaultLat, market.defaultLng);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: start,
        zoom: points.isNotEmpty ? 15 : (here != null ? 14 : 11),
      ),
      padding: EdgeInsets.only(
        top: widget.coveredTop,
        bottom: widget.coveredBottom,
      ),
      onMapCreated: (controller) {
        _controller = controller;
        _frame();
      },
      markers: {
        for (final stop in widget.stops)
          if (stop.location?.coordinates != null)
            Marker(
              markerId: MarkerId(stop.id),
              position: stop.location!.coordinates!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                stop.isPickup
                    ? BitmapDescriptor.hueAzure
                    : BitmapDescriptor.hueBlue,
              ),
            ),
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }
}
