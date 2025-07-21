// lib/screens/map_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/location_provider.dart'; // Ensure this path is correct
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

  // Make this a regular field, initialized in initState
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    // Access the location controller and its currentLatLng via ref.read
    final locationController = ref.read(locationControllerProvider);
    final LatLng? userCurrentLocation = locationController.currentLatLng;

    // Set _initialCameraPosition based on currentLatLng or a default if not available
    _initialCameraPosition = CameraPosition(
      target: userCurrentLocation ?? const LatLng(6.3361, 5.6125), // Default to Benin City if current location is null
      zoom: 14.0,
    );

    // Initialize _pickedLocation with the camera's initial target
    _pickedLocation = _initialCameraPosition.target;

    // Fetch the address for this initial location
    _getAddressFromLatLng(_pickedLocation!);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Animate to the actual initial position if the map was created after init
    // This handles cases where _initialCameraPosition might have changed
    // since the map was initially rendered (e.g., if location loaded asynchronously).
    _mapController!.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
  }

  void _onCameraMove(CameraPosition position) {
    _pickedLocation = position.target;
  }

  void _onCameraIdle() {
    if (_pickedLocation != null) {
      _getAddressFromLatLng(_pickedLocation!);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    setState(() {
      _isLoadingAddress = true;
      _pickedAddress = null; // Clear previous address
    });
    try {
      final locationController = ref.read(locationControllerProvider);
      final location = await locationController.getAddressFromLatLng(latLng);
      setState(() {
        _pickedAddress = location?.formattedAddress ?? 'Unknown location';
      });
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _pickedAddress = 'Failed to load address';
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  void _confirmLocation() {
    if (_pickedLocation != null && _pickedAddress != null) { // Ensure address is also available
      final selectedLocation = LocationModel.fromLatLng(
        _pickedLocation!,
        formattedAddress: _pickedAddress,
      );
      Navigator.pop(context, selectedLocation); // Return the selected location
    } else {
      // Optionally provide user feedback if location or address isn't ready
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for location details to load.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition, // Now correctly initialized in initState
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          const Center(
            child: Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 50,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Picked Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap.h8,
                  _isLoadingAddress
                      ? const CircularProgressIndicator(
                          color: AppColors.primary)
                      : Text(
                          _pickedAddress ?? 'Moving map to pick location...',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                  Gap.h16,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                      title: 'Confirm This Location',
                      // Disable button if address is still loading or not available
                      onTap: (_isLoadingAddress || _pickedAddress == null) ? null : _confirmLocation,
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