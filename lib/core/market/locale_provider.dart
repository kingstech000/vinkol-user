/// Locale selection, owned by the market layer.
///
/// A market decides which languages exist: Nigeria ships English, Canada ships English and
/// Français. The app never offers a language its market has no copy for — falling back to
/// English in Quebec is precisely the compliance failure this layer exists to prevent.
library;

import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';

import 'market_provider.dart';
import 'market_scope.dart';

/// The language the user picked, if any. Null means "follow the market's default".
class LocaleNotifier extends StateNotifier<String?> {
  LocaleNotifier(this._ref) : super(_restore()) {
    // A market switch can strip a language: an Ontario user who chose Français and moves to
    // Nigeria has no French copy to read.
    _ref.listen(currentMarketProvider, (_, market) {
      if (!market.offersLanguage(state)) clear();
    });
  }

  final Ref _ref;

  static const String cacheKey = 'app_language_code';

  static String? _restore() {
    if (!locator.isRegistered<LocalCache>()) return null;
    try {
      final code = locator<LocalCache>().getFromLocalCache(cacheKey) as String?;
      return MarketScope.market.offersLanguage(code) ? code : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> select(String languageCode) async {
    if (!MarketScope.market.offersLanguage(languageCode)) return;
    state = languageCode;
    await _persist(languageCode);
  }

  Future<void> clear() async {
    state = null;
    await _persist(null);
  }

  Future<void> _persist(String? code) async {
    if (!locator.isRegistered<LocalCache>()) return;
    final cache = locator<LocalCache>();
    if (code == null) {
      await cache.removeFromLocalCache(cacheKey);
    } else {
      await cache.saveToLocalCache(key: cacheKey, value: code);
    }
  }
}

final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, String?>(LocaleNotifier.new);

/// The locale to hand [MaterialApp]. The user's choice when the market offers it, otherwise
/// the market's first language.
final appLocaleProvider = Provider<Locale>((ref) {
  final market = ref.watch(currentMarketProvider);
  final chosen = ref.watch(localeNotifierProvider);
  final code =
      market.offersLanguage(chosen) ? chosen! : market.languageCodes.first;
  return Locale(code, market.code);
});

/// Everything [MaterialApp] may resolve to. Constrained to the market's languages so a
/// device set to French in Nigeria still gets English, which is the only copy that market has.
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  final market = ref.watch(currentMarketProvider);
  return <Locale>[
    for (final code in market.languageCodes) Locale(code, market.code)
  ];
});
