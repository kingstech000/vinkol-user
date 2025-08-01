// lib/core/services/location_controller.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:starter_codes/models/location_model.dart'; // Ensure this path is correct

import 'package:geolocator/geolocator.dart';
import 'package:starter_codes/provider/user_provider.dart'; 
class LocationController {
  final String? BACKEND_URL;
  final String GOOGLE_MAP_API_KEY;
final Ref ref;
  LatLng? _currentLatLng; // Private field to store the user's current location

  // Public getter to access the currentLatLng from outside the class
  LatLng? get currentLatLng => _currentLatLng;

  LocationController({
    required this.GOOGLE_MAP_API_KEY,
    this.BACKEND_URL,
    required this.ref,
  }) {
    // Immediately attempt to get the user's current location when the controller is loaded
    _initializeCurrentLocation();
  }

  /// Initializes the current location by requesting permissions and fetching it.
  /// This method is called once when the controller is instantiated.
  Future<void> _initializeCurrentLocation() async {
    _currentLatLng = await _getCurrentLatLngLocation();
    if (_currentLatLng == null) {
      print('Could not get initial user location. Some features might be limited.');
      // Optionally, you could set a default location here, e.g., LatLng(0.0, 0.0)
      // or show a persistent message to the user to enable location services.
    }
  }

  Future<List<Map<String, dynamic>>> searchPlaces(
      String placeName, {LatLng? position}) async {
    List<Map<String, dynamic>> matchedLocations = [];
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json');

    // Use the provided position or fallback to the stored currentLatLng
    final LatLng effectivePosition = position ?? _currentLatLng ?? const LatLng(6.5244, 3.3792); // Default to Lagos, Nigeria if no location is available
final state = ref.watch(userProvider)!.currentState;
    final params = {
      'input': "$placeName $state state Nigeria",
      'location': '${effectivePosition.latitude},${effectivePosition.longitude}',
      'radius': '500', // Radius in meters
      'key': GOOGLE_MAP_API_KEY,
      'components': 'country:NG', // Limit results to Nigeria
    };

    try {
      final response = await http.get(url.replace(queryParameters: params));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        matchedLocations = List<Map<String, dynamic>>.from(
            data['predictions']?.map((prediction) {
                  return prediction;
                }) ??
                []);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error occurred while searching for places: $e');
    }

    return matchedLocations;
  }

  Future<LocationModel> fetchCoordinateFromPlaceId(
      LocationModel location) async {
    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/place/details/json');

    if (location.placeId == null) {
      throw Exception('Place ID is required to fetch coordinates.');
    }

    final params = {
      'place_id': location.placeId!,
      'key': GOOGLE_MAP_API_KEY,
      'fields': 'name,formatted_address,geometry,place_id', // Specify fields
    };

    try {
      final response = await http.get(url.replace(queryParameters: params));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'];

        if (result != null) {
          return LocationModel.fromPlaceDetailsResult(result);
        } else {
          throw Exception('No result found for the place ID.');
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        throw Exception('Failed to fetch place details.');
      }
    } catch (e) {
      print('Error occurred while fetching coordinates: $e');
      rethrow;
    }
  }

  // New method for reverse geocoding (to get address from LatLng picked on map)
  Future<LocationModel?> getAddressFromLatLng(LatLng latLng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$GOOGLE_MAP_API_KEY');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return LocationModel(
            formattedAddress: result['formatted_address'],
            address: result['address_components'].firstWhere(
              (component) => component['types'].contains('street_number') || component['types'].contains('route'),
              orElse: () => {'long_name': ''},
            )['long_name'], // More robust way to get a basic address component
            coordinates: latLng,
            placeId: result['place_id'],
          );
        }
      } else {
        print('Reverse geocoding failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during reverse geocoding: $e');
    }
    return null;
  }

  /// Fetches the current device location as a LatLng object.
  /// Handles permission requests and service enablement.
  /// This is a private helper method.
  Future<LatLng?> _getCurrentLatLngLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      // This case should ideally be handled by guiding the user to enable services.
      // For this implementation, we just return null.
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Current position: ${position.latitude}, ${position.longitude}');
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Public method to force a refresh of the current location.
  /// Useful if the app resumes or if the user grants permissions later.
  Future<LatLng?> refreshCurrentLocation() async {
    _currentLatLng = await _getCurrentLatLngLocation();
    return _currentLatLng;
  }
}


// Provider for your LocationController
final locationControllerProvider = Provider<LocationController>((ref) {
  // Ensure GOOGLE_MAP_API_KEY is loaded via dotenv
  final googleApiKey = dotenv.env['GOOGLE_MAP_API_KEY'] as String;
  final backendUrl = dotenv.env['BACKEND_URL'] as String; // Optional
  return LocationController(
    GOOGLE_MAP_API_KEY: googleApiKey,
    BACKEND_URL: backendUrl,
    ref:ref,
  );
});
