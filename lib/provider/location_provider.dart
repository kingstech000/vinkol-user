import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:starter_codes/models/location_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:starter_codes/provider/user_provider.dart';

class LocationController {
  final String? BACKEND_URL;
  final String GOOGLE_MAP_API_KEY;
  final Ref ref;
  LatLng? _currentLatLng;

  LatLng? get currentLatLng => _currentLatLng;

  LocationController({
    required this.GOOGLE_MAP_API_KEY,
    this.BACKEND_URL,
    required this.ref,
  }) {
    _initializeCurrentLocation();
  }

  /// Initializes the current location by requesting permissions and fetching it.
  Future<void> _initializeCurrentLocation() async {
    _currentLatLng = await _getCurrentLatLngLocation();
    if (_currentLatLng == null) {
      // Optionally set a default location
    }
  }

  /// Searches for places based on input text
  Future<List<Map<String, dynamic>>> searchPlaces(String placeName,
      {LatLng? position}) async {
    List<Map<String, dynamic>> matchedLocations = [];
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json');

    final LatLng effectivePosition = position ??
        _currentLatLng ??
        const LatLng(6.5244, 3.3792); // Default to Lagos, Nigeria
    final user = ref.watch(userProvider);
    final state = user?.currentState;
    final input = placeName;
    final params = {
      'input': input,
      'key': GOOGLE_MAP_API_KEY,
      'components': 'country:NG',
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

        print(
            'Location search for: "$input" returned ${matchedLocations.length} results');
      } else {
        print('Location search failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Location search error: $e');
    }

    return matchedLocations;
  }

  /// Fetches detailed information for a place, including state and country
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
      'fields':
          'name,formatted_address,geometry,place_id,address_component', // Added address_component
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
        throw Exception('Failed to fetch place details.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reverse geocoding: Get address from LatLng picked on map
  /// Includes state and country extraction
  Future<LocationModel?> getAddressFromLatLng(LatLng latLng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$GOOGLE_MAP_API_KEY');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return LocationModel.fromReverseGeocodeResult(result, latLng);
        }
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
    return null;
  }

  /// Fetches the current device location as a LatLng object.
  /// Handles permission requests and service enablement.
  Future<LatLng?> _getCurrentLatLngLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  /// Public method to force a refresh of the current location.
  Future<LatLng?> refreshCurrentLocation() async {
    _currentLatLng = await _getCurrentLatLngLocation();
    return _currentLatLng;
  }
}

// Provider for your LocationController
final locationControllerProvider = Provider<LocationController>((ref) {
  final googleApiKey = dotenv.env['GOOGLE_MAP_API_KEY'] as String;
  final backendUrl = dotenv.env['BACKEND_URL'] as String?;
  return LocationController(
    GOOGLE_MAP_API_KEY: googleApiKey,
    BACKEND_URL: backendUrl,
    ref: ref,
  );
});
