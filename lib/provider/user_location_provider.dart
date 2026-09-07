import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/market/market_profile.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/market_provider.dart';

/// Where the customer says they are.
///
/// Set once on the location screen, either from a Places search or from the
/// device's GPS, and persisted. This is the primary source of truth for the
/// customer's own location: it seeds the market, the map's starting point and
/// the default pickup.
///
/// It is not the same thing as an order's market. An order is priced from its
/// pickup coordinates by the server, so booking a Toronto pickup gives a
/// Canadian order regardless of what is stored here.
class UserLocationNotifier extends StateNotifier<LocationModel?> {
  UserLocationNotifier(this._cache, this._ref) : super(_read(_cache));

  static const String _cacheKey = 'user_current_location';

  final LocalCache _cache;
  final Ref _ref;

  static LocationModel? _read(LocalCache cache) {
    final stored = cache.getFromLocalCache(_cacheKey);
    if (stored is! String || stored.isEmpty) return null;
    try {
      return LocationModel.fromJson(
          jsonDecode(stored) as Map<String, dynamic>);
    } catch (_) {
      // A cache written by an older build. Ask again rather than guess.
      return null;
    }
  }

  /// Whether the customer has told us where they are yet.
  bool get hasLocation => state != null;

  /// Records the location and adopts the market it sits in.
  ///
  /// The market is set as an explicit choice, not a suggestion: the customer
  /// picked this place, so nothing detected later should quietly override it.
  Future<void> setLocation(LocationModel location) async {
    state = location;
    await _cache.saveToLocalCache(
      key: _cacheKey,
      value: jsonEncode(location.toJson()),
    );

    final country = countryFromPlaceName(location.country);
    if (country != null) {
      await _ref.read(marketProvider.notifier).selectMarket(country);
    }
  }

  Future<void> clear() async {
    state = null;
    await _cache.removeFromLocalCache(_cacheKey);
  }
}

final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, LocationModel?>((ref) {
  return UserLocationNotifier(locator<LocalCache>(), ref);
});

/// Whether the location screen still needs to be shown.
bool hasStoredUserLocation() {
  final stored = locator<LocalCache>()
      .getFromLocalCache(UserLocationNotifier._cacheKey);
  return stored is String && stored.isNotEmpty;
}
