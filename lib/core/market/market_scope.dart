/// The resolved market, ambient.
///
/// Money formatting in this app runs through extension getters on `num` and `String`
/// (`.toMoney()`, 34 call sites) which have no `BuildContext` and no `WidgetRef`. They need
/// the active market as ambient state, the way `Intl.defaultLocale` is ambient.
///
/// **`MarketNotifier` is the only writer.** Widgets read `marketProvider` and get rebuilt;
/// the pure formatters read here. Two views of one value, never two values.
library;

import 'markets.dart';
import 'models.dart';

abstract final class MarketScope {
  static Market _market = Markets.fallback;
  static Region? _region;

  /// The active market. Defaults to Nigeria until [resolve] runs, so an app that somehow
  /// starts before resolution behaves exactly as it does today rather than crashing.
  static Market get market => _market;

  /// The active region. Falls back to the market's first region — every market ships at
  /// least one, so this never throws.
  static Region get region => _region ?? _market.regions.first;

  /// Whether a region was actually chosen, as opposed to defaulted. The market-select screen
  /// needs this; nothing that formats money does.
  static bool get hasRegion => _region != null;

  /// Sets the active market and region together. Changing market always re-resolves the
  /// region — an Ontario user does not stay in Ontario after moving to Nigeria.
  static void resolve(Market market, {Region? region}) {
    _market = market;
    _region = region != null && market.regions.contains(region) ? region : null;
  }

  /// Sets the region within the current market. Ignores a region from another market.
  static void resolveRegion(Region? region) {
    if (region == null) {
      _region = null;
      return;
    }
    if (_market.regions.contains(region)) _region = region;
  }

  /// Cache keys for the resolved selection. Codes, not names, so a display-name change does
  /// not orphan a user's choice.
  static const String marketCacheKey = 'market_country_code';
  static const String regionCacheKey = 'market_region_code';
}
