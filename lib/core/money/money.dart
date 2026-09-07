/// The market layer's money primitives.
///
/// The server decides which market an order belongs to by reverse-geocoding the
/// pickup coordinates, so the client never chooses a country or a currency — it
/// reads them off whatever the API returned and renders accordingly.
///
/// Records written before the Canada expansion carry neither field. Every one of
/// them is Nigerian, which is why both [Country.fromCode] and [Currency.fromCode]
/// fall back to the Nigerian value rather than throwing.
library;

import 'package:intl/intl.dart';

/// A market the app operates in.
enum Country {
  ng('NG'),
  ca('CA');

  const Country(this.code);

  /// The ISO 3166-1 alpha-2 code the API uses.
  final String code;

  /// Resolves an API `country` value, defaulting to Nigeria for legacy records.
  static Country fromCode(String? code) {
    if (code == null) return Country.ng;
    final normalized = code.trim().toUpperCase();
    for (final country in Country.values) {
      if (country.code == normalized) return country;
    }
    return Country.ng;
  }
}

/// What each market accepts and offers.
///
/// The server picks the market's default when `paymentSource` is omitted, which
/// is the safest thing to send — so a market with a single option sends nothing
/// at all rather than naming it.
extension MarketRules on Country {
  /// The payment sources this market accepts, in the order to offer them.
  ///
  /// Sending one the market does not offer is a 400 naming it, e.g.
  /// "Wallet is not available in CA".
  List<String> get paymentSources => switch (this) {
        Country.ng => const ['Wallet', 'Paystack'],
        Country.ca => const ['Stripe'],
      };

  /// Whether customers in this market have an in-app wallet.
  ///
  /// Canada has none: top-ups are refused, withdrawals do not apply, and a
  /// customer pays by card every time.
  bool get hasCustomerWallet => paymentSources.contains('Wallet');

  /// Whether to show the customer a choice at all. With one option there is
  /// nothing to choose, and [paymentSourceOrNull] sends nothing.
  bool get offersPaymentChoice => paymentSources.length > 1;

  /// The value to send as `paymentSource`, or null to let the server default.
  ///
  /// Returns null whenever the market has no choice to make, or when the
  /// selection is not one this market accepts — sending it would be a 400.
  String? paymentSourceOrNull(String? selected) {
    if (!offersPaymentChoice) return null;
    if (selected == null || !paymentSources.contains(selected)) return null;
    return selected;
  }

  /// Whether this market offers the partner-courier option, sold as
  /// "Priority+".
  ///
  /// It is fulfilled by Chowdeck, which operates only in Nigeria. Asking
  /// `orders/get-cd-quote` for a Canadian pickup is a guaranteed 400 — "We can
  /// not pick up from this address" — so outside Nigeria the quote is neither
  /// requested nor offered, rather than requested and shown greyed out.
  bool get offersPartnerCourier => switch (this) {
        Country.ng => true,
        Country.ca => false,
      };

  /// Where a cancelled order's money goes back to.
  ///
  /// Nigeria credits the in-app wallet immediately. Canada has no customer
  /// wallet, so Stripe returns it to the card over several business days.
  String get refundDestination => switch (this) {
        Country.ng => 'The amount will be reversed to your wallet.',
        Country.ca =>
          'The amount will be refunded to your card in 5-10 business days.',
      };
}

/// A currency the app can be charged in.
enum Currency {
  ngn('NGN', '₦', 0),
  cad('CAD', 'C\$', 2);

  const Currency(this.code, this.symbol, this.decimalDigits);

  /// The ISO 4217 code the API uses.
  final String code;

  /// The symbol to prefix an amount with.
  final String symbol;

  /// How many decimal places this currency is written with. Naira is quoted in
  /// whole units; Canadian dollars always show cents.
  final int decimalDigits;

  /// Resolves an API `currency` value, defaulting to naira for legacy records.
  static Currency fromCode(String? code) {
    if (code == null) return Currency.ngn;
    final normalized = code.trim().toUpperCase();
    for (final currency in Currency.values) {
      if (currency.code == normalized) return currency;
    }
    return Currency.ngn;
  }
}

/// An amount paired with the currency it is denominated in.
///
/// Pairing the two makes it impossible to render a Canadian amount with a naira
/// symbol, which is the failure the expansion guide warns about most.
class Money implements Comparable<Money> {
  const Money(this.amount, this.currency);

  const Money.zero(this.currency) : amount = 0;

  final double amount;
  final Currency currency;

  /// Reads an amount and a currency straight off a JSON map.
  ///
  /// Tolerates numbers arriving as strings, which several of the older order
  /// endpoints still do. Returns null when the amount key is absent or unparsable
  /// so that an optional field stays optional.
  static Money? tryParse(
    Map<String, dynamic> json,
    String amountKey, {
    String currencyKey = 'currency',
    Currency? fallbackCurrency,
  }) {
    final amount = parseAmount(json[amountKey]);
    if (amount == null) return null;
    return Money(
      amount,
      fallbackCurrency ?? Currency.fromCode(json[currencyKey] as String?),
    );
  }

  /// Coerces an API money value to a double, tolerating strings and nulls.
  ///
  /// Amounts must never be read as `int`: a Canadian total of 21.26 truncates to
  /// 21 and the customer is shown the wrong price.
  static double? parseAmount(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// The amount written for its own market, e.g. `₦2,700` or `C$21.26`.
  ///
  /// The symbol and the number of decimal places both come off [currency], so a
  /// Canadian total can never be rendered with a naira sign. Pass
  /// `showSymbol: false` when the symbol is drawn separately — the card layouts
  /// set it at a lighter weight so the number stays the hero.
  String format({bool showSymbol = true}) {
    final pattern = currency.decimalDigits > 0
        ? '#,##0.${'0' * currency.decimalDigits}'
        : '#,##0';
    final number = NumberFormat(pattern, 'en_US').format(amount);
    return showSymbol ? '${currency.symbol}$number' : number;
  }

  bool get isZero => amount == 0;

  Money operator +(Money other) =>
      Money(amount + _sameCurrency(other, '+'), currency);

  Money operator -(Money other) =>
      Money(amount - _sameCurrency(other, '-'), currency);

  Money operator *(num factor) => Money(amount * factor, currency);

  bool operator >(Money other) => amount > _sameCurrency(other, '>');

  bool operator <(Money other) => amount < _sameCurrency(other, '<');

  bool operator >=(Money other) => amount >= _sameCurrency(other, '>=');

  bool operator <=(Money other) => amount <= _sameCurrency(other, '<=');

  @override
  int compareTo(Money other) =>
      amount.compareTo(_sameCurrency(other, 'compare'));

  double _sameCurrency(Money other, String operation) {
    if (other.currency != currency) {
      throw ArgumentError(
        'Cannot $operation ${other.currency.code} and ${currency.code}: '
        'one payment cannot span two currencies.',
      );
    }
    return other.amount;
  }

  Money copyWith({double? amount, Currency? currency}) =>
      Money(amount ?? this.amount, currency ?? this.currency);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => '${currency.code} $amount';
}
