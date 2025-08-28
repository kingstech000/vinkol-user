import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/location_provider.dart'; // Ensure this path is correct

class MapDisplay extends ConsumerStatefulWidget {
  const MapDisplay({
    super.key,
  });

  @override
  _MapDisplayState createState() => _MapDisplayState();
}

class _MapDisplayState extends ConsumerState<MapDisplay> {
  LatLng? _currentPosition;
  String _currentAddress = "Fetching location...";
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndSetLocation();
  }

  Future<void> _fetchAndSetLocation() async {
    setState(() {
      _isLoading = true; // Show loading indicator
      _currentAddress = "Fetching location...";
    });

    LatLng? position = ref.read(locationControllerProvider).currentLatLng;

    // If currentLatLng is null (e.g., first load, permission not granted yet),
    // try to refresh it.
    position ??=
        await ref.read(locationControllerProvider).refreshCurrentLocation();

    if (position != null) {
      _currentPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      };

      // Get address from coordinates
      LocationModel? locationModel = await ref
          .read(locationControllerProvider)
          .getAddressFromLatLng(_currentPosition!);
      if (locationModel != null) {
        _currentAddress = locationModel.formattedAddress ?? "Unknown Address";
      } else {
        _currentAddress = "Address not found";
      }
    } else {
      // Handle cases where location is not available
      _currentPosition = const LatLng(6.3361, 5.6125); // Default to Benin City
      _currentAddress =
          "Location not available. Please enable location services.";
      _markers = {
        Marker(
          markerId: const MarkerId('defaultLocation'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Default Location'),
        ),
      };
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the camera position based on whether current location is available
    final CameraPosition initialCameraPosition = CameraPosition(
      target: _currentPosition ??
          const LatLng(6.3361, 5.6125), // Default to Benin City if null
      zoom: 14,
    );

    return Container(
      height: 200, // Fixed height for the map section
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300], // Placeholder color for the map
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          _isLoading
              ? const MapShimmerPlaceholder()
              : GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  zoomControlsEnabled: false,
                  markers: _markers, // Display the current location marker
                ),

          // Location name card overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentAddress
                          .split(',')
                          .first, // Get the first part of the address
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentAddress.contains(',')
                          ? _currentAddress
                              .substring(_currentAddress.indexOf(',') + 1)
                              .trim()
                          : _currentAddress, // Rest of the address or full if no comma
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Optionally, a refresh button if location is not available
          if (!_isLoading && _currentPosition == null)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchAndSetLocation,
                      child: const Text('Retry Location'),
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

// You'd create a separate widget for this
class MapShimmerPlaceholder extends StatelessWidget {
  const MapShimmerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background for the map area
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Simulated map background
          Center(
            child: Icon(Icons.map, size: 80, color: Colors.grey[400]),
          ),
          // Shimmer effect for the address card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 2,
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: double.infinity,
                        height: 14,
                        color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Container(width: 150, height: 12, color: Colors.grey[300]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
