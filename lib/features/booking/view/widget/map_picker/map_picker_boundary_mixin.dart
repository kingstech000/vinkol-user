import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/utils/state_boundaries.dart';
import 'package:starter_codes/features/booking/data/map_geography.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

/// Keeps a picked map location inside the user's state and off water.
///
/// The host screen owns the map and the address lookup; this mixin owns the
/// pin's validity — it detects a pin that has drifted out of the state or onto
/// water, tells the user, and snaps the camera back to somewhere valid.
mixin MapPickerBoundaryMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  GoogleMapController? mapController;
  LatLng? pickedLocation;
  String? userState;
  StateBoundary? stateBoundary;
  bool isMapReady = false;
  bool showingStateError = false;

  /// Called once the pin has settled on a valid point, so the host can
  /// reverse-geocode it.
  void loadAddressFor(LatLng latLng);

  void enforceStateBoundaries() {
    if (pickedLocation == null || userState == null || stateBoundary == null) {
      return;
    }

    // Check if current picked location is outside state
    if (!StateBoundaries.isLocationInState(pickedLocation!, userState!)) {
      handleLocationOutsideState();
    }
  }

  /// Nudges the pin to the nearest land if it has landed on water.
  void checkAndAdjustWaterLocation() {
    if (pickedLocation == null) return;

    if (!MapGeography.isLocationOverWater(pickedLocation!)) return;

    final nearestLandLocation = MapGeography.findNearestLandLocation(
      pickedLocation!,
      userState: userState,
      stateBoundary: stateBoundary,
    );
    if (nearestLandLocation == null) return;

    setState(() {
      pickedLocation = nearestLandLocation;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(nearestLandLocation, 17.0),
    );

    if (mounted) {
      AppStatusDialogs.showSuccess(
        context,
        'Location Adjusted',
        'Location adjusted to nearest land area (avoided water)',
      );
    }
  }

  void handleLocationOutsideState() {
    setState(() {
      showingStateError = true;
    });

    if (mounted) {
      AppStatusDialogs.showError(
        context,
        'Location Error',
        'Location must be within $userState state only!',
      );
    }

    // Immediately snap back to valid location
    snapToClosestPointInState();
  }

  void snapToClosestPointInState() {
    if (stateBoundary == null || mapController == null || !isMapReady) {
      return;
    }

    final closestPoint =
        StateBoundaries.getClosestPointInState(pickedLocation!, userState!) ??
            MapGeography.knownLocationInState(userState!);

    // Check if the closest point is over water and adjust if necessary
    final finalPoint = MapGeography.isLocationOverWater(closestPoint)
        ? MapGeography.findNearestLandLocation(
              closestPoint,
              userState: userState,
              stateBoundary: stateBoundary,
            ) ??
            closestPoint
        : closestPoint;

    setState(() {
      pickedLocation = finalPoint;
      showingStateError = false;
    });

    if (mounted) {
      AppStatusDialogs.showSuccess(
        context,
        'Location Adjusted',
        'Location adjusted to $userState state boundary',
      );
    }

    mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(finalPoint, 17.0),
    );

    loadAddressFor(finalPoint);
  }

  void showLocationError(String message) {
    if (mounted) {
      AppStatusDialogs.showError(
        context,
        'Location Error',
        message,
      );
    }
  }
}
