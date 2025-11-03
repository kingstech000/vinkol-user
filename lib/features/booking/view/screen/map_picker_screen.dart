// lib/screens/map_picker_screen.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/state_boundaries.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/location_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key});

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  String? _pickedAddress;
  bool _isLoadingAddress = false;
  String? _userState;
  StateBoundary? _stateBoundary;
  bool _isMapReady = false;
  bool _showingStateError = false;

  // Initial camera position with better zoom
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeMap();

    // Set up periodic boundary enforcement
    if (_stateBoundary != null) {
      Timer.periodic(const Duration(seconds: 2), (timer) {
        if (mounted) {
          _enforceStateBoundaries();
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
    _userState = user?.currentState;

    if (_userState == null || _userState!.isEmpty) {
      _setDefaultLocation();
      return;
    }

    // Get state boundary
    _stateBoundary = StateBoundaries.getBoundary(_userState!);
    if (_stateBoundary == null) {
      _setDefaultLocation();
      return;
    }

    // Access the location controller and its currentLatLng
    final locationController = ref.read(locationControllerProvider);
    final LatLng? userCurrentLocation = locationController.currentLatLng;

    // Check if user's current location is within their state
    if (userCurrentLocation != null &&
        StateBoundaries.isLocationInState(userCurrentLocation, _userState!)) {
      // User is in their state, start from current location with street-level zoom
      _initialCameraPosition = CameraPosition(
        target: userCurrentLocation,
        zoom: 17.0, // Street-level zoom to see streets clearly
      );
      _pickedLocation = userCurrentLocation;
    } else {
      // User is outside their state, start from a major city in their state
      final stateCenter = _getKnownLocationInState(_userState!);
      _initialCameraPosition = CameraPosition(
        target: stateCenter,
        zoom: 17.0, // Street-level zoom to see streets clearly
      );
      _pickedLocation = stateCenter;
    }

    // Fetch the address for initial location
    _getAddressFromLatLng(_pickedLocation!);
  }

  void _setDefaultLocation() {
    _initialCameraPosition = const CameraPosition(
      target: LatLng(6.3361, 5.6125), // Benin City default
      zoom: 17.0, // Street-level zoom
    );
    _pickedLocation = _initialCameraPosition.target;
    _getAddressFromLatLng(_pickedLocation!);
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    // Apply custom map style for better street visibility
    await controller.setMapStyle(_getStreetFocusedMapStyle());

    // If we have state boundary, set strict bounds and restrictions
    if (_stateBoundary != null) {
      // Wait a bit for map to fully initialize
      await Future.delayed(const Duration(milliseconds: 500));

      // Set strict camera bounds to prevent moving outside state
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          _stateBoundary!.bounds,
          50.0, // Minimal padding to prevent edge cases
        ),
      );

      // Then zoom to the picked location with street-level zoom
      await Future.delayed(const Duration(milliseconds: 300));
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_pickedLocation!, 17.0),
      );
    }

    setState(() {
      _isMapReady = true;
    });
  }

  String _getStreetFocusedMapStyle() {
    // Enhanced map style for better street visibility and location picking
    return '''
    [
      {
        "featureType": "administrative.country",
        "elementType": "geometry.stroke",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "administrative.province",
        "elementType": "geometry.stroke",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels",
        "stylers": [{"visibility": "on"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {"visibility": "on"},
          {"color": "#ffffff"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels",
        "stylers": [{"visibility": "on"}]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {"visibility": "on"},
          {"weight": 2}
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "geometry",
        "stylers": [
          {"visibility": "on"},
          {"weight": 1}
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.icon",
        "stylers": [{"visibility": "on"}]
      },
      {
        "featureType": "poi.business",
        "stylers": [{"visibility": "on"}]
      },
      {
        "featureType": "transit.station",
        "stylers": [{"visibility": "on"}]
      },
      {
        "featureType": "landscape.man_made",
        "stylers": [
          {"visibility": "on"},
          {"color": "#f0f0f0"}
        ]
      }
    ]
    ''';
  }

  void _onCameraMove(CameraPosition position) {
    // Only update picked location if it's within the user's state
    if (_userState != null && _stateBoundary != null) {
      if (StateBoundaries.isLocationInState(position.target, _userState!)) {
        setState(() {
          _pickedLocation = position.target;
          _showingStateError = false;
        });
      } else {
        // Location is outside state - don't update picked location
        // and show error immediately
        setState(() {
          _showingStateError = true;
        });
      }
    } else {
      // No state restriction, update normally
      setState(() {
        _pickedLocation = position.target;
        _showingStateError = false;
      });
    }
  }

  void _onCameraIdle() {
    if (_pickedLocation == null) return;

    // Strict validation: ensure location is within user's state
    if (_userState != null && _stateBoundary != null) {
      if (!StateBoundaries.isLocationInState(_pickedLocation!, _userState!)) {
        _handleLocationOutsideState();
        return;
      }
    }

    // Check if location is over water and adjust if necessary
    _checkAndAdjustWaterLocation();

    // Location is valid, get address
    _getAddressFromLatLng(_pickedLocation!);
  }

  // Additional method to continuously enforce state boundaries
  void _enforceStateBoundaries() {
    if (_pickedLocation == null || _userState == null || _stateBoundary == null)
      return;

    // Check if current picked location is outside state
    if (!StateBoundaries.isLocationInState(_pickedLocation!, _userState!)) {
      _handleLocationOutsideState();
    }
  }

  // Method to check if location is over water and adjust to nearest land
  void _checkAndAdjustWaterLocation() {
    if (_pickedLocation == null) return;

    // Check if the current location is over water
    if (_isLocationOverWater(_pickedLocation!)) {
      // Find the nearest land location
      final nearestLandLocation = _findNearestLandLocation(_pickedLocation!);

      if (nearestLandLocation != null) {
        setState(() {
          _pickedLocation = nearestLandLocation;
        });

        // Animate to the new land location
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(nearestLandLocation, 17.0),
        );

        // Show message about water avoidance
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Location adjusted to nearest land area (avoided water)',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue[600],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  // Check if a location is over water based on coordinates
  bool _isLocationOverWater(LatLng location) {
    // Define known water bodies in Nigeria with their approximate boundaries
    final waterBodies = [
      // Lagos Lagoon
      {
        'name': 'Lagos Lagoon',
        'bounds': [6.4, 3.3, 6.6, 3.5]
      },
      // Victoria Island area
      {
        'name': 'Victoria Island Water',
        'bounds': [6.42, 3.37, 6.45, 3.42]
      },
      // Port Harcourt creeks
      {
        'name': 'Port Harcourt Creeks',
        'bounds': [4.75, 6.95, 4.85, 7.05]
      },
      // Calabar River
      {
        'name': 'Calabar River',
        'bounds': [4.90, 8.30, 5.00, 8.35]
      },
      // Niger River (major sections)
      {
        'name': 'Niger River',
        'bounds': [6.0, 5.5, 6.5, 5.7]
      },
      // Benue River
      {
        'name': 'Benue River',
        'bounds': [7.0, 8.0, 7.5, 8.5]
      },
      // Lake Chad area
      {
        'name': 'Lake Chad',
        'bounds': [13.0, 13.5, 13.5, 14.0]
      },
      // Atlantic Ocean (coastal areas)
      {
        'name': 'Atlantic Coast',
        'bounds': [4.0, 5.0, 4.5, 5.5]
      },
      {
        'name': 'Atlantic Coast Lagos',
        'bounds': [6.35, 3.35, 6.45, 3.45]
      },
    ];

    for (final waterBody in waterBodies) {
      final bounds = waterBody['bounds'] as List<double>;
      if (location.latitude >= bounds[0] &&
          location.latitude <= bounds[2] &&
          location.longitude >= bounds[1] &&
          location.longitude <= bounds[3]) {
        return true;
      }
    }

    return false;
  }

  // Find the nearest land location by searching in expanding circles
  LatLng? _findNearestLandLocation(LatLng waterLocation) {
    // Search in expanding circles around the water location
    final searchRadiuses = [0.001, 0.002, 0.005, 0.01, 0.02, 0.05]; // degrees

    for (final radius in searchRadiuses) {
      // Check 8 directions around the water location
      final directions = [
        [0, 1],
        [1, 1],
        [1, 0],
        [1, -1],
        [0, -1],
        [-1, -1],
        [-1, 0],
        [-1, 1]
      ];

      for (final direction in directions) {
        final testLat = waterLocation.latitude + (direction[0] * radius);
        final testLng = waterLocation.longitude + (direction[1] * radius);
        final testLocation = LatLng(testLat, testLng);

        // Check if this location is not over water and within state boundaries
        if (!_isLocationOverWater(testLocation) &&
            (_userState == null ||
                _stateBoundary == null ||
                StateBoundaries.isLocationInState(testLocation, _userState!))) {
          return testLocation;
        }
      }
    }

    // If no land found in reasonable distance, return null
    return null;
  }

  void _handleLocationOutsideState() {
    setState(() {
      _showingStateError = true;
    });

    // Show error message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location must be within $_userState state only!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Immediately snap back to valid location
    _snapToClosestPointInState();
  }

  void _snapToClosestPointInState() {
    if (_stateBoundary == null || _mapController == null || !_isMapReady)
      return;

    // Find the closest valid point within the state
    final closestPoint =
        StateBoundaries.getClosestPointInState(_pickedLocation!, _userState!) ??
            _getKnownLocationInState(_userState!);

    // Check if the closest point is over water and adjust if necessary
    final finalPoint = _isLocationOverWater(closestPoint)
        ? _findNearestLandLocation(closestPoint) ?? closestPoint
        : closestPoint;

    setState(() {
      _pickedLocation = finalPoint;
      _showingStateError = false;
    });

    // Show success message for snapping back
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location adjusted to $_userState state boundary',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Smoothly animate back to valid location
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(finalPoint, 17.0),
    );

    _getAddressFromLatLng(finalPoint);
  }

  // Method to refresh current location during initialization
  Future<void> _refreshCurrentLocationForInitialization() async {
    try {
      final locationController = ref.read(locationControllerProvider);
      await locationController.refreshCurrentLocation();

      // If user is in their state and we have a current location, update the map
      if (_userState != null && _stateBoundary != null) {
        final currentLocation = locationController.currentLatLng;
        if (currentLocation != null &&
            StateBoundaries.isLocationInState(currentLocation, _userState!)) {
          // Check if current location is over water and adjust if necessary
          final finalLocation = _isLocationOverWater(currentLocation)
              ? _findNearestLandLocation(currentLocation) ?? currentLocation
              : currentLocation;

          setState(() {
            _pickedLocation = finalLocation;
          });

          // Update map to current location if map is ready
          if (_mapController != null && _isMapReady) {
            _mapController!.animateCamera(
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
        _showLocationError('Unable to get your current location');
        return;
      }

      // Check if current location is within user's state
      if (_userState != null && _stateBoundary != null) {
        if (!StateBoundaries.isLocationInState(currentLocation, _userState!)) {
          _showLocationError('You are currently outside $_userState state');
          return;
        }
      }

      // Check if current location is over water and adjust if necessary
      final finalLocation = _isLocationOverWater(currentLocation)
          ? _findNearestLandLocation(currentLocation) ?? currentLocation
          : currentLocation;

      // Valid location, move map there
      setState(() {
        _pickedLocation = finalLocation;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
            finalLocation, 17.0), // Street-level zoom for current location
      );

      _getAddressFromLatLng(finalLocation);
    } catch (e) {
      _showLocationError('Error getting location: ${e.toString()}');
    }
  }

  void _showLocationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
    if (_pickedLocation == null) {
      _showLocationError('Please select a location');
      return;
    }

    // Final validation: ensure location is within user's state
    if (_userState != null && _stateBoundary != null) {
      if (!StateBoundaries.isLocationInState(_pickedLocation!, _userState!)) {
        _handleLocationOutsideState();
        return;
      }
    }

    if (_pickedAddress == null || _isLoadingAddress) {
      _showLocationError('Please wait for location details to load');
      return;
    }

    // Create and return the selected location
    final selectedLocation = LocationModel.fromLatLng(
      _pickedLocation!,
      formattedAddress: _pickedAddress,
    );

    Navigator.pop(context, selectedLocation);
  }

  /// Get a known location within the specified state with better coordinates
  LatLng _getKnownLocationInState(String stateName) {
    final knownLocations = {
      'Lagos': const LatLng(6.5244, 3.3792), // Victoria Island
      'FCT': const LatLng(9.0579, 7.4951), // Central Abuja - Wuse
      'Kano': const LatLng(11.9804, 8.5214), // Kano City Center
      'Rivers': const LatLng(4.8156, 7.0498), // Port Harcourt GRA
      'Kaduna': const LatLng(10.5105, 7.4165), // Kaduna Central
      'Ondo': const LatLng(7.2571, 5.2058), // Akure Center
      'Oyo': const LatLng(7.3775, 3.9470), // Ibadan UI Area
      'Ogun': const LatLng(7.1475, 3.3619), // Abeokuta Center
      'Edo': const LatLng(6.3176, 5.6145), // Benin City Center
      'Anambra': const LatLng(6.2104, 7.0153), // Awka Center
      'Enugu': const LatLng(6.4426, 7.4898), // Enugu Independence Layout
      'Imo': const LatLng(5.4840, 7.0351), // Owerri Center
      'Abia': const LatLng(5.5320, 7.4860), // Umuahia
      'Delta': const LatLng(6.1967, 6.6963), // Asaba Center
      'Cross River': const LatLng(4.9517, 8.3220), // Calabar Center
      'Akwa Ibom': const LatLng(5.0104, 7.8584), // Uyo Center
      'Bayelsa': const LatLng(4.9247, 6.2642), // Yenagoa
      'Ebonyi': const LatLng(6.2649, 8.0137), // Abakaliki
      'Niger': const LatLng(9.6177, 6.5568), // Minna Center
      'Kogi': const LatLng(7.7973, 6.7337), // Lokoja
      'Kwara': const LatLng(8.4966, 4.5426), // Ilorin Center
      'Nasarawa': const LatLng(8.5378, 8.3206), // Lafia
      'Plateau': const LatLng(9.8965, 8.8583), // Jos Center
      'Bauchi': const LatLng(10.3158, 9.8442), // Bauchi City
      'Gombe': const LatLng(10.2891, 11.1671), // Gombe Center
      'Taraba': const LatLng(7.8708, 10.7734), // Jalingo
      'Adamawa': const LatLng(9.3275, 12.3984), // Yola Center
      'Borno': const LatLng(11.8333, 13.1500), // Maiduguri
      'Yobe': const LatLng(11.7480, 11.9660), // Damaturu
      'Jigawa': const LatLng(12.2236, 9.3477), // Dutse Center
      'Katsina': const LatLng(12.9908, 7.6018), // Katsina Center
      'Kebbi': const LatLng(12.4500, 4.1975), // Birnin Kebbi
      'Sokoto': const LatLng(13.0059, 5.2476), // Sokoto Center
      'Zamfara': const LatLng(12.1704, 6.2407), // Gusau Center
      'Osun': const LatLng(7.7500, 4.5500), // Osogbo
      'Ekiti': const LatLng(7.6219, 5.2200), // Ado Ekiti
    };

    return knownLocations[stateName] ??
        StateBoundaries.getStateCenter(stateName) ??
        const LatLng(6.3361, 5.6125);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick Location${_userState != null ? ' in $_userState' : ''}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Current location button in app bar
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.primary),
            onPressed: _getCurrentLocation,
            tooltip: 'Go to current location',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll use our custom button
            zoomControlsEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false, // Disable tilt for better experience
            zoomGesturesEnabled: true,

            // Strict camera bounds to prevent moving outside state
            cameraTargetBounds: _stateBoundary != null
                ? CameraTargetBounds(_stateBoundary!.bounds)
                : CameraTargetBounds.unbounded,

            // Restrict zoom range to prevent getting too far out
            minMaxZoomPreference: _stateBoundary != null
                ? const MinMaxZoomPreference(14.0,
                    20.0) // Street-level min zoom for better street visibility
                : const MinMaxZoomPreference(14.0, 20.0),

            mapType: MapType.normal,
            buildingsEnabled: true,
            trafficEnabled: false,
          ),

          // Center crosshair
          const Center(
            child: Icon(
              CupertinoIcons.map_pin,
              color: AppColors.primary,
              size: 40,
            ),
          ),

          // Zoom controls
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom_in",
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.zoom_in, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoom_out",
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.zoom_out, color: Colors.black87),
                ),
              ],
            ),
          ),

          // Bottom address card and confirm button
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color:
                            _showingStateError ? Colors.red : AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Selected Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Gap.h12,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: _isLoadingAddress
                        ? Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Getting address...',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          )
                        : Text(
                            _pickedAddress ?? 'Move map to pick location...',
                            style: TextStyle(
                              color: _showingStateError
                                  ? Colors.red[700]
                                  : Colors.black87,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                  ),
                  Gap.h16,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                      title: 'Confirm This Location',
                      onTap: (_isLoadingAddress ||
                              _pickedAddress == null ||
                              _showingStateError)
                          ? null
                          : _confirmLocation,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
