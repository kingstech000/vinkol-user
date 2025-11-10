import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/location_provider.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchAndSetLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true; 
      _currentAddress = "Fetching location...";
    });

    LatLng? position = ref.read(locationControllerProvider).currentLatLng;
    position ??=
        await ref.read(locationControllerProvider).refreshCurrentLocation();

    if (!mounted) return;

    if (position != null) {
      _currentPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      };

      LocationModel? locationModel = await ref
          .read(locationControllerProvider)
          .getAddressFromLatLng(_currentPosition!);

      if (!mounted) return;

      if (locationModel != null) {
        _currentAddress = locationModel.formattedAddress ?? "Unknown Address";
      } else {
        _currentAddress = "Address not found";
      }
    } else {
      _currentPosition = const LatLng(6.3361, 5.6125);
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

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialCameraPosition = CameraPosition(
      target: _currentPosition ??
          const LatLng(6.3361, 5.6125),
      zoom: 14,
    );

    return Container(
      height: 200, 
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          _isLoading
              ? const MapShimmerPlaceholder()
              : GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  zoomControlsEnabled: false,
                  markers: _markers,
                ),

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
                          .first,
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
                          : _currentAddress,
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

class MapShimmerPlaceholder extends StatelessWidget {
  const MapShimmerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.map, size: 80, color: Colors.grey[400]),
          ),
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
