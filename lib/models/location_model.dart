import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String?
      address; // e.g., "123 Main St" (main_text from structured_formatting)
  final String?
      formattedAddress; // e.g., "123 Main St, City, Country" (description from prediction)
  final LatLng? coordinates;
  final String? placeId; // Google Place ID

  LocationModel({
    this.address,
    this.formattedAddress,
    this.coordinates,
    this.placeId,
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
  factory LocationModel.fromPlaceDetailsResult(Map<String, dynamic> result) {
    final geometry = result['geometry']?['location'];
    LatLng? coords;
    if (geometry != null) {
      coords = LatLng(geometry['lat'], geometry['lng']);
    }
    return LocationModel(
      address: result['name'], // 'name' often has the main address part
      formattedAddress: result['formatted_address'],
      coordinates: coords,
      placeId: result['place_id'],
    );
  }

  // Factory constructor from a LatLng (e.g., when picking from map)
  factory LocationModel.fromLatLng(LatLng latLng,
      {String? address, String? formattedAddress}) {
    return LocationModel(
      address: address,
      formattedAddress: formattedAddress,
      coordinates: latLng,
    );
  }

  // To convert to JSON for your backend (as used in BookingService)
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'formattedAddress': formattedAddress,
      'latitude': coordinates?.latitude,
      'longitude': coordinates?.longitude,
      'placeId': placeId, // Include placeId if your backend uses it
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    LatLng? coords;
    // Check if latitude and longitude exist before attempting to create LatLng
    if (json['latitude'] != null && json['longitude'] != null) {
      // Cast to double as LatLng expects doubles
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
    );
  }

  // For display purposes and debugging
  @override
  String toString() {
    return 'LocationModel(address: $address, formattedAddress: $formattedAddress, coordinates: ${coordinates?.latitude}, ${coordinates?.longitude}, placeId: $placeId)';
  }
}
