import 'package:starter_codes/core/money/money.dart';

/// Everything about a market that the *client* decides, as opposed to what the
/// server decides.
///
/// The distinction matters and getting it wrong is a bug:
///
/// * **The order's market** is decided by the server, by reverse-geocoding the
///   pickup coordinates. It governs money, tax and payment, and the client only
///   reads it off the quote. See `MarketRules` in `core/money/money.dart`.
/// * **The device's market** — this file — governs *input affordances*: which
///   country address search offers, how a phone number is written, where the map
///   opens, what a region is called. It is a convenience, not an authority.
///
/// So a customer whose device is set to Nigeria who books a Toronto pickup still
/// gets a Canadian order at Canadian prices. The device market only ever changes
/// what is easy to type, never what is charged.
class MarketProfile {
  const MarketProfile({
    required this.country,
    required this.displayName,
    required this.placesCountryCode,
    required this.defaultLat,
    required this.defaultLng,
    required this.dialCode,
    required this.localPhoneDigits,
    required this.phoneExample,
    required this.regionLabel,
    required this.regions,
    required this.clampPickToRegion,
    required this.postalCodeLabel,
    required this.supportPhone,
    required this.supportHours,
  });

  final Country country;

  /// What to call this market to a customer.
  final String displayName;

  /// ISO country code for the Google Places `components` filter.
  final String placesCountryCode;

  /// Where the map opens before the customer has picked anything.
  final double defaultLat;
  final double defaultLng;

  /// International dialling prefix, e.g. `+234`.
  final String dialCode;

  /// Digits in a local number, after the dial code. Nigerian numbers are
  /// written with a leading 0 that is dropped in international form, so an
  /// 11-digit local number is 10 digits after `+234`.
  final int localPhoneDigits;

  /// A local number of the right shape, for the field's placeholder. Grouped
  /// in threes the way a number is displayed back, so the hint and a real
  /// entry read alike.
  final String phoneExample;

  /// What this market calls its first-level administrative region.
  final String regionLabel;

  /// The regions themselves, for pickers.
  final List<String> regions;

  /// Whether the map picker should confine the pin to the customer's region.
  ///
  /// Nigeria does this because riders are dispatched per state. Nowhere else
  /// has region boundary data, and clamping without it would strand the pin.
  final bool clampPickToRegion;

  /// Null where the market does not use postal codes.
  final String? postalCodeLabel;

  final String supportPhone;
  final String supportHours;

  /// Whether an address in this market needs a postal code to be deliverable.
  bool get usesPostalCode => postalCodeLabel != null;
}

const MarketProfile _nigeria = MarketProfile(
  country: Country.ng,
  displayName: 'Nigeria',
  placesCountryCode: 'NG',
  defaultLat: 6.5244, // Lagos
  defaultLng: 3.3792,
  dialCode: '+234',
  localPhoneDigits: 10,
  phoneExample: '801 234 5678',
  regionLabel: 'State',
  regions: [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
    'FCT',
  ],
  clampPickToRegion: true,
  postalCodeLabel: null,
  supportPhone: '+234 700 846 6556',
  supportHours: '8am-8pm daily',
);

const MarketProfile _canada = MarketProfile(
  country: Country.ca,
  displayName: 'Canada',
  placesCountryCode: 'CA',
  defaultLat: 43.6532, // Toronto
  defaultLng: -79.3832,
  dialCode: '+1',
  localPhoneDigits: 10,
  phoneExample: '416 555 0123',
  regionLabel: 'Province',
  regions: [
    'Alberta',
    'British Columbia',
    'Manitoba',
    'New Brunswick',
    'Newfoundland and Labrador',
    'Northwest Territories',
    'Nova Scotia',
    'Nunavut',
    'Ontario',
    'Prince Edward Island',
    'Quebec',
    'Saskatchewan',
    'Yukon',
  ],
  clampPickToRegion: false,
  postalCodeLabel: 'Postal code',
  supportPhone: '+1 647 946 0011',
  supportHours: '8am-8pm ET',
);

extension CountryProfile on Country {
  MarketProfile get profile => switch (this) {
        Country.ng => _nigeria,
        Country.ca => _canada,
      };

  /// The currency this market prices in. Only ever a hint for the UI — an
  /// order's currency comes off its quote, never from here.
  Currency get defaultCurrency => switch (this) {
        Country.ng => Currency.ngn,
        Country.ca => Currency.cad,
      };
}

/// Resolves the country Google returned on an address to a market we serve.
///
/// Google spells the country out (`"Nigeria"`, `"Canada"`), so this maps names
/// as well as codes. Returns null for anywhere we do not operate, which the
/// caller should treat as "leave the market alone" rather than as Nigeria.
Country? countryFromPlaceName(String? name) {
  if (name == null) return null;
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  const names = <String, Country>{
    'nigeria': Country.ng,
    'ng': Country.ng,
    'nga': Country.ng,
    'canada': Country.ca,
    'ca': Country.ca,
    'can': Country.ca,
  };
  return names[normalized];
}
