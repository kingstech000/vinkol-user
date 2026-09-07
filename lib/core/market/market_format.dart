/// The one place money, distances and tax become strings.
///
/// Every rule here exists because a symbol swap is not a market layer:
///   - the symbol may prefix *or* suffix, so nothing concatenates it by hand;
///   - the decimal count is per currency (NGN 0, CAD 2), never hardcoded;
///   - grouping comes from the market's locale, not `en_US`;
///   - tax is resolved from the **region**, and is absent entirely in a market that does not
///     display one.
library;

import 'package:intl/intl.dart';

import 'market_scope.dart';
import 'models.dart';

abstract final class MarketFormat {
  /// `NumberFormat` construction is not cheap and this runs in list builders. Keyed by
  /// locale and decimal count, which is everything that varies.
  static final Map<String, NumberFormat> _cache = <String, NumberFormat>{};

  static NumberFormat _number(String locale, int decimalDigits) =>
      _cache['$locale/$decimalDigits'] ??= NumberFormat.decimalPatternDigits(
        locale: locale,
        decimalDigits: decimalDigits,
      );

  /// The grouped number, with no symbol.
  static String amount(num value, {int? decimalDigits}) {
    final market = MarketScope.market;
    return _number(
      market.locale,
      decimalDigits ?? market.currency.decimalDigits,
    ).format(value);
  }

  /// Money, with the symbol placed where the market puts it.
  ///
  /// Pass [decimalDigits] only to pin a precision the market would not choose — the two
  /// legacy "with decimals" formatters do, to keep their output byte-identical.
  static String money(num value, {int? decimalDigits}) {
    final currency = MarketScope.market.currency;
    final formatted = amount(value, decimalDigits: decimalDigits);
    return currency.position == SymbolPosition.prefix
        ? '${currency.symbol}$formatted'
        : '$formatted${currency.symbol}';
  }

  /// Money at the currency's full precision, never fewer than 2 places.
  ///
  /// This is the "exact amount" register — wallet balances, transaction detail. It is pinned
  /// rather than market-derived so Nigeria keeps rendering `₦1,234.50` exactly as it does
  /// today, and it is already correct for 2-decimal currencies.
  static String moneyPrecise(num value) => money(
        value,
        decimalDigits: MarketScope.market.currency.decimalDigits > 2
            ? MarketScope.market.currency.decimalDigits
            : 2,
      );

  /// The bare currency symbol, for an input's prefix. Callers must not assume it is one glyph
  /// or that it goes in front — check [symbolIsPrefix].
  static String get symbol => MarketScope.market.currency.symbol;

  static bool get symbolIsPrefix =>
      MarketScope.market.currency.position == SymbolPosition.prefix;

  /// The market's group and decimal separators, taken from its locale rather than assumed.
  static String get groupSeparator =>
      _number(MarketScope.market.locale, 0).symbols.GROUP_SEP;

  static String get decimalSeparator =>
      _number(MarketScope.market.locale, 0).symbols.DECIMAL_SEP;

  /// Parses a string the user typed or that [amount] produced, back to a number. Strips the
  /// market's grouping and normalises its decimal separator; returns 0 for anything else.
  static double parse(String text) {
    if (text.trim().isEmpty) return 0;
    final cleaned = text
        .replaceAll(MarketScope.market.currency.symbol, '')
        .replaceAll(groupSeparator, '')
        .replaceAll(decimalSeparator, '.')
        .replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  /// A formatted distance. Never concatenated — the unit is market config.
  static String distance(num value) =>
      '${amount(value, decimalDigits: value % 1 == 0 ? 0 : 1)} '
      '${MarketScope.market.distanceUnit.suffix}';

  /// The tax on a subtotal, or **null in a market that does not display tax separately**.
  ///
  /// Nigeria returns null here, which is why no Nigerian screen grows a tax row. The rate
  /// comes from the active region, because Ontario and Alberta are the same country at
  /// different rates.
  ///
  /// This computes a *display* figure. The quote endpoint is expected to return the
  /// authoritative amount (D-09); prefer the server's number whenever there is one.
  static TaxLine? tax(num subtotal) {
    final market = MarketScope.market;
    if (!market.showTax) return null;
    final region = MarketScope.region;
    return TaxLine(
      label: region.taxLabel,
      regionName: region.name,
      amount: subtotal * region.taxRate,
    );
  }
}
