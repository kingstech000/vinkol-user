import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReverseLocationStringMap extends ConsumerStatefulWidget {
  final String? pickupLocationString;
  final String? dropoffLocationString;

  const ReverseLocationStringMap({
    super.key,
    required this.pickupLocationString,
    required this.dropoffLocationString,
  });

  @override
  ConsumerState<ReverseLocationStringMap> createState() =>
      _ReverseLocationStringMapState();
}

class _ReverseLocationStringMapState
    extends ConsumerState<ReverseLocationStringMap> {
  LatLng? _pickupCoordinates;
  LatLng? _dropoffCoordinates;
  final Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;
  late String googleApiKey;

  @override
  void initState() {
    super.initState();
    googleApiKey = dotenv.env['GOOGLE_MAP_API_KEY']!;
    _parseAndDrawRoute();
  }

  @override
  void didUpdateWidget(covariant ReverseLocationStringMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pickupLocationString != oldWidget.pickupLocationString ||
        widget.dropoffLocationString != oldWidget.dropoffLocationString) {
      _parseAndDrawRoute();
    }
  }

  Future<void> _parseAndDrawRoute() async {
    _polylines.clear();
    LatLng? newPickupCoordinates;
    LatLng? newDropoffCoordinates;

    if (widget.pickupLocationString != null &&
        widget.pickupLocationString!.isNotEmpty) {
      newPickupCoordinates =
          await _getCoordinatesFromAddress(widget.pickupLocationString!);
    }

    if (widget.dropoffLocationString != null &&
        widget.dropoffLocationString!.isNotEmpty) {
      newDropoffCoordinates =
          await _getCoordinatesFromAddress(widget.dropoffLocationString!);
    }

    if (!mounted) return;

    if (newPickupCoordinates != _pickupCoordinates ||
        newDropoffCoordinates != _dropoffCoordinates) {
      setState(() {
        _pickupCoordinates = newPickupCoordinates;
        _dropoffCoordinates = newDropoffCoordinates;
      });
    }

    LatLng? cameraTarget;
    if (_pickupCoordinates != null) {
      cameraTarget = _pickupCoordinates;
    } else if (_dropoffCoordinates != null) {
      cameraTarget = _dropoffCoordinates;
    }

    if (_mapController != null && cameraTarget != null) {
      if (!mounted) return;
      _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(cameraTarget, 14));
    }

    if (_pickupCoordinates != null && _dropoffCoordinates != null) {
      final pickupPoint = PointLatLng(
          _pickupCoordinates!.latitude, _pickupCoordinates!.longitude);
      final dropoffPoint = PointLatLng(
          _dropoffCoordinates!.latitude, _dropoffCoordinates!.longitude);

      final polylineCoordinates = await createPolyline(
        pickup: pickupPoint,
        dropOff: dropoffPoint,
      );

      if (!mounted) return;

      if (polylineCoordinates.isNotEmpty) {
        setState(() {
          addPolyline(
            polylines: _polylines,
            polylineCoordinates: polylineCoordinates,
          );
        });
        _zoomToFitRoute(polylineCoordinates);
      }
    } else {
      if (_polylines.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _polylines.clear();
        });
      }
    }
  }

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      debugPrint('Error geocoding address "$address": $e');
    }
    return null;
  }

  void _zoomToFitRoute(List<LatLng> polylineCoordinates) {
    if (_mapController != null && polylineCoordinates.isNotEmpty) {
      if (!mounted) return;

      double minLat = polylineCoordinates.first.latitude;
      double minLng = polylineCoordinates.first.longitude;
      double maxLat = polylineCoordinates.first.latitude;
      double maxLng = polylineCoordinates.first.longitude;

      for (var point in polylineCoordinates) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          50.w, // Padding
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final LatLng initialTarget = _pickupCoordinates ??
        _dropoffCoordinates ??
        const LatLng(6.5244, 3.3792);
    final double initialZoom =
        (_pickupCoordinates != null && _dropoffCoordinates != null) ? 12 : 14;


    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: initialZoom,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _parseAndDrawRoute();
          },
          polylines: _polylines,
          markers: {
            if (_pickupCoordinates != null)
              Marker(
                markerId: const MarkerId('pickupLocation'),
                position: _pickupCoordinates!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
                infoWindow: InfoWindow(title: widget.pickupLocationString),
              ),
            if (_dropoffCoordinates != null)
              Marker(
                markerId: const MarkerId('dropoffLocation'),
                position: _dropoffCoordinates!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                infoWindow: InfoWindow(title: widget.dropoffLocationString),
              ),
          },
        ),
        // Google Maps Directions Button
      
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose(); // Dispose of the map controller
    super.dispose();
  }
}
