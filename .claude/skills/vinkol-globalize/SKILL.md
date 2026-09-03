---
name: vinkol-globalize
description: Convert Nigeria-specific assumptions in the Vinkol app into the configurable market layer — currency, formatting, addresses, phone, payment providers, support, locale. Use when touching money, prices, ₦, wallet, checkout, addresses, states/provinces, phone numbers, dates, distances, or when asked about internationalization, Canada, or multi-currency.
---

# Vinkol Globalization

The rule: **one global brand, configurable markets.** Nothing is deleted — things move from the
brand layer to the market layer. Read `.claude/design/03-globalization-gaps.md` for the measured
inventory of what leaks where.

## The architecture

`lib/core/market/` holds a `Market` resolved once at startup and exposed through Riverpod:

```
Market
  countryCode, displayName
  currency: code, symbol, symbolPosition, decimalDigits, groupSeparator
  locale
  addressFields: ordered, labelled, required-ness per field
  phone: dialCode, format, validation
  paymentProviders
  tax: model, label ("VAT" / "GST" / "HST" / none)
  distanceUnit: km | mi
  support: channels, hours
```

No screen knows what country it is in. A screen that branches on country is a bug.

## Where to start — highest leverage first

1. **`AmountTextFormatter`** ([lib/core/extensions/amount_formatter.dart](lib/core/extensions/amount_formatter.dart))
   hardcodes `₦` and `en_US`. Nearly all money in the app flows through `.toCurrency()`.
   Making this market-aware fixes most of the currency problem in one change.
2. **`CurrencyFormatter` / `AmountInputFormatter`**
   ([lib/core/extensions/currency_formatter.dart](lib/core/extensions/currency_formatter.dart))
   pin `en_US` grouping and accept integers only. CAD/USD/GBP/EUR need 2 decimals.
3. **The 25 remaining `₦` literals** across 14 files — route them through the formatter.
4. **State lists** ([state_boundaries.dart](lib/core/utils/state_boundaries.dart),
   [data_utils.dart](lib/core/utils/data_utils.dart)) → "administrative region", per market.
5. **Address model** → an ordered field list from config, not a fixed struct.
6. **`flutter_localizations` + ARB files** — there is currently zero localization
   infrastructure and every user-facing string is a Dart literal.

## Design rules for anything you touch

1. **Never lay out around a symbol width.** `₦1,200` vs `CA$1,200.00` differ by four glyphs.
   Money is right-aligned, tabular, symbol at reduced weight.
2. **Never hardcode decimal places.** NGN commonly shows 0; CAD/USD/GBP/EUR show 2.
3. **Assume +40% text length.** Every label needs an overflow decision; buttons must wrap to
   two lines without breaking.
4. **Symbol position is config**, not a prefix you can assume.
5. **Dates, distances and numbers are formatted**, never concatenated.
6. **`EdgeInsetsDirectional`, `start`, `end`** — never `left`/`right`. No RTL market is planned;
   this costs nothing now and is unaffordable to retrofit.
7. **No flag emoji, ever** — as country markers or anything else. Flags are politically loaded
   and inconsistent across platforms; use the country name.
8. **Trust copy is market-layer.** Regulatory and insurance claims differ per country and
   cannot live in a global string.

## What stays global

Color, type, spacing, radius, components and their behavior, motion, iconography, information
hierarchy, tone of voice, the status semantics. A Canadian user and a Nigerian user see the
same product with different data in it.
