/// The market catalogue. Values follow `prototype/public/js/market.js` and the Canada spec in
/// `.claude/design/08-backend-gaps.md`.
///
/// Adding a market is adding an entry here. It is not adding a branch to a screen.
library;

import 'models.dart';
import 'regions.dart';

abstract final class Markets {
  /// Nigeria — the live market. Everything here must render **exactly** what the API returns
  /// today: a delivery fee, no separate tax line, `₦` with no decimals.
  static const Market nigeria = Market(
    code: 'NG',
    displayName: 'Nigeria',
    locale: 'en_NG',
    currency: CurrencyConfig(code: 'NGN', symbol: '₦', decimalDigits: 0),
    // The API quotes `deliveryFee` and nothing else. Showing a tax row here would invent a
    // number the server never sent.
    showTax: false,
    regionLabel: 'State',
    regions: nigerianStates,
    addressFields: <AddressField>[
      AddressField(key: 'street', label: 'Street address'),
      AddressField(key: 'area', label: 'Area'),
      AddressField(key: 'state', label: 'State', kind: AddressFieldKind.region),
    ],
    phone: PhoneConfig(
      dialCode: '+234',
      example: '801 234 5678',
      nationalDigits: 10,
    ),
    paymentProviders: <MarketPaymentProvider>[
      MarketPaymentProvider(
        id: 'Wallet',
        name: 'Vinkol wallet',
        note: 'Pay from your balance',
      ),
      MarketPaymentProvider(
        id: 'Paystack',
        name: 'Paystack',
        note: 'Card details are entered on Paystack',
      ),
    ],
    // The live production contacts, from `LinkRoutes`. The prototype fixture quotes a
    // different number; these are the real ones and win.
    support: MarketSupport(
      phone: '+234 807 972 2331',
      phoneAlt: '+234 701 848 8479',
      email: 'Vinkollogistics@gmail.com',
      whatsapp: 'https://wa.link/xuhpbs',
      hours: '8am–8pm daily',
    ),
    languages: <MarketLanguage>[
      MarketLanguage(code: 'en', nativeName: 'English'),
    ],
    liabilityCoverage: 50000,
    // The ladder the live app already offers.
    topUpPresets: <num>[1000, 5000, 10000, 20000],
    // The floor the backend enforces on `wallet/fund` and `wallet/withdraw`.
    minimumTransfer: 100,
    // NUBAN. The `banks/validate` endpoint expects exactly this many digits.
    bankAccountDigits: 10,
  );

  /// Canada — the expansion this project exists for (decision D-09). Specified and kept even
  /// though the backend does not support it yet.
  static const Market canada = Market(
    code: 'CA',
    displayName: 'Canada',
    locale: 'en_CA',
    currency: CurrencyConfig(code: 'CAD', symbol: 'CA\$', decimalDigits: 2),
    // Sales tax must be displayed, and its rate and label come from the province, not here.
    showTax: true,
    regionLabel: 'Province',
    regions: canadianProvinces,
    addressFields: <AddressField>[
      AddressField(key: 'street', label: 'Street address'),
      AddressField(key: 'city', label: 'City'),
      AddressField(
          key: 'province', label: 'Province', kind: AddressFieldKind.region),
      AddressField(
        key: 'postalCode',
        label: 'Postal code',
        kind: AddressFieldKind.postalCode,
        // Canada cannot deliver without one, so it is required and validated. The pattern
        // excludes the letters Canada Post never uses (D, F, I, O, Q, U anywhere; W and Z
        // leading).
        pattern:
            r'^[ABCEGHJ-NPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][ -]?\d[ABCEGHJ-NPRSTV-Z]\d$',
        example: 'A1A 1A1',
        hint: 'A1A 1A1',
      ),
    ],
    phone: PhoneConfig(
      dialCode: '+1',
      example: '647 946 0011',
      nationalDigits: 10,
    ),
    paymentProviders: <MarketPaymentProvider>[
      MarketPaymentProvider(
        id: 'Wallet',
        name: 'Vinkol wallet',
        note: 'Pay from your balance',
      ),
      MarketPaymentProvider(
        id: 'Card',
        name: 'Credit or debit card',
        note: 'Visa, Mastercard, Amex',
      ),
      MarketPaymentProvider(
        id: 'Interac',
        name: 'Interac',
        note: 'Pay from your Canadian bank',
      ),
    ],
    support: MarketSupport(
      phone: '+1 647 946 0011',
      email: 'Vinkollogistics@gmail.com',
      hours: '8am–8pm ET',
    ),
    // Quebec's Charter of the French Language makes this a legal requirement.
    languages: <MarketLanguage>[
      MarketLanguage(code: 'en', nativeName: 'English'),
      MarketLanguage(code: 'fr', nativeName: 'Français'),
    ],
    // Not set. Nigeria's ₦50,000 retention policy is a Nigerian commercial commitment and
    // does not convert; a Canadian figure is a business decision, not a conversion.
    liabilityCoverage: null,
    // Specified, not converted: a sensible Canadian ladder in whole dollars.
    topUpPresets: <num>[20, 50, 100, 200],
    minimumTransfer: 5,
  );

  /// United Kingdom. Configured, not yet operated — the same standing as Canada (D-09).
  ///
  /// Structurally it is the third shape: two decimals like Canada, but VAT-inclusive pricing
  /// like Nigeria, so it shows no separate tax line, and distances are in miles.
  static const Market unitedKingdom = Market(
    code: 'GB',
    displayName: 'United Kingdom',
    locale: 'en_GB',
    currency: CurrencyConfig(code: 'GBP', symbol: '£', decimalDigits: 2),
    // Consumer prices must be advertised VAT-inclusive, so a separate tax row would be a
    // second, wrong number next to the price the user agreed to.
    showTax: false,
    regionLabel: 'Nation',
    regions: ukNations,
    addressFields: <AddressField>[
      AddressField(key: 'street', label: 'Street address'),
      AddressField(key: 'city', label: 'Town or city'),
      AddressField(
          key: 'nation', label: 'Nation', kind: AddressFieldKind.region),
      AddressField(
        key: 'postcode',
        label: 'Postcode',
        kind: AddressFieldKind.postalCode,
        pattern: r'^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$',
        example: 'SW1A 1AA',
        hint: 'SW1A 1AA',
      ),
    ],
    phone: PhoneConfig(
      dialCode: '+44',
      // Ofcom's reserved drama range: a real format that can never ring a real person.
      example: '7700 900123',
      nationalDigits: 10,
    ),
    paymentProviders: <MarketPaymentProvider>[
      MarketPaymentProvider(
        id: 'Wallet',
        name: 'Vinkol wallet',
        note: 'Pay from your balance',
      ),
      MarketPaymentProvider(
        id: 'Card',
        name: 'Credit or debit card',
        note: 'Visa, Mastercard, Amex',
      ),
    ],
    // One support line until a local one is staffed — an invented local number would route a
    // stranger's phone, which is worse than an honest international one.
    support: MarketSupport(
      phone: '+234 807 972 2331',
      email: 'Vinkollogistics@gmail.com',
      hours: '8am–8pm WAT',
    ),
    languages: <MarketLanguage>[
      MarketLanguage(code: 'en', nativeName: 'English'),
    ],
    liabilityCoverage: null,
    topUpPresets: <num>[10, 25, 50, 100],
    minimumTransfer: 5,
    // A UK account number is exactly eight digits, behind a six-digit sort code.
    bankAccountDigits: 8,
    distanceUnit: DistanceUnit.mi,
  );

  /// United States. Configured, not yet operated.
  ///
  /// The tax case Canada is not: sales tax is a **state** rate that counties and cities add
  /// to, so [Region.taxRate] here is a floor and the quote endpoint stays authoritative.
  static const Market unitedStates = Market(
    code: 'US',
    displayName: 'United States',
    locale: 'en_US',
    currency: CurrencyConfig(code: 'USD', symbol: '\$', decimalDigits: 2),
    showTax: true,
    regionLabel: 'State',
    regions: usStates,
    addressFields: <AddressField>[
      AddressField(key: 'street', label: 'Street address'),
      AddressField(key: 'city', label: 'City'),
      AddressField(key: 'state', label: 'State', kind: AddressFieldKind.region),
      AddressField(
        key: 'zip',
        label: 'ZIP code',
        kind: AddressFieldKind.postalCode,
        // ZIP+4 is optional and both forms are deliverable.
        pattern: r'^\d{5}(-\d{4})?$',
        example: '94105',
        hint: '94105',
      ),
    ],
    phone: PhoneConfig(
      dialCode: '+1',
      // The 555-01xx block is reserved for fiction.
      example: '415 555 0142',
      nationalDigits: 10,
    ),
    paymentProviders: <MarketPaymentProvider>[
      MarketPaymentProvider(
        id: 'Wallet',
        name: 'Vinkol wallet',
        note: 'Pay from your balance',
      ),
      MarketPaymentProvider(
        id: 'Card',
        name: 'Credit or debit card',
        note: 'Visa, Mastercard, Amex',
      ),
    ],
    support: MarketSupport(
      phone: '+234 807 972 2331',
      email: 'Vinkollogistics@gmail.com',
      hours: '8am–8pm WAT',
    ),
    languages: <MarketLanguage>[
      MarketLanguage(code: 'en', nativeName: 'English'),
    ],
    liabilityCoverage: null,
    topUpPresets: <num>[20, 50, 100, 200],
    minimumTransfer: 5,
    // A routing number, an account number and no fixed length — null means the field
    // validates on "not empty" rather than inventing a rule.
    bankAccountDigits: null,
    distanceUnit: DistanceUnit.mi,
  );

  /// Ghana. Configured, not yet operated.
  ///
  /// The market that proves addresses are a list and not a struct: there is no postcode, and
  /// the thing that actually finds a door is a GhanaPost GPS code, which is optional.
  static const Market ghana = Market(
    code: 'GH',
    displayName: 'Ghana',
    locale: 'en_GH',
    currency: CurrencyConfig(code: 'GHS', symbol: 'GH₵', decimalDigits: 2),
    showTax: false,
    regionLabel: 'Region',
    regions: ghanaianRegions,
    addressFields: <AddressField>[
      AddressField(key: 'street', label: 'Street address'),
      AddressField(key: 'area', label: 'Area'),
      AddressField(
          key: 'region', label: 'Region', kind: AddressFieldKind.region),
      AddressField(
        key: 'digitalAddress',
        label: 'GhanaPost GPS',
        isRequired: false,
        pattern: r'^[A-Z]{2}-\d{3,4}-\d{4}$',
        example: 'GA-183-4321',
        hint: 'GA-183-4321',
      ),
    ],
    phone: PhoneConfig(
      dialCode: '+233',
      example: '24 123 4567',
      nationalDigits: 9,
    ),
    paymentProviders: <MarketPaymentProvider>[
      MarketPaymentProvider(
        id: 'Wallet',
        name: 'Vinkol wallet',
        note: 'Pay from your balance',
      ),
      MarketPaymentProvider(
        id: 'Paystack',
        name: 'Paystack',
        note: 'Card or mobile money',
      ),
    ],
    support: MarketSupport(
      phone: '+234 807 972 2331',
      email: 'Vinkollogistics@gmail.com',
      hours: '8am–8pm WAT',
    ),
    languages: <MarketLanguage>[
      MarketLanguage(code: 'en', nativeName: 'English'),
    ],
    liabilityCoverage: null,
    topUpPresets: <num>[20, 50, 100, 200],
    minimumTransfer: 5,
  );

  /// South Africa. Configured, not yet operated.
  static const Market southAfrica = Market(
    code: 'ZA',
    displayName: 'South Africa',
    locale: 'en_ZA',
    currency: CurrencyConfig(code: 'ZAR', symbol: 'R', decimalDigits: 2),
    // The Consumer Protection Act requires the advertised price to be the price paid.
    showTax: false,
    regionLabel: 'Province',
    regions: southAfricanProvinces,
    addressFields: <AddressField>[
      AddressField(key: 'street', label: 'Street address'),
      AddressField(key: 'suburb', label: 'Suburb'),
      AddressField(key: 'city', label: 'City'),
      AddressField(
          key: 'province', label: 'Province', kind: AddressFieldKind.region),
      AddressField(
        key: 'postalCode',
        label: 'Postal code',
        kind: AddressFieldKind.postalCode,
        pattern: r'^\d{4}$',
        example: '8001',
        hint: '8001',
      ),
    ],
    phone: PhoneConfig(
      dialCode: '+27',
      example: '71 123 4567',
      nationalDigits: 9,
    ),
    paymentProviders: <MarketPaymentProvider>[
      MarketPaymentProvider(
        id: 'Wallet',
        name: 'Vinkol wallet',
        note: 'Pay from your balance',
      ),
      MarketPaymentProvider(
        id: 'Card',
        name: 'Credit or debit card',
        note: 'Visa, Mastercard',
      ),
    ],
    support: MarketSupport(
      phone: '+234 807 972 2331',
      email: 'Vinkollogistics@gmail.com',
      hours: '8am–8pm WAT',
    ),
    languages: <MarketLanguage>[
      MarketLanguage(code: 'en', nativeName: 'English'),
    ],
    liabilityCoverage: null,
    topUpPresets: <num>[50, 100, 250, 500],
    minimumTransfer: 20,
  );

  static const Map<String, Market> byCode = <String, Market>{
    'NG': nigeria,
    'CA': canada,
    'GB': unitedKingdom,
    'US': unitedStates,
    'GH': ghana,
    'ZA': southAfrica,
  };

  /// The picker order: the live market first, then the expansion, then the rest
  /// alphabetically. Adding a market is adding it here.
  static const List<Market> all = <Market>[
    nigeria,
    canada,
    ghana,
    southAfrica,
    unitedKingdom,
    unitedStates,
  ];

  /// The market to fall back to when nothing has been resolved yet. Nigeria is the live
  /// market, so an unresolved app behaves exactly as it does today.
  static const Market fallback = nigeria;

  /// Looks a market up by country code, falling back rather than throwing — a missing or
  /// unknown code must not be able to take the app down at startup.
  static Market resolve(String? code) =>
      byCode[code?.trim().toUpperCase()] ?? fallback;
}
