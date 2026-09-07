import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/market/market_profile.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/provider/location_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';

/// The market the *device* is operating in.
///
/// This governs input affordances only — which country address search offers,
/// how a phone number is written, where the map opens, what a region is called.
/// It never decides what an order costs: the server resolves the order's market
/// from the pickup coordinates, and the client reads that off the quote.
///
/// Resolution order:
///   1. An explicit choice the customer made, which persists.
///   2. The account's own `country`, once the profile has loaded.
///   3. The country the device's location reverse-geocodes to.
///   4. Nigeria.
///
/// The explicit choice sits at the top deliberately. Someone in Lagos testing
/// the Canadian flow, or a customer who has moved, must be able to say so and
/// be believed.
class MarketNotifier extends StateNotifier<Country> {
  MarketNotifier(this._cache) : super(_readOverride(_cache) ?? Country.ng) {
    _hasOverride = _readOverride(_cache) != null;
  }

  static const String _cacheKey = 'device_market_country';

  final LocalCache _cache;
  bool _hasOverride = false;

  /// Whether the customer chose this market themselves, rather than it being
  /// detected. A detected market may be replaced by a better signal; a chosen
  /// one may not.
  bool get isExplicit => _hasOverride;

  MarketProfile get profile => state.profile;

  static Country? _readOverride(LocalCache cache) {
    final stored = cache.getFromLocalCache(_cacheKey);
    if (stored is! String || stored.isEmpty) return null;
    return countryFromPlaceName(stored);
  }

  /// Records an explicit choice. Survives restarts until changed again.
  Future<void> selectMarket(Country country) async {
    _hasOverride = true;
    state = country;
    await _cache.saveToLocalCache(key: _cacheKey, value: country.code);
  }

  /// Offers a market detected from the account or the device's location.
  ///
  /// Ignored once the customer has chosen for themselves, and ignored for
  /// anywhere we do not operate — an unserved country should leave the market
  /// as it was rather than silently resetting it to Nigeria.
  void suggestMarket(Country? detected) {
    if (detected == null || _hasOverride) return;
    if (state != detected) state = detected;
  }

  /// Clears an explicit choice and falls back to detection again.
  Future<void> clearSelection() async {
    _hasOverride = false;
    await _cache.removeFromLocalCache(_cacheKey);
  }
}

final marketProvider = StateNotifierProvider<MarketNotifier, Country>((ref) {
  final notifier = MarketNotifier(locator<LocalCache>());
  // The account's own market is the strongest signal after an explicit choice,
  // but it only arrives once the profile loads — well after startup. Adopt it
  // whenever it does.
  ref.listen(userProvider, (_, user) => notifier.suggestMarket(user?.country));
  return notifier;
});

/// Detects the device's market from where it physically is.
///
/// Reverse-geocodes the current position and offers the result to
/// [MarketNotifier.suggestMarket], which ignores it if the customer has already
/// chosen for themselves. Safe to call more than once; safe to fail.
Future<void> detectDeviceMarket(WidgetRef ref) async {
  final notifier = ref.read(marketProvider.notifier);
  if (notifier.isExplicit) return;

  // The account's own market is the better signal when we have it.
  final accountCountry = ref.read(userProvider)?.country;
  if (accountCountry != null) {
    notifier.suggestMarket(accountCountry);
    return;
  }

  try {
    final controller = ref.read(locationControllerProvider);
    // The controller resolves its position asynchronously in its constructor,
    // so at startup the cached value is still null. Ask for a fix rather than
    // reading a value that has not arrived yet.
    final position =
        controller.currentLatLng ?? await controller.refreshCurrentLocation();
    if (position == null) return;
    final resolved = await controller.getAddressFromLatLng(position);
    notifier.suggestMarket(countryFromPlaceName(resolved?.country));
  } catch (_) {
    // Detection is a convenience. Falling back to the stored market is fine.
  }
}

/// The active market's client-side configuration.
final marketProfileProvider = Provider<MarketProfile>((ref) {
  return ref.watch(marketProvider).profile;
});
