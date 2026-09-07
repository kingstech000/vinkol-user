/// Riverpod access to the market layer, and the startup resolution.
///
/// [MarketNotifier] is the single writer for [MarketScope]: everything that changes the
/// active market goes through here, so the reactive view (widgets) and the ambient view (the
/// money formatters) cannot drift apart.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';

import 'market_scope.dart';
import 'markets.dart';
import 'models.dart';

@immutable
class MarketState {
  const MarketState({required this.market, required this.region});

  final Market market;
  final Region region;

  String get regionLabel => market.regionLabel;
}

class MarketNotifier extends StateNotifier<MarketState> {
  MarketNotifier()
      : super(MarketState(
          market: MarketScope.market,
          region: MarketScope.region,
        ));

  /// Switches market. The region always re-resolves — a province is not a state.
  Future<void> setMarket(Market market, {Region? region}) async {
    MarketScope.resolve(market, region: region);
    state = MarketState(market: MarketScope.market, region: MarketScope.region);
    await _persist();
  }

  Future<void> setRegion(Region region) async {
    MarketScope.resolveRegion(region);
    state = MarketState(market: MarketScope.market, region: MarketScope.region);
    await _persist();
  }

  /// Sets the region from the name the API stores on the user (`User.state`). A no-op when
  /// the name is not one of this market's regions — an unknown region is a data problem, and
  /// silently defaulting it would quietly tax the wrong province.
  Future<void> setRegionByName(String? name) async {
    final region = state.market.regionByName(name);
    if (region == null) return;
    await setRegion(region);
  }

  Future<void> _persist() async {
    if (!locator.isRegistered<LocalCache>()) return;
    final cache = locator<LocalCache>();
    await cache.saveToLocalCache(
      key: MarketScope.marketCacheKey,
      value: state.market.code,
    );
    await cache.saveToLocalCache(
      key: MarketScope.regionCacheKey,
      value: state.region.code,
    );
  }
}

/// The active market. Read this in widgets; the money formatters read [MarketScope].
final marketProvider = StateNotifierProvider<MarketNotifier, MarketState>(
  (ref) => MarketNotifier(),
);

/// Convenience reads, so a widget that needs one field does not depend on all of them.
final currentMarketProvider =
    Provider<Market>((ref) => ref.watch(marketProvider).market);

final currentRegionProvider =
    Provider<Region>((ref) => ref.watch(marketProvider).region);

/// The administrative regions of the active market, for a picker. Replaces the
/// `nigerianStates` constant that used to be imported directly by two screens.
final marketRegionsProvider =
    Provider<List<Region>>((ref) => ref.watch(currentMarketProvider).regions);

/// Resolves the market **once, before the first frame**, from the last persisted choice.
///
/// Called from `main()`. Falls back to Nigeria — the live market — on a cold install or any
/// cache failure, so a user who has never chosen sees exactly today's app.
Future<void> resolveMarketAtStartup() async {
  if (!locator.isRegistered<LocalCache>()) {
    MarketScope.resolve(Markets.fallback);
    return;
  }
  try {
    final cache = locator<LocalCache>();
    final market = Markets.resolve(
        cache.getFromLocalCache(MarketScope.marketCacheKey) as String?);
    final region = market.regionByCode(
        cache.getFromLocalCache(MarketScope.regionCacheKey) as String?);
    MarketScope.resolve(market, region: region);
  } catch (_) {
    MarketScope.resolve(Markets.fallback);
  }
}
