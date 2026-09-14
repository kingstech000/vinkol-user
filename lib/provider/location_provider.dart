import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:starter_codes/models/location_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:starter_codes/provider/market_provider.dart';

/// How far around the customer to prefer search results, in metres — roughly a
/// metropolitan area. A bias, not a boundary: a match outside it still appears,
/// it just ranks below the nearby ones.
const int _searchBiasRadiusMetres = 50000;

class LocationController {
  final String? BACKEND_URL;
  final String GOOGLE_MAP_API_KEY;
  final Ref ref;
  LatLng? _currentLatLng;

  /// The fix currently being resolved, if any. Geolocator rejects a second
  /// permission request while one is still open, so every caller joins the
  /// request already in flight instead of starting a competing one.
  Future<LatLng?>? _pendingFix;

  LatLng? get currentLatLng => _currentLatLng;

  LocationController({
    required this.GOOGLE_MAP_API_KEY,
    this.BACKEND_URL,
    required this.ref,
  }) {
    // Deliberately not awaited: callers that need the fix call
    // refreshCurrentLocation(), which joins this same request.
    refreshCurrentLocation();
  }

  /// Searches for places anywhere in the world.
  ///
  /// Deliberately unfiltered by country. The customer is the one who knows
  /// where they are: they may be booking a pickup in a market we have not
  /// launched in, or telling us where they are moving to, and a country filter
  /// makes such an address simply unfindable with no way to say so.
  ///
  /// [position] *biases* the ranking rather than restricting it — matches near
  /// the customer come first, and everywhere else still appears below them.
  /// `strictbounds` is deliberately not sent, since that is what would turn the
  /// bias back into a filter.
  Future<List<Map<String, dynamic>>> searchPlaces(
    String placeName, {
    LatLng? position,
  }) async {
    List<Map<String, dynamic>> matchedLocations = [];
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json');

    final profile = ref.read(marketProfileProvider);
    final LatLng effectivePosition = position ??
        _currentLatLng ??
        LatLng(profile.defaultLat, profile.defaultLng);
    final input = placeName;
    final params = {
      'input': input,
      'key': GOOGLE_MAP_API_KEY,
      'location':
          '${effectivePosition.latitude},${effectivePosition.longitude}',
      'radius': '$_searchBiasRadiusMetres',
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
          final detailedLocation = LocationModel.fromPlaceDetailsResult(result);
          return detailedLocation.copyWith(
            formattedAddress: location.formattedAddress ?? detailedLocation.formattedAddress,
          );
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

    try {
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

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      // A denied permission, a timeout or a request that raced another one all
      // mean the same thing to callers: no fix.
      return null;
    }
  }

  /// Resolves the current location, joining the request already in flight if
  /// there is one. Never throws — an unavailable fix comes back as null.
  Future<LatLng?> refreshCurrentLocation() {
    return _pendingFix ??= _getCurrentLatLngLocation().then((latLng) {
      _currentLatLng = latLng;
      return latLng;
    }).whenComplete(() {
      _pendingFix = null;
    });
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
