import 'package:starter_codes/core/money/money.dart';

/// Money formatting helpers.
///
/// Unused as of Sep 2026 — every call site goes through `DoubleX.toMoney`.
/// Kept only so the public API stays stable per decision D-03; a deletion
/// candidate alongside the other dead files listed in CLAUDE.md.
///
/// The decimal places come from the currency, so the `WithDecimals` variants are
/// now identical to their plain counterparts.
class AmountTextFormatter {
  static String formatCurrency(double amount,
          [Currency currency = Currency.ngn]) =>
      Money(amount, currency).format();

  static String formatCurrencyWithDecimals(double amount,
          [Currency currency = Currency.ngn]) =>
      Money(amount, currency).format();

  static String formatAmount(double amount,
          [Currency currency = Currency.ngn]) =>
      Money(amount, currency).format(showSymbol: false);

  static String formatAmountWithDecimals(double amount,
          [Currency currency = Currency.ngn]) =>
      Money(amount, currency).format(showSymbol: false);
}

extension AmountFormatting on num {
  String toCurrency([Currency currency = Currency.ngn]) =>
      AmountTextFormatter.formatCurrency(toDouble(), currency);
  String toAmount([Currency currency = Currency.ngn]) =>
      AmountTextFormatter.formatAmount(toDouble(), currency);
  String toCurrencyWithDecimals([Currency currency = Currency.ngn]) =>
      AmountTextFormatter.formatCurrencyWithDecimals(toDouble(), currency);
  String toAmountWithDecimals([Currency currency = Currency.ngn]) =>
      AmountTextFormatter.formatAmountWithDecimals(toDouble(), currency);
}
