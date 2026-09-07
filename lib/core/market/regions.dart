/// Administrative regions per market, moved here out of `data_utils.dart` and
/// `state_boundaries.dart` (`.claude/design/03-globalization-gaps.md`).
///
/// **Every `taxRate` below is a display fallback.** The quote endpoint is expected to return
/// the authoritative tax amount and label resolved from the delivery's region (decision D-09,
/// `.claude/design/08-backend-gaps.md`). Rates change by legislation; do not bill from these.
library;

import 'models.dart';

/// Nigeria's 36 states plus the Federal Capital Territory.
///
/// Names match `StateBoundaries.boundaries` and the `state` string the API stores on the user
/// exactly — those lookups are by name, so the spellings here are load-bearing.
///
/// VAT is a single national rate (7.5%) and Nigeria does not display a separate tax line
/// (`Markets.nigeria.showTax` is false), so no region here changes the money.
const List<Region> nigerianStates = <Region>[
  Region(code: 'AB', name: 'Abia', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'AD', name: 'Adamawa', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'AK', name: 'Akwa Ibom', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'AN', name: 'Anambra', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'BA', name: 'Bauchi', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'BY', name: 'Bayelsa', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'BE', name: 'Benue', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'BO', name: 'Borno', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'CR', name: 'Cross River', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'DE', name: 'Delta', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'EB', name: 'Ebonyi', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'ED', name: 'Edo', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'EK', name: 'Ekiti', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'EN', name: 'Enugu', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'GO', name: 'Gombe', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'IM', name: 'Imo', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'JI', name: 'Jigawa', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'KD', name: 'Kaduna', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'KN', name: 'Kano', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'KT', name: 'Katsina', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'KE', name: 'Kebbi', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'KO', name: 'Kogi', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'KW', name: 'Kwara', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'LA', name: 'Lagos', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'NA', name: 'Nasarawa', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'NI', name: 'Niger', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'OG', name: 'Ogun', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'ON', name: 'Ondo', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'OS', name: 'Osun', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'OY', name: 'Oyo', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'PL', name: 'Plateau', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'RI', name: 'Rivers', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'SO', name: 'Sokoto', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'TA', name: 'Taraba', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'YO', name: 'Yobe', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'ZA', name: 'Zamfara', taxLabel: 'VAT', taxRate: 0.075),
  Region(code: 'FC', name: 'FCT', taxLabel: 'VAT', taxRate: 0.075),
];

/// Canada's ten provinces and three territories.
///
/// **This list is the reason tax cannot be a market property.** Alberta charges 5% and Quebec
/// 14.975% in the same country, and four of these labels name two taxes rather than one. A
/// backend holding one rate per market is wrong here
/// (`.claude/design/08-backend-gaps.md`, trap 1).
///
/// The five rates named in the spec — ON, BC, AB, QC, NS — are carried verbatim from
/// `prototype/public/js/market.js`. The other eight are filled in to complete the country.
const List<Region> canadianProvinces = <Region>[
  Region(code: 'AB', name: 'Alberta', taxLabel: 'GST', taxRate: 0.05),
  Region(
      code: 'BC',
      name: 'British Columbia',
      taxLabel: 'GST + PST',
      taxRate: 0.12),
  Region(code: 'MB', name: 'Manitoba', taxLabel: 'GST + RST', taxRate: 0.12),
  Region(code: 'NB', name: 'New Brunswick', taxLabel: 'HST', taxRate: 0.15),
  Region(
    code: 'NL',
    name: 'Newfoundland and Labrador',
    taxLabel: 'HST',
    taxRate: 0.15,
  ),
  Region(
      code: 'NT',
      name: 'Northwest Territories',
      taxLabel: 'GST',
      taxRate: 0.05),
  Region(code: 'NS', name: 'Nova Scotia', taxLabel: 'HST', taxRate: 0.15),
  Region(code: 'NU', name: 'Nunavut', taxLabel: 'GST', taxRate: 0.05),
  Region(code: 'ON', name: 'Ontario', taxLabel: 'HST', taxRate: 0.13),
  Region(
      code: 'PE', name: 'Prince Edward Island', taxLabel: 'HST', taxRate: 0.15),
  Region(code: 'QC', name: 'Quebec', taxLabel: 'GST + QST', taxRate: 0.14975),
  Region(
      code: 'SK', name: 'Saskatchewan', taxLabel: 'GST + PST', taxRate: 0.11),
  Region(code: 'YT', name: 'Yukon', taxLabel: 'GST', taxRate: 0.05),
];

/// The four nations of the United Kingdom.
///
/// VAT is a single UK-wide rate and consumer prices are quoted VAT-inclusive by law, so
/// `Markets.unitedKingdom.showTax` is false and no nation here changes the money. The nation
/// still matters: it is part of a UK address and it is how deliveries are zoned.
const List<Region> ukNations = <Region>[
  Region(code: 'ENG', name: 'England', taxLabel: 'VAT', taxRate: 0.20),
  Region(code: 'NIR', name: 'Northern Ireland', taxLabel: 'VAT', taxRate: 0.20),
  Region(code: 'SCT', name: 'Scotland', taxLabel: 'VAT', taxRate: 0.20),
  Region(code: 'WLS', name: 'Wales', taxLabel: 'VAT', taxRate: 0.20),
];

/// The fifty United States plus the District of Columbia.
///
/// The rate is the **state** rate only. Most states also allow county and city sales tax on
/// top, so the figure here is a floor and a display fallback — the same rule as everywhere
/// else in this file: the quote endpoint returns the authoritative amount. Five states
/// (Alaska, Delaware, Montana, New Hampshire, Oregon) levy no state sales tax at all.
const List<Region> usStates = <Region>[
  Region(code: 'AL', name: 'Alabama', taxLabel: 'Sales tax', taxRate: 0.04),
  Region(code: 'AK', name: 'Alaska', taxLabel: 'Sales tax', taxRate: 0.0),
  Region(code: 'AZ', name: 'Arizona', taxLabel: 'Sales tax', taxRate: 0.056),
  Region(code: 'AR', name: 'Arkansas', taxLabel: 'Sales tax', taxRate: 0.065),
  Region(
      code: 'CA', name: 'California', taxLabel: 'Sales tax', taxRate: 0.0725),
  Region(code: 'CO', name: 'Colorado', taxLabel: 'Sales tax', taxRate: 0.029),
  Region(
      code: 'CT', name: 'Connecticut', taxLabel: 'Sales tax', taxRate: 0.0635),
  Region(code: 'DE', name: 'Delaware', taxLabel: 'Sales tax', taxRate: 0.0),
  Region(
      code: 'DC',
      name: 'District of Columbia',
      taxLabel: 'Sales tax',
      taxRate: 0.06),
  Region(code: 'FL', name: 'Florida', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(code: 'GA', name: 'Georgia', taxLabel: 'Sales tax', taxRate: 0.04),
  Region(code: 'HI', name: 'Hawaii', taxLabel: 'General excise', taxRate: 0.04),
  Region(code: 'ID', name: 'Idaho', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(code: 'IL', name: 'Illinois', taxLabel: 'Sales tax', taxRate: 0.0625),
  Region(code: 'IN', name: 'Indiana', taxLabel: 'Sales tax', taxRate: 0.07),
  Region(code: 'IA', name: 'Iowa', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(code: 'KS', name: 'Kansas', taxLabel: 'Sales tax', taxRate: 0.065),
  Region(code: 'KY', name: 'Kentucky', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(code: 'LA', name: 'Louisiana', taxLabel: 'Sales tax', taxRate: 0.0445),
  Region(code: 'ME', name: 'Maine', taxLabel: 'Sales tax', taxRate: 0.055),
  Region(code: 'MD', name: 'Maryland', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(
      code: 'MA',
      name: 'Massachusetts',
      taxLabel: 'Sales tax',
      taxRate: 0.0625),
  Region(code: 'MI', name: 'Michigan', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(
      code: 'MN', name: 'Minnesota', taxLabel: 'Sales tax', taxRate: 0.06875),
  Region(code: 'MS', name: 'Mississippi', taxLabel: 'Sales tax', taxRate: 0.07),
  Region(code: 'MO', name: 'Missouri', taxLabel: 'Sales tax', taxRate: 0.04225),
  Region(code: 'MT', name: 'Montana', taxLabel: 'Sales tax', taxRate: 0.0),
  Region(code: 'NE', name: 'Nebraska', taxLabel: 'Sales tax', taxRate: 0.055),
  Region(code: 'NV', name: 'Nevada', taxLabel: 'Sales tax', taxRate: 0.0685),
  Region(
      code: 'NH', name: 'New Hampshire', taxLabel: 'Sales tax', taxRate: 0.0),
  Region(
      code: 'NJ', name: 'New Jersey', taxLabel: 'Sales tax', taxRate: 0.06625),
  Region(
      code: 'NM',
      name: 'New Mexico',
      taxLabel: 'Gross receipts',
      taxRate: 0.04875),
  Region(code: 'NY', name: 'New York', taxLabel: 'Sales tax', taxRate: 0.04),
  Region(
      code: 'NC',
      name: 'North Carolina',
      taxLabel: 'Sales tax',
      taxRate: 0.0475),
  Region(
      code: 'ND', name: 'North Dakota', taxLabel: 'Sales tax', taxRate: 0.05),
  Region(code: 'OH', name: 'Ohio', taxLabel: 'Sales tax', taxRate: 0.0575),
  Region(code: 'OK', name: 'Oklahoma', taxLabel: 'Sales tax', taxRate: 0.045),
  Region(code: 'OR', name: 'Oregon', taxLabel: 'Sales tax', taxRate: 0.0),
  Region(
      code: 'PA', name: 'Pennsylvania', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(
      code: 'RI', name: 'Rhode Island', taxLabel: 'Sales tax', taxRate: 0.07),
  Region(
      code: 'SC', name: 'South Carolina', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(
      code: 'SD', name: 'South Dakota', taxLabel: 'Sales tax', taxRate: 0.042),
  Region(code: 'TN', name: 'Tennessee', taxLabel: 'Sales tax', taxRate: 0.07),
  Region(code: 'TX', name: 'Texas', taxLabel: 'Sales tax', taxRate: 0.0625),
  Region(code: 'UT', name: 'Utah', taxLabel: 'Sales tax', taxRate: 0.0485),
  Region(code: 'VT', name: 'Vermont', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(code: 'VA', name: 'Virginia', taxLabel: 'Sales tax', taxRate: 0.053),
  Region(code: 'WA', name: 'Washington', taxLabel: 'Sales tax', taxRate: 0.065),
  Region(
      code: 'WV', name: 'West Virginia', taxLabel: 'Sales tax', taxRate: 0.06),
  Region(code: 'WI', name: 'Wisconsin', taxLabel: 'Sales tax', taxRate: 0.05),
  Region(code: 'WY', name: 'Wyoming', taxLabel: 'Sales tax', taxRate: 0.04),
];

/// Ghana's sixteen regions.
///
/// VAT is national and consumer prices are quoted inclusive, so
/// `Markets.ghana.showTax` is false and the region does not move the money — it addresses and
/// zones the delivery.
const List<Region> ghanaianRegions = <Region>[
  Region(code: 'AH', name: 'Ahafo', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'AS', name: 'Ashanti', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'BO', name: 'Bono', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'BE', name: 'Bono East', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'CP', name: 'Central', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'EP', name: 'Eastern', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'AA', name: 'Greater Accra', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'NE', name: 'North East', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'NP', name: 'Northern', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'OT', name: 'Oti', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'SV', name: 'Savannah', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'UE', name: 'Upper East', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'UW', name: 'Upper West', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'TV', name: 'Volta', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'WP', name: 'Western', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'WN', name: 'Western North', taxLabel: 'VAT', taxRate: 0.15),
];

/// South Africa's nine provinces. VAT is national at 15% and prices are advertised inclusive,
/// so `Markets.southAfrica.showTax` is false.
const List<Region> southAfricanProvinces = <Region>[
  Region(code: 'EC', name: 'Eastern Cape', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'FS', name: 'Free State', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'GP', name: 'Gauteng', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'KZN', name: 'KwaZulu-Natal', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'LP', name: 'Limpopo', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'MP', name: 'Mpumalanga', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'NC', name: 'Northern Cape', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'NW', name: 'North West', taxLabel: 'VAT', taxRate: 0.15),
  Region(code: 'WC', name: 'Western Cape', taxLabel: 'VAT', taxRate: 0.15),
];
