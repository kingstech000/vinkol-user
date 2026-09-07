/// The market layer's data model.
///
/// The rule (`.claude/design/03-globalization-gaps.md`): **one global brand, configurable
/// markets.** A screen never asks what country it is in — it asks the market a question. If a
/// screen needs to branch on country, the market is missing a field; add the field.
///
/// Reference implementation: `prototype/public/js/market.js`. The Canada spec and the three
/// traps this model exists to avoid are in `.claude/design/08-backend-gaps.md`.
library;

/// Where the currency symbol sits relative to the number. Configuration, never an assumption:
/// several locales suffix it.
enum SymbolPosition { prefix, suffix }

/// What kind of control an [AddressField] renders as. The market supplies the field list and
/// its order; the address form renders whatever it is given.
enum AddressFieldKind {
  /// Free text — street, area, city.
  text,

  /// A choice from [Market.regions]. Labelled by [Market.regionLabel].
  region,

  /// Postal / ZIP code. Validated against [AddressField.pattern].
  postalCode,
}

enum DistanceUnit { km, mi }

extension DistanceUnitX on DistanceUnit {
  String get suffix => this == DistanceUnit.km ? 'km' : 'mi';
}

/// How money is written in this market.
///
/// Both halves matter. `₦1,200` and `CA$1,200.00` differ by four glyphs and two decimal
/// places, so nothing may lay out around a symbol width or assume a decimal count.
class CurrencyConfig {
  const CurrencyConfig({
    required this.code,
    required this.symbol,
    required this.decimalDigits,
    this.position = SymbolPosition.prefix,
  });

  /// ISO 4217, e.g. `NGN`, `CAD`.
  final String code;

  /// The glyph shown to users, e.g. `₦`, `CA$`.
  final String symbol;

  /// NGN commonly shows 0; CAD, USD, GBP and EUR show 2.
  final int decimalDigits;

  final SymbolPosition position;
}

/// An administrative region — a Nigerian state, a Canadian province.
///
/// **Tax lives here, not on the market.** Ontario charges 13% HST and Alberta 5% GST in the
/// same country, and the label is not always a single tax ("GST + QST"). Anything that holds
/// one rate per country is wrong in Canada
/// (`.claude/design/08-backend-gaps.md`, decision D-09).
class Region {
  const Region({
    required this.code,
    required this.name,
    required this.taxLabel,
    required this.taxRate,
  });

  /// Short code — `LA`, `ON`, `QC`. Stable; safe to persist.
  final String code;

  /// The display name. This is also what the API stores in `User.state` today and what
  /// `StateBoundaries` keys on, so it must match those strings exactly for Nigeria.
  final String name;

  /// What this region calls its sales tax: `VAT`, `HST`, `GST + QST`.
  final String taxLabel;

  /// Fractional rate, e.g. `0.13`. **A display fallback only** — the quote endpoint is
  /// expected to return the authoritative tax amount and label resolved from the delivery's
  /// province (D-09). Never bill from this number.
  final double taxRate;
}

/// One field in a market's address form.
///
/// Address is an ordered list, not a struct. Nigeria has three fields and no postal code;
/// Canada has four and cannot deliver without one. A `state` column does not survive the next
/// market.
class AddressField {
  const AddressField({
    required this.key,
    required this.label,
    this.kind = AddressFieldKind.text,
    this.isRequired = true,
    this.hint,
    this.pattern,
    this.example,
  });

  /// The key this field is stored and transmitted under.
  final String key;

  /// The user-facing label. Assume +40% growth under translation.
  final String label;

  final AddressFieldKind kind;
  final bool isRequired;
  final String? hint;

  /// Validation for the field, where the market defines one (postal codes). Held as a
  /// pattern *source* rather than a [RegExp] so the whole market stays `const`.
  final String? pattern;

  /// A sample value, e.g. `A1A 1A1`.
  final String? example;

  bool validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return !isRequired;
    final source = pattern;
    if (source == null) return true;
    return (_compiled[source] ??= RegExp(source, caseSensitive: false))
        .hasMatch(text);
  }

  static final Map<String, RegExp> _compiled = <String, RegExp>{};
}

/// How phone numbers are written here. One global phone component; the market supplies the
/// numbers behind it.
class PhoneConfig {
  const PhoneConfig({
    required this.dialCode,
    required this.example,
    required this.nationalDigits,
  });

  /// `+234`, `+1`.
  final String dialCode;

  /// A sample national number, e.g. `801 234 5678`.
  final String example;

  /// How many digits follow the dial code.
  final int nationalDigits;

  /// The national digits of whatever the user typed or the API stored.
  ///
  /// Accepts the four shapes a phone number arrives in — `+234801…`, `234801…`, `0801…` and
  /// `801…` — and strips spaces, dashes and brackets. This replaces `PhoneNumberUtils`, which
  /// hardcodes `+234` and a 10-digit length and therefore cannot see a Canadian number.
  String nationalNumber(String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    final code = dialCode.replaceAll(RegExp(r'[^0-9]'), '');
    // Only strip the country code when what remains could still be a full national number —
    // otherwise `+1 647…` loses its leading 6 the moment the 1 is treated as a prefix.
    if (code.isNotEmpty &&
        digits.startsWith(code) &&
        digits.length > nationalDigits) {
      digits = digits.substring(code.length);
    }
    // The trunk prefix. Nigeria writes 0801…; the stored form never keeps it.
    if (digits.length > nationalDigits && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  bool isValidNational(String input) =>
      nationalNumber(input).length == nationalDigits;

  /// The form the API is given: dial code plus national digits, nothing else.
  String international(String input) => '$dialCode${nationalNumber(input)}';
}

/// A payment method offered in this market. Paystack has no Canadian presence and Interac has
/// no Nigerian one, so the list is config; the checkout UI that renders it is global.
class MarketPaymentProvider {
  const MarketPaymentProvider({
    required this.id,
    required this.name,
    required this.note,
  });

  /// The value sent to the API as `paymentSource`.
  final String id;
  final String name;
  final String note;
}

/// A language a market offers. Carries the BCP-47 code the app resolves a [Locale] from and
/// the name shown to a user, so the two cannot drift apart.
class MarketLanguage {
  const MarketLanguage({required this.code, required this.nativeName});

  /// The language subtag: `en`, `fr`.
  final String code;

  /// The name written in that language — a language picker that says "French" to a
  /// francophone has already failed.
  final String nativeName;
}

/// Support channels and hours. Regulatory and contact details differ per country and cannot
/// live in a global string.
class MarketSupport {
  const MarketSupport({
    required this.phone,
    required this.email,
    required this.hours,
    this.phoneAlt,
    this.whatsapp,
  });

  final String phone;

  /// A second line, where the market runs one. Nigeria does; a market that does not gets
  /// null and the row is not rendered. Channels are per-country config, not a screen's
  /// business — a support screen that names a Nigerian number in Canada is the same class
  /// of bug as one that prints the naira symbol there.
  final String? phoneAlt;

  final String email;

  /// A deep link to whatever messaging channel this market actually staffs. Null where there
  /// is none. This is not in-app chat — the prototype is right that there is no such thing
  /// and no endpoint for one; it is an outbound link to a channel that exists today.
  final String? whatsapp;

  /// e.g. `8am–8pm daily`, `8am–8pm ET`.
  final String hours;

  static String _tel(String number) =>
      'tel:${number.replaceAll(RegExp(r'[^\d+]'), '')}';

  String get phoneUri => _tel(phone);
  String? get phoneAltUri => phoneAlt == null ? null : _tel(phoneAlt!);
  String get emailUri => 'mailto:$email';
}

/// Everything that varies by country. Resolved once at startup and read through
/// `marketProvider` (widgets) or `MarketScope` (the pure formatters).
class Market {
  const Market({
    required this.code,
    required this.displayName,
    required this.locale,
    required this.currency,
    required this.showTax,
    required this.regionLabel,
    required this.regions,
    required this.addressFields,
    required this.phone,
    required this.paymentProviders,
    required this.support,
    required this.languages,
    required this.liabilityCoverage,
    required this.topUpPresets,
    required this.minimumTransfer,
    this.bankAccountDigits,
    this.distanceUnit = DistanceUnit.km,
  });

  /// ISO 3166-1 alpha-2. Never rendered as a flag — flags are politically loaded and
  /// inconsistent across platforms. Show [displayName] instead.
  final String code;

  final String displayName;

  /// The `intl` locale used for number and date formatting, e.g. `en_NG`, `en_CA`.
  final String locale;

  final CurrencyConfig currency;

  /// Whether a tax line is displayed at all.
  ///
  /// This is the field that does structural work rather than cosmetic work: Nigeria quotes a
  /// delivery fee with no separate tax line, which is exactly what the API returns today, and
  /// Canada must display sales tax. Switching market makes a whole row appear.
  final bool showTax;

  /// What this country calls its administrative regions: `State`, `Province`.
  final String regionLabel;

  final List<Region> regions;

  /// The address form, in the order it is rendered.
  final List<AddressField> addressFields;

  final PhoneConfig phone;
  final List<MarketPaymentProvider> paymentProviders;
  final MarketSupport support;

  /// Available languages, first is the default. Quebec's Charter of the French Language makes
  /// Français a legal requirement in Canada, not a nicety.
  final List<MarketLanguage> languages;

  /// The language codes this market ships, in order. Drives `supportedLocales`.
  List<String> get languageCodes => <String>[for (final l in languages) l.code];

  /// Whether this market offers a language. A locale the market does not ship must never be
  /// selected — an English-only market has no French copy to fall back to.
  bool offersLanguage(String? code) =>
      code != null && languageCodes.contains(code);

  /// The retention-coverage ceiling quoted in support copy, in this market's currency, or
  /// null where no figure has been set. Trust and regulatory claims differ per country and
  /// cannot live in a global string, and a coverage number is a commercial decision — it is
  /// never derived from another market's.
  final num? liabilityCoverage;

  /// The one-tap top-up amounts on the Add money screen, smallest first.
  ///
  /// Per market rather than converted: a ₦5,000 chip and a CA$5,000 chip are not the same
  /// offer, and a converted ladder produces amounts nobody would choose. Same reasoning as
  /// [liabilityCoverage].
  final List<num> topUpPresets;

  /// The smallest amount the app will submit for a top-up or a withdrawal.
  ///
  /// A floor in ₦ is meaningless in CA$ — ₦100 is roughly nine Canadian cents — so this is
  /// market config rather than a constant in the wallet screens.
  final num minimumTransfer;

  /// The fixed length of a bank account number in this market, or null where accounts are
  /// not identified by one number of one length.
  ///
  /// Nigeria's NUBAN is exactly ten digits, which is what the validate endpoint expects.
  /// Canada is null: an account there is a transit number, an institution number and an
  /// account number, and the backend has no endpoint for that shape (D-10). Null means the
  /// field validates on "not empty" rather than inventing a rule.
  final int? bankAccountDigits;

  final DistanceUnit distanceUnit;

  List<String> get regionNames => <String>[for (final r in regions) r.name];

  /// Looks a region up by the name the API stores. Returns null rather than guessing — an
  /// unrecognised region is a data problem, not a default.
  Region? regionByName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final needle = name.trim().toLowerCase();
    for (final r in regions) {
      if (r.name.toLowerCase() == needle) return r;
    }
    return null;
  }

  Region? regionByCode(String? code) {
    if (code == null) return null;
    final needle = code.trim().toUpperCase();
    for (final r in regions) {
      if (r.code == needle) return r;
    }
    return null;
  }

  AddressField? addressField(String key) {
    for (final f in addressFields) {
      if (f.key == key) return f;
    }
    return null;
  }

  /// Whether this market collects a postal code. Derived, so no screen has to ask "is this
  /// Canada".
  bool get usesPostalCode =>
      addressFields.any((f) => f.kind == AddressFieldKind.postalCode);
}

/// A resolved tax line: what to label it and how much it is. Null everywhere [Market.showTax]
/// is false, so a market without a separate tax line renders no row at all.
class TaxLine {
  const TaxLine(
      {required this.label, required this.regionName, required this.amount});

  /// e.g. `HST`, `GST + QST`.
  final String label;
  final String regionName;
  final num amount;
}
