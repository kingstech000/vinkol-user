# Globalization Gaps — Brand Layer vs Market Layer

Brief §0.6 and §17–18. The rule: **the brand layer is identical in every country; the market
layer is configuration.** Nothing below gets deleted — it gets moved to the right layer.

## The architecture

```
BRAND LAYER (global, never varies)          MARKET LAYER (per country, configurable)
  color, type, spacing, radius                currency + symbol placement + decimals
  components and their behavior               number and date formatting
  motion, iconography                         address model and field order
  information hierarchy                       phone format and dial code
  tone of voice                               payment providers
  the five status semantics                   tax model and labels
                                              support channels and hours
                                              legal/regulatory copy
                                              distance units (km / mi)
                                              language
```

Target shape: `lib/core/market/` holds a `Market` config resolved once at startup
(country → currency, locale, formats, providers, support), exposed through a Riverpod provider.
Every screen reads formatting from it. No screen knows what country it is in.

## Measured leakage (from `lib/` at `4447728`)

| Leak | Count / location | Layer it belongs in |
|------|------------------|---------------------|
| `₦` hardcoded in UI and formatters | 25 occurrences across 14 files | Market — currency symbol |
| `AmountTextFormatter` prepends `₦` and pins locale `en_US` | [amount_formatter.dart](lib/core/extensions/amount_formatter.dart) | Market — this class is the single highest-leverage fix; ~all money in the app flows through `.toCurrency()` |
| `CurrencyFormatter` / `AmountInputFormatter` pin `en_US` grouping, integer-only, no decimal input | [currency_formatter.dart](lib/core/extensions/currency_formatter.dart) | Market — CAD/USD/GBP need 2 decimals; some locales use `.` as the group separator |
| Nigerian state list | [state_boundaries.dart](lib/core/utils/state_boundaries.dart), [data_utils.dart](lib/core/utils/data_utils.dart) | Market — becomes "administrative region", supplied per country |
| Address model assumes state + Nigerian structure | [booking/model/request.dart](lib/features/booking/model/request.dart), [profile_setting_screen.dart](lib/features/auth/view/screen/profile_setting_screen.dart) | Market — address is an ordered field list per country, not a fixed struct |
| Phone input assumes a dial code | [phone_number_utils.dart](lib/utils/phone_number_utils.dart), [phone_number_input.dart](lib/widgets/phone_number_input.dart) | Market — but keep one global component |
| Payment provider assumptions in the webview flow | [payment_webview.dart](lib/features/payment/view/payment_webview.dart), [payment_veification_screen.dart](lib/features/payment/view/payment_veification_screen.dart) | Market — provider is config, the checkout UI is global |
| Support contact details | [SupportAndHelpScreen.dart](lib/features/profile/view/screen/SupportAndHelpScreen.dart) | Market |
| **Zero localization infrastructure** | no `flutter_localizations`, no `AppLocalizations`, 0 hits | Introduce — every user-facing string is a Dart literal today |

## Design rules that follow

1. **Never lay out around a symbol width.** `₦1,200` and `CA$1,200.00` differ by 4 glyphs.
   Money is right-aligned on a shared axis, tabular figures, symbol at reduced emphasis.
2. **Never hardcode a decimal count.** NGN commonly shows 0; CAD/USD/GBP/EUR show 2.
3. **Assume +40% text length.** French and German run long. No single-line label without an
   overflow decision; no button whose label cannot wrap to two lines.
4. **Never encode meaning in symbol position.** Some locales suffix the symbol.
5. **Address is a list, not a struct.** Field order, labels and required-ness come from config.
6. **Dates and distances are formatted, never concatenated.**
7. **Design for RTL structurally** even though no RTL market is planned: use `EdgeInsetsDirectional`
   and `start`/`end`, not `left`/`right`. It costs nothing now and is unaffordable later.
