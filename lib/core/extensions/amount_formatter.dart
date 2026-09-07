import 'package:starter_codes/core/market/market_format.dart';

/// Money formatting, market-aware.
///
/// Everything here now resolves through [MarketFormat] and the active market: the symbol, its
/// position, the decimal count and the grouping locale. Nothing in this file knows what
/// country it is in.
///
/// Nigeria's output is unchanged — `₦2,500` from [formatCurrency], `₦2,500.00` from
/// [formatCurrencyWithDecimals] — because NGN is configured with 0 decimals and the
/// "with decimals" variants pin 2. That is deliberate: Nigeria must keep rendering exactly
/// what the API returns today.
class AmountTextFormatter {
  /// The market's own precision. NGN 0, CAD 2.
  static String formatCurrency(double amount) => MarketFormat.money(amount);

  /// Pinned to at least 2 decimals — the "exact amount" register.
  static String formatCurrencyWithDecimals(double amount) =>
      MarketFormat.moneyPrecise(amount);

  static String formatAmount(double amount) => MarketFormat.amount(amount);

  static String formatAmountWithDecimals(double amount) =>
      MarketFormat.amount(amount, decimalDigits: 2);
}

extension AmountFormatting on num {
  String toCurrency() => AmountTextFormatter.formatCurrency(toDouble());
  String toAmount() => AmountTextFormatter.formatAmount(toDouble());
  String toCurrencyWithDecimals() =>
      AmountTextFormatter.formatCurrencyWithDecimals(toDouble());
  String toAmountWithDecimals() =>
      AmountTextFormatter.formatAmountWithDecimals(toDouble());
}
