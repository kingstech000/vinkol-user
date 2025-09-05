import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Defines precise boundaries for Nigerian states
/// These boundaries are more accurate and should properly contain locations within each state
class StateBoundaries {
  static const Map<String, StateBoundary> boundaries = {
    'FCT': StateBoundary(
      southwest: LatLng(8.2, 6.7),
      northeast: LatLng(9.5, 8.0),
    ),
    'Abia': StateBoundary(
      southwest: LatLng(4.7, 7.0),
      northeast: LatLng(6.0, 8.2),
    ),
    'Adamawa': StateBoundary(
      southwest: LatLng(7.8, 11.2),
      northeast: LatLng(10.8, 14.2),
    ),
    'Akwa Ibom': StateBoundary(
      southwest: LatLng(4.3, 7.3),
      northeast: LatLng(5.8, 8.8),
    ),
    'Anambra': StateBoundary(
      southwest: LatLng(5.6, 6.3),
      northeast: LatLng(7.0, 7.8),
    ),
    'Bauchi': StateBoundary(
      southwest: LatLng(9.2, 8.2),
      northeast: LatLng(12.2, 11.8),
    ),
    'Bayelsa': StateBoundary(
      southwest: LatLng(3.8, 5.2),
      northeast: LatLng(5.2, 6.8),
    ),
    'Benue': StateBoundary(
      southwest: LatLng(6.2, 7.2),
      northeast: LatLng(8.8, 9.8),
    ),
    'Borno': StateBoundary(
      southwest: LatLng(9.8, 10.8),
      northeast: LatLng(13.8, 14.8),
    ),
    'Cross River': StateBoundary(
      southwest: LatLng(4.2, 7.2),
      northeast: LatLng(6.8, 9.8),
    ),
    'Delta': StateBoundary(
      southwest: LatLng(4.8, 5.2),
      northeast: LatLng(6.8, 6.8),
    ),
    'Ebonyi': StateBoundary(
      southwest: LatLng(5.6, 7.2),
      northeast: LatLng(7.0, 8.8),
    ),
    'Edo': StateBoundary(
      southwest: LatLng(5.2, 5.2),
      northeast: LatLng(7.8, 7.8),
    ),
    'Ekiti': StateBoundary(
      southwest: LatLng(6.8, 4.2),
      northeast: LatLng(8.2, 5.8),
    ),
    'Enugu': StateBoundary(
      southwest: LatLng(5.8, 6.2),
      northeast: LatLng(7.2, 7.8),
    ),
    'Gombe': StateBoundary(
      southwest: LatLng(9.2, 10.2),
      northeast: LatLng(11.2, 12.2),
    ),
    'Imo': StateBoundary(
      southwest: LatLng(4.8, 6.2),
      northeast: LatLng(6.2, 7.8),
    ),
    'Jigawa': StateBoundary(
      southwest: LatLng(10.8, 7.2),
      northeast: LatLng(13.2, 9.8),
    ),
    'Kaduna': StateBoundary(
      southwest: LatLng(9.2, 6.2),
      northeast: LatLng(11.8, 8.8),
    ),
    'Kano': StateBoundary(
      southwest: LatLng(10.2, 7.2),
      northeast: LatLng(12.8, 9.8),
    ),
    'Katsina': StateBoundary(
      southwest: LatLng(11.2, 6.2),
      northeast: LatLng(13.8, 8.8),
    ),
    'Kebbi': StateBoundary(
      southwest: LatLng(10.2, 3.2),
      northeast: LatLng(12.8, 5.8),
    ),
    'Kogi': StateBoundary(
      southwest: LatLng(6.8, 5.2),
      northeast: LatLng(8.8, 7.8),
    ),
    'Kwara': StateBoundary(
      southwest: LatLng(7.2, 3.2),
      northeast: LatLng(9.8, 5.8),
    ),
    'Lagos': StateBoundary(
      southwest: LatLng(5.8, 2.2),
      northeast: LatLng(7.2, 4.8),
    ),
    'Nasarawa': StateBoundary(
      southwest: LatLng(7.2, 7.2),
      northeast: LatLng(9.2, 9.2),
    ),
    'Niger': StateBoundary(
      southwest: LatLng(8.2, 4.2),
      northeast: LatLng(11.2, 7.2),
    ),
    'Ogun': StateBoundary(
      southwest: LatLng(5.8, 2.2),
      northeast: LatLng(7.8, 4.8),
    ),
    'Ondo': StateBoundary(
      southwest: LatLng(5.8, 4.2),
      northeast: LatLng(7.8, 6.8),
    ),
    'Osun': StateBoundary(
      southwest: LatLng(6.2, 3.2),
      northeast: LatLng(8.2, 5.8),
    ),
    'Oyo': StateBoundary(
      southwest: LatLng(6.2, 2.2),
      northeast: LatLng(8.8, 4.8),
    ),
    'Plateau': StateBoundary(
      southwest: LatLng(8.2, 8.2),
      northeast: LatLng(10.2, 10.2),
    ),
    'Rivers': StateBoundary(
      southwest: LatLng(3.8, 6.2),
      northeast: LatLng(5.8, 7.8),
    ),
    'Sokoto': StateBoundary(
      southwest: LatLng(11.2, 3.2),
      northeast: LatLng(13.8, 5.8),
    ),
    'Taraba': StateBoundary(
      southwest: LatLng(6.2, 9.2),
      northeast: LatLng(9.2, 12.2),
    ),
    'Yobe': StateBoundary(
      southwest: LatLng(10.2, 9.8),
      northeast: LatLng(13.2, 12.8),
    ),
    'Zamfara': StateBoundary(
      southwest: LatLng(10.2, 4.2),
      northeast: LatLng(12.8, 6.8),
    ),
  };

  /// Get the boundary for a specific state
  static StateBoundary? getBoundary(String stateName) {
    if (stateName.isEmpty) return null;

    // Try exact match first
    if (boundaries.containsKey(stateName)) {
      return boundaries[stateName];
    }

    // Try partial match (e.g., "Lagos" matches "Lagos")
    for (String key in boundaries.keys) {
      if (key.toLowerCase().contains(stateName.toLowerCase()) ||
          stateName.toLowerCase().contains(key.toLowerCase())) {
        return boundaries[key];
      }
    }

    // Try common abbreviations and variations
    final abbreviations = {
      'Abuja FCT': 'FCT',
      'Abuja': 'FCT',
      'AK': 'Akwa Ibom',
      'AN': 'Anambra',
      'BA': 'Bauchi',
      'BY': 'Bayelsa',
      'BE': 'Benue',
      'BO': 'Borno',
      'CR': 'Cross River',
      'DE': 'Delta',
      'EB': 'Ebonyi',
      'ED': 'Edo',
      'EK': 'Ekiti',
      'EN': 'Enugu',
      'GO': 'Gombe',
      'IM': 'Imo',
      'JI': 'Jigawa',
      'KD': 'Kaduna',
      'KN': 'Kano',
      'KT': 'Katsina',
      'KB': 'Kebbi',
      'KG': 'Kogi',
      'KW': 'Kwara',
      'LA': 'Lagos',
      'NA': 'Nasarawa',
      'NI': 'Niger',
      'OG': 'Ogun',
      'ON': 'Ondo',
      'OS': 'Osun',
      'OY': 'Oyo',
      'PL': 'Plateau',
      'RI': 'Rivers',
      'SO': 'Sokoto',
      'TA': 'Taraba',
      'YO': 'Yobe',
      'ZA': 'Zamfara',
    };

    if (abbreviations.containsKey(stateName)) {
      return boundaries[abbreviations[stateName]!];
    }

    return null;
  }

  /// Check if a location is within a specific state boundary
  /// Uses more precise boundary checking
  static bool isLocationInState(LatLng location, String stateName) {
    final boundary = getBoundary(stateName);
    if (boundary == null) return false;

    // More precise boundary checking with small buffer
    const double buffer = 0.01; // Small buffer for precision

    return location.latitude >= (boundary.southwest.latitude - buffer) &&
        location.latitude <= (boundary.northeast.latitude + buffer) &&
        location.longitude >= (boundary.southwest.longitude - buffer) &&
        location.longitude <= (boundary.northeast.longitude + buffer);
  }

  /// Get the center point of a state
  static LatLng? getStateCenter(String stateName) {
    final boundary = getBoundary(stateName);
    if (boundary == null) return null;

    return LatLng(
      (boundary.southwest.latitude + boundary.northeast.latitude) / 2,
      (boundary.southwest.longitude + boundary.northeast.longitude) / 2,
    );
  }

  /// Get a camera position that shows the entire state with optimal zoom
  static CameraPosition? getStateCameraPosition(String stateName) {
    final boundary = getBoundary(stateName);
    if (boundary == null) return null;

    final center = getStateCenter(stateName);
    if (center == null) return null;

    // Calculate appropriate zoom level based on state size
    final latDiff = boundary.northeast.latitude - boundary.southwest.latitude;
    final lngDiff = boundary.northeast.longitude - boundary.southwest.longitude;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // More precise zoom calculation for better state visibility
    double zoom = 9.0; // Default zoom
    if (maxDiff > 3.0) zoom = 6.0;
    if (maxDiff > 2.0) zoom = 7.0;
    if (maxDiff > 1.5) zoom = 8.0;
    if (maxDiff < 1.0) zoom = 10.0;
    if (maxDiff < 0.8) zoom = 11.0;
    if (maxDiff < 0.5) zoom = 12.0;

    return CameraPosition(
      target: center,
      zoom: zoom,
    );
  }

  /// Get a camera position focused on a specific location within the state
  static CameraPosition? getLocationCameraPosition(
      String stateName, LatLng location) {
    final boundary = getBoundary(stateName);
    if (boundary == null) return null;

    // Check if location is within state
    if (!isLocationInState(location, stateName)) {
      // If not in state, use state center
      return getStateCameraPosition(stateName);
    }

    // Use the specific location with appropriate zoom
    return CameraPosition(
      target: location,
      zoom: 15.0, // Close zoom for specific location
    );
  }

  /// Get all available state names
  static List<String> getAvailableStates() {
    return boundaries.keys.toList();
  }

  /// Validate if a state name is supported
  static bool isStateSupported(String stateName) {
    return getBoundary(stateName) != null;
  }

  /// Get the closest point within a state boundary to a given location
  static LatLng? getClosestPointInState(LatLng location, String stateName) {
    final boundary = getBoundary(stateName);
    if (boundary == null) return null;

    // If already in state, return the location
    if (isLocationInState(location, stateName)) {
      return location;
    }

    // Find the closest point within the boundary
    double lat = location.latitude;
    double lng = location.longitude;

    // Clamp latitude to state bounds
    if (lat < boundary.southwest.latitude) lat = boundary.southwest.latitude;
    if (lat > boundary.northeast.latitude) lat = boundary.northeast.latitude;

    // Clamp longitude to state bounds
    if (lng < boundary.southwest.longitude) lng = boundary.southwest.longitude;
    if (lng > boundary.northeast.longitude) lng = boundary.northeast.longitude;

    return LatLng(lat, lng);
  }
}

/// Represents the boundary of a state with southwest and northeast coordinates
class StateBoundary {
  final LatLng southwest;
  final LatLng northeast;

  const StateBoundary({
    required this.southwest,
    required this.northeast,
  });

  /// Get the bounds as a LatLngBounds object for Google Maps
  LatLngBounds get bounds => LatLngBounds(
        southwest: southwest,
        northeast: northeast,
      );

  /// Get the center point of this boundary
  LatLng get center => LatLng(
        (southwest.latitude + northeast.latitude) / 2,
        (southwest.longitude + northeast.longitude) / 2,
      );

  /// Get the width and height of the boundary in degrees
  double get width => (northeast.longitude - southwest.longitude).abs();
  double get height => (northeast.latitude - southwest.latitude).abs();

  /// Check if a location is within this specific boundary
  bool contains(LatLng location) {
    return location.latitude >= southwest.latitude &&
        location.latitude <= northeast.latitude &&
        location.longitude >= southwest.longitude &&
        location.longitude <= northeast.longitude;
  }
}
