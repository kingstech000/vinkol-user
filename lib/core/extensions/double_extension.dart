import 'package:starter_codes/core/money/money.dart';

extension DoubleX on double {
  /// Formats this amount for a market.
  ///
  /// Defaults to naira so the existing call sites keep working unchanged; pass
  /// [currency] wherever the amount's market is known — it travels with every
  /// quote, order, payment and withdrawal the API returns.
  ///
  /// Naira is written without decimals and Canadian dollars with two. That is a
  /// property of the currency, not of the call site.
  String toMoney([Currency currency = Currency.ngn]) =>
      Money(this, currency).format();

  String toMoneyShowFree([Currency currency = Currency.ngn]) {
    if (this == 0.0) {
      return "Free";
    }
    return toMoney(currency);
  }

  String toMoneyWithoutSymbol([Currency currency = Currency.ngn]) =>
      Money(this, currency).format(showSymbol: false);

  String toMoneyWithSymbol([Currency currency = Currency.ngn]) =>
      toMoney(currency);
}
