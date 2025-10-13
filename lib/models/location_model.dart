import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String? address; // e.g., "123 Main St"
  final String? formattedAddress; // e.g., "123 Main St, City, Country"
  final LatLng? coordinates;
  final String? placeId; // Google Place ID
  final String? state; // e.g., "Rivers State" or "Lagos State"
  final String? country; // e.g., "Nigeria"

  LocationModel({
    this.address,
    this.formattedAddress,
    this.coordinates,
    this.placeId,
    this.state,
    this.country,
  });

  // Factory constructor for Google Place Autocomplete predictions
  factory LocationModel.fromPredictionMap(Map<String, dynamic> prediction) {
    return LocationModel(
      address: prediction['structured_formatting']?['main_text'],
      formattedAddress: prediction['description'],
      placeId: prediction['place_id'],
    );
  }

  // Factory constructor for Google Place Details results
  // This extracts state and country from the address components
  factory LocationModel.fromPlaceDetailsResult(Map<String, dynamic> result) {
    final geometry = result['geometry']?['location'];
    LatLng? coords;
    if (geometry != null) {
      coords = LatLng(geometry['lat'], geometry['lng']);
    }

    // Extract state and country from address_components
    String? extractedState;
    String? extractedCountry;

    if (result['address_components'] != null) {
      final List<dynamic> addressComponents = result['address_components'];

      for (var component in addressComponents) {
        final List<String> types = List<String>.from(component['types'] ?? []);

        // Extract administrative_area_level_1 (state/province)
        if (types.contains('administrative_area_level_1')) {
          extractedState = component['long_name'];
        }

        // Extract country
        if (types.contains('country')) {
          extractedCountry = component['long_name'];
        }
      }
    }

    return LocationModel(
      address: result['name'],
      formattedAddress: result['formatted_address'],
      coordinates: coords,
      placeId: result['place_id'],
      state: extractedState,
      country: extractedCountry,
    );
  }

  // Factory constructor for reverse geocoding results (from LatLng)
  factory LocationModel.fromReverseGeocodeResult(
      Map<String, dynamic> result, LatLng latLng) {
    String? extractedState;
    String? extractedCountry;

    if (result['address_components'] != null) {
      final List<dynamic> addressComponents = result['address_components'];

      for (var component in addressComponents) {
        final List<String> types = List<String>.from(component['types'] ?? []);

        if (types.contains('administrative_area_level_1')) {
          extractedState = component['long_name'];
        }

        if (types.contains('country')) {
          extractedCountry = component['long_name'];
        }
      }
    }

    return LocationModel(
      formattedAddress: result['formatted_address'],
      address: result['address_components'].firstWhere(
        (component) =>
            component['types'].contains('street_number') ||
            component['types'].contains('route'),
        orElse: () => {'long_name': ''},
      )['long_name'],
      coordinates: latLng,
      placeId: result['place_id'],
      state: extractedState,
      country: extractedCountry,
    );
  }

  // Factory constructor from a LatLng (e.g., when picking from map)
  factory LocationModel.fromLatLng(LatLng latLng,
      {String? address,
      String? formattedAddress,
      String? state,
      String? country}) {
    return LocationModel(
      address: address,
      formattedAddress: formattedAddress,
      coordinates: latLng,
      state: state,
      country: country,
    );
  }

  // Convert to JSON for backend
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'formattedAddress': formattedAddress,
      'latitude': coordinates?.latitude,
      'longitude': coordinates?.longitude,
      'placeId': placeId,
      'state': state,
      'country': country,
    };
  }

  // Create from JSON (from backend response)
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    LatLng? coords;
    if (json['latitude'] != null && json['longitude'] != null) {
      coords = LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      );
    }
    return LocationModel(
      address: json['address'] as String?,
      formattedAddress: json['formattedAddress'] as String?,
      coordinates: coords,
      placeId: json['placeId'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
    );
  }

  @override
  String toString() {
    return 'LocationModel(address: $address, formattedAddress: $formattedAddress, '
        'coordinates: (${coordinates?.latitude}, ${coordinates?.longitude}), '
        'placeId: $placeId, state: $state, country: $country)';
  }
}
