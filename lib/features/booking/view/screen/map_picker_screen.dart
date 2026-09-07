// lib/screens/map_picker_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/utils/state_boundaries.dart';
import 'package:starter_codes/features/booking/data/map_geography.dart';
import 'package:starter_codes/features/booking/data/map_style.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/view/widget/map_picker/map_picker_boundary_mixin.dart';
import 'package:starter_codes/features/booking/view/widget/map_picker/map_picker_view.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/location_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';

class MapPickerScreen extends ConsumerStatefulWidget {
  final bool? isPickupLocation;
  final String? stopId;

  const MapPickerScreen({super.key, this.isPickupLocation, this.stopId});

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen>
    with MapPickerBoundaryMixin<MapPickerScreen> {
  String? _pickedAddress;
  bool _isLoadingAddress = false;

  // Initial camera position with better zoom
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeMap();

    // Set up periodic boundary enforcement
    if (stateBoundary != null) {
      Timer.periodic(const Duration(seconds: 2), (timer) {
        if (mounted) {
          enforceStateBoundaries();
        } else {
          timer.cancel();
        }
      });
    }

    // Refresh current location to get the most up-to-date position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCurrentLocationForInitialization();
    });
  }

  void _initializeMap() {
    // Get user's current state
    final user = ref.read(userProvider);
    userState = user?.currentState;

    if (userState == null || userState!.isEmpty) {
      _setDefaultLocation();
      return;
    }

    // Get state boundary
    stateBoundary = StateBoundaries.getBoundary(userState!);
    if (stateBoundary == null) {
      _setDefaultLocation();
      return;
    }

    // Access the location controller and its currentLatLng
    final locationController = ref.read(locationControllerProvider);
    final LatLng? userCurrentLocation = locationController.currentLatLng;

    // Check if user's current location is within their state
    if (userCurrentLocation != null &&
        StateBoundaries.isLocationInState(userCurrentLocation, userState!)) {
      // User is in their state, start from current location with street-level zoom
      _initialCameraPosition = CameraPosition(
        target: userCurrentLocation,
        zoom: 17.0, // Street-level zoom to see streets clearly
      );
      pickedLocation = userCurrentLocation;
    } else {
      // User is outside their state, start from a major city in their state
      final stateCenter = MapGeography.knownLocationInState(userState!);
      _initialCameraPosition = CameraPosition(
        target: stateCenter,
        zoom: 17.0, // Street-level zoom to see streets clearly
      );
      pickedLocation = stateCenter;
    }

    // Fetch the address for initial location
    _getAddressFromLatLng(pickedLocation!);
  }

  void _setDefaultLocation() {
    _initialCameraPosition = const CameraPosition(
      target: LatLng(6.3361, 5.6125), // Benin City default
      zoom: 17.0, // Street-level zoom
    );
    pickedLocation = _initialCameraPosition.target;
    _getAddressFromLatLng(pickedLocation!);
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    // Apply custom map style for better street visibility
    await controller.setMapStyle(kStreetFocusedMapStyle);

    // If we have state boundary, set strict bounds and restrictions
    if (stateBoundary != null) {
      // Wait a bit for map to fully initialize
      await Future.delayed(const Duration(milliseconds: 500));

      // Set strict camera bounds to prevent moving outside state
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          stateBoundary!.bounds,
          50.0, // Minimal padding to prevent edge cases
        ),
      );

      // Then zoom to the picked location with street-level zoom
      await Future.delayed(const Duration(milliseconds: 300));
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(pickedLocation!, 17.0),
      );
    }

    setState(() {
      isMapReady = true;
    });
  }

  void _onCameraMove(CameraPosition position) {
    // Only update picked location if it's within the user's state
    if (userState != null && stateBoundary != null) {
      if (StateBoundaries.isLocationInState(position.target, userState!)) {
        setState(() {
          pickedLocation = position.target;
          showingStateError = false;
        });
      } else {
        // Location is outside state - don't update picked location
        // and show error immediately
        setState(() {
          showingStateError = true;
        });
      }
    } else {
      // No state restriction, update normally
      setState(() {
        pickedLocation = position.target;
        showingStateError = false;
      });
    }
  }

  void _onCameraIdle() {
    if (pickedLocation == null) return;

    // Strict validation: ensure location is within user's state
    if (userState != null && stateBoundary != null) {
      if (!StateBoundaries.isLocationInState(pickedLocation!, userState!)) {
        handleLocationOutsideState();
        return;
      }
    }

    // Check if location is over water and adjust if necessary
    checkAndAdjustWaterLocation();

    // Location is valid, get address
    _getAddressFromLatLng(pickedLocation!);
  }

  // Additional method to continuously enforce state boundaries
  // Method to refresh current location during initialization
  Future<void> _refreshCurrentLocationForInitialization() async {
    try {
      final locationController = ref.read(locationControllerProvider);
      await locationController.refreshCurrentLocation();

      // If user is in their state and we have a current location, update the map
      if (userState != null && stateBoundary != null) {
        final currentLocation = locationController.currentLatLng;
        if (currentLocation != null &&
            StateBoundaries.isLocationInState(currentLocation, userState!)) {
          // Check if current location is over water and adjust if necessary
          final finalLocation =
              MapGeography.isLocationOverWater(currentLocation)
                  ? MapGeography.findNearestLandLocation(currentLocation,
                          userState: userState, stateBoundary: stateBoundary) ??
                      currentLocation
                  : currentLocation;

          setState(() {
            pickedLocation = finalLocation;
          });

          // Update map to current location if map is ready
          if (mapController != null && isMapReady) {
            mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(finalLocation, 17.0),
            );
            _getAddressFromLatLng(finalLocation);
          }
        }
      }
    } catch (e) {
      debugPrint('Error refreshing location during initialization: $e');
    }
  }

  // Method to get user's current location within their state
  Future<void> _getCurrentLocation() async {
    try {
      final locationController = ref.read(locationControllerProvider);

      // Try to get current location
      await locationController.refreshCurrentLocation();
      final currentLocation = locationController.currentLatLng;

      if (currentLocation == null) {
        showLocationError('Unable to get your current location');
        return;
      }

      // Check if current location is within user's state
      if (userState != null && stateBoundary != null) {
        if (!StateBoundaries.isLocationInState(currentLocation, userState!)) {
          showLocationError('You are currently outside $userState state');
          return;
        }
      }

      // Check if current location is over water and adjust if necessary
      final finalLocation = MapGeography.isLocationOverWater(currentLocation)
          ? MapGeography.findNearestLandLocation(currentLocation,
                  userState: userState, stateBoundary: stateBoundary) ??
              currentLocation
          : currentLocation;

      // Valid location, move map there
      setState(() {
        pickedLocation = finalLocation;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
            finalLocation, 17.0), // Street-level zoom for current location
      );

      _getAddressFromLatLng(finalLocation);
    } catch (e) {
      showLocationError('Error getting location: ${e.toString()}');
    }
  }

  @override
  void loadAddressFor(LatLng latLng) => _getAddressFromLatLng(latLng);

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    if (!mounted) return;

    setState(() {
      _isLoadingAddress = true;
      _pickedAddress = null;
    });

    try {
      final locationController = ref.read(locationControllerProvider);
      final location = await locationController.getAddressFromLatLng(latLng);

      if (!mounted) return;

      setState(() {
        _pickedAddress = location?.formattedAddress ?? 'Unknown location';
      });
    } catch (e) {
      debugPrint('Error getting address: $e');

      if (!mounted) return;

      setState(() {
        _pickedAddress = 'Failed to load address';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  void _confirmLocation() {
    if (pickedLocation == null) {
      showLocationError('Please select a location');
      return;
    }

    // Final validation: ensure location is within user's state
    if (userState != null && stateBoundary != null) {
      if (!StateBoundaries.isLocationInState(pickedLocation!, userState!)) {
        handleLocationOutsideState();
        return;
      }
    }

    if (_pickedAddress == null || _isLoadingAddress) {
      showLocationError('Please wait for location details to load');
      return;
    }

    // Create and return the selected location
    final selectedLocation = LocationModel.fromLatLng(
      pickedLocation!,
      formattedAddress: _pickedAddress,
    );

    // Update the ride location notifier if stopId is provided
    if (widget.stopId != null) {
      final notifier = ref.read(rideLocationProvider.notifier);
      notifier.updateStopLocation(widget.stopId!, selectedLocation);
    } else if (widget.isPickupLocation != null) {
      final notifier = ref.read(rideLocationProvider.notifier);
      if (widget.isPickupLocation!) {
        notifier.setPickUpLocation(selectedLocation);
      } else {
        notifier.setDropOffLocation(selectedLocation);
      }
    }

    Navigator.pop(context, selectedLocation);
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userProvider);

    return MapPickerView(
      userState: userState,
      stateBoundary: stateBoundary,
      initialCameraPosition: _initialCameraPosition,
      pickedAddress: _pickedAddress,
      isLoadingAddress: _isLoadingAddress,
      showingStateError: showingStateError,
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      onCurrentLocation: _getCurrentLocation,
      onZoomIn: () => mapController?.animateCamera(CameraUpdate.zoomIn()),
      onZoomOut: () => mapController?.animateCamera(CameraUpdate.zoomOut()),
      onConfirm: _confirmLocation,
    );
  }
}
