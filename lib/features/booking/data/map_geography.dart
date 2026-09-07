import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/utils/state_boundaries.dart';

/// Static geography the location picker consults before it accepts a pin:
/// which coordinates fall on water, where the nearest land is, and a sensible
/// centre for each state when we have to fall back to one.
class MapGeography {
  const MapGeography._();

  /// Approximate bounding boxes of water bodies, as [minLat, minLng, maxLat, maxLng].
  static const List<List<double>> _waterBodies = [
    [6.4, 3.3, 6.6, 3.5], // Lagos Lagoon
    [6.42, 3.37, 6.45, 3.42], // Victoria Island water
    [4.75, 6.95, 4.85, 7.05], // Port Harcourt creeks
    [4.90, 8.30, 5.00, 8.35], // Calabar River
    [6.0, 5.5, 6.5, 5.7], // Niger River (major sections)
    [7.0, 8.0, 7.5, 8.5], // Benue River
    [13.0, 13.5, 13.5, 14.0], // Lake Chad
    [4.0, 5.0, 4.5, 5.5], // Atlantic coast
    [6.35, 3.35, 6.45, 3.45], // Atlantic coast, Lagos
  ];

  /// Distances, in degrees, searched outward when nudging a pin off water.
  static const List<double> _searchRadiuses = [
    0.001,
    0.002,
    0.005,
    0.01,
    0.02,
    0.05
  ];

  /// The eight compass directions probed at each search radius.
  static const List<List<int>> _directions = [
    [0, 1],
    [1, 1],
    [1, 0],
    [1, -1],
    [0, -1],
    [-1, -1],
    [-1, 0],
    [-1, 1],
  ];

  /// Whether [location] falls inside one of the known water bodies.
  static bool isLocationOverWater(LatLng location) {
    for (final bounds in _waterBodies) {
      if (location.latitude >= bounds[0] &&
          location.latitude <= bounds[2] &&
          location.longitude >= bounds[1] &&
          location.longitude <= bounds[3]) {
        return true;
      }
    }
    return false;
  }

  /// Searches expanding circles around [waterLocation] for the closest point
  /// that is on land and, when [userState] and [stateBoundary] are supplied,
  /// still inside that state. Returns null if nothing suitable is nearby.
  static LatLng? findNearestLandLocation(
    LatLng waterLocation, {
    String? userState,
    StateBoundary? stateBoundary,
  }) {
    for (final radius in _searchRadiuses) {
      for (final direction in _directions) {
        final testLocation = LatLng(
          waterLocation.latitude + (direction[0] * radius),
          waterLocation.longitude + (direction[1] * radius),
        );

        if (!isLocationOverWater(testLocation) &&
            (userState == null ||
                stateBoundary == null ||
                StateBoundaries.isLocationInState(testLocation, userState))) {
          return testLocation;
        }
      }
    }
    return null;
  }

  /// A recognisable point inside [stateName] — the city centre or main
  /// business district — used when we need to place the pin somewhere valid.
  static LatLng knownLocationInState(String stateName) {
    return _knownLocations[stateName] ??
        StateBoundaries.getStateCenter(stateName) ??
        const LatLng(6.3361, 5.6125);
  }

  static const Map<String, LatLng> _knownLocations = {
    'Lagos': LatLng(6.5244, 3.3792), // Victoria Island
    'FCT': LatLng(9.0579, 7.4951), // Central Abuja - Wuse
    'Kano': LatLng(11.9804, 8.5214), // Kano City Center
    'Rivers': LatLng(4.8156, 7.0498), // Port Harcourt GRA
    'Kaduna': LatLng(10.5105, 7.4165), // Kaduna Central
    'Ondo': LatLng(7.2571, 5.2058), // Akure Center
    'Oyo': LatLng(7.3775, 3.9470), // Ibadan UI Area
    'Ogun': LatLng(7.1475, 3.3619), // Abeokuta Center
    'Edo': LatLng(6.3176, 5.6145), // Benin City Center
    'Anambra': LatLng(6.2104, 7.0153), // Awka Center
    'Enugu': LatLng(6.4426, 7.4898), // Enugu Independence Layout
    'Imo': LatLng(5.4840, 7.0351), // Owerri Center
    'Abia': LatLng(5.5320, 7.4860), // Umuahia
    'Delta': LatLng(6.1967, 6.6963), // Asaba Center
    'Cross River': LatLng(4.9517, 8.3220), // Calabar Center
    'Akwa Ibom': LatLng(5.0104, 7.8584), // Uyo Center
    'Bayelsa': LatLng(4.9247, 6.2642), // Yenagoa
    'Ebonyi': LatLng(6.2649, 8.0137), // Abakaliki
    'Niger': LatLng(9.6177, 6.5568), // Minna Center
    'Kogi': LatLng(7.7973, 6.7337), // Lokoja
    'Kwara': LatLng(8.4966, 4.5426), // Ilorin Center
    'Nasarawa': LatLng(8.5378, 8.3206), // Lafia
    'Plateau': LatLng(9.8965, 8.8583), // Jos Center
    'Bauchi': LatLng(10.3158, 9.8442), // Bauchi City
    'Gombe': LatLng(10.2891, 11.1671), // Gombe Center
    'Taraba': LatLng(7.8708, 10.7734), // Jalingo
    'Adamawa': LatLng(9.3275, 12.3984), // Yola Center
    'Borno': LatLng(11.8333, 13.1500), // Maiduguri
    'Yobe': LatLng(11.7480, 11.9660), // Damaturu
    'Jigawa': LatLng(12.2236, 9.3477), // Dutse Center
    'Katsina': LatLng(12.9908, 7.6018), // Katsina Center
    'Kebbi': LatLng(12.4500, 4.1975), // Birnin Kebbi
    'Sokoto': LatLng(13.0059, 5.2476), // Sokoto Center
    'Zamfara': LatLng(12.1704, 6.2407), // Gusau Center
    'Osun': LatLng(7.7500, 4.5500), // Osogbo
    'Ekiti': LatLng(7.6219, 5.2200), // Ado Ekiti
  };
}
