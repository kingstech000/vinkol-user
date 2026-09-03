/* The market layer, in miniature.
 * Mirrors the architecture in .claude/design/03-globalization-gaps.md: no screen knows what
 * country it is in. Screens call money() and taxLabel(); the market supplies the rest.
 * Switching markets in the harness must not change a single line of screen code.
 */

/* The market layer — the point of the redesign.
 *
 * A market is not a currency swap. It decides the symbol AND its decimals, whether tax is
 * shown at all and what it is called, what the administrative region is called, which address
 * fields exist and in what order, the phone format, and who support is.
 *
 * `showTax` matters most: Nigeria quotes a delivery fee with no separate tax line, which is
 * exactly what the API returns today. Canada must display sales tax. Switching market makes a
 * whole row appear — that is the market layer doing structural work, not cosmetics.
 */
export const MARKETS = {
  NG: {
    code: 'NG',
    name: 'Nigeria',
    flagless: 'NG',
    currency: 'NGN',
    symbol: '₦',
    symbolPosition: 'prefix',
    decimals: 0,
    locale: 'en-NG',
    showTax: false,          // matches the API today: deliveryFee only
    taxLabel: 'VAT',
    distanceUnit: 'km',
    regionLabel: 'State',
    dialCode: '+234',
    phoneExample: '801 234 5678',
    addressFields: ['Street address', 'Area', 'State'],
    postcodePattern: null,
    languages: ['English'],
    paymentProviders: [
      { id: 'wallet', name: 'Vinkol wallet', note: 'Pay from your balance', icon: 'wallet' },
      { id: 'paystack', name: 'Paystack', note: 'Card details are entered on Paystack', icon: 'card' },
    ],
    support: '+234 700 846 6556',
    supportHours: '8am–8pm daily',
    /* Nigeria charges one national rate, so region does not change the money. */
    regions: [
      { code: 'LA', name: 'Lagos', taxLabel: 'VAT', taxRate: 0.075 },
      { code: 'FC', name: 'Abuja (FCT)', taxLabel: 'VAT', taxRate: 0.075 },
      { code: 'RI', name: 'Rivers', taxLabel: 'VAT', taxRate: 0.075 },
    ],
  },
  CA: {
    code: 'CA',
    name: 'Canada',
    flagless: 'CA',
    currency: 'CAD',
    symbol: 'CA$',
    symbolPosition: 'prefix',
    decimals: 2,
    locale: 'en-CA',
    showTax: true,           // sales tax must be displayed
    taxLabel: 'HST',
    distanceUnit: 'km',
    regionLabel: 'Province',
    dialCode: '+1',
    phoneExample: '647 946 0011',
    addressFields: ['Street address', 'City', 'Province', 'Postal code'],
    postcodePattern: 'A1A 1A1',
    /* Quebec's Charter of the French Language makes French a legal requirement, not a nicety. */
    languages: ['English', 'Français'],
    paymentProviders: [
      { id: 'wallet', name: 'Vinkol wallet', note: 'Pay from your balance', icon: 'wallet' },
      { id: 'card', name: 'Credit or debit card', note: 'Visa, Mastercard, Amex', icon: 'card' },
      { id: 'interac', name: 'Interac', note: 'Pay from your Canadian bank', icon: 'store' },
    ],
    support: '+1 647 946 0011',
    supportHours: '8am–8pm ET',
    /* Canadian sales tax is set by PROVINCE, not by country. This is the single biggest thing
     * the backend must model differently: one tax rate per market is not enough. */
    regions: [
      { code: 'ON', name: 'Ontario', taxLabel: 'HST', taxRate: 0.13 },
      { code: 'BC', name: 'British Columbia', taxLabel: 'GST + PST', taxRate: 0.12 },
      { code: 'AB', name: 'Alberta', taxLabel: 'GST', taxRate: 0.05 },
      { code: 'QC', name: 'Quebec', taxLabel: 'GST + QST', taxRate: 0.14975 },
      { code: 'NS', name: 'Nova Scotia', taxLabel: 'HST', taxRate: 0.15 },
    ],
  },
};

let current = MARKETS.NG;
let currentRegion = MARKETS.NG.regions[0];

export const market = () => current;
export const region = () => currentRegion;
export const setRegion = (code) => {
  currentRegion = current.regions.find((r) => r.code === code) || current.regions[0];
};
export const setMarket = (code) => {
  current = MARKETS[code] || MARKETS.NG;
  currentRegion = current.regions[0];
};

/* Base amounts in fixtures are NGN. Real markets price independently; this keeps the demo
 * honest about magnitude without pretending to be an FX service. */
const FROM_NGN = { NG: 1, CA: 0.0011 };

/** Money as markup, with the symbol at reduced emphasis so the number is the hero. */
export function money(amountNgn, { plain = false } = {}) {
  const m = current;
  const value = amountNgn * FROM_NGN[m.code];
  const formatted = new Intl.NumberFormat(m.locale, {
    minimumFractionDigits: m.decimals,
    maximumFractionDigits: m.decimals,
  }).format(value);
  if (plain) return `${m.symbol}${formatted}`;
  return `<span class="sym">${m.symbol}</span>${formatted}`;
}

/* Tax is a REGION property, not a market one — Ontario 13% HST and Alberta 5% GST are the
 * same country. Anything that hardcodes one rate per country will be wrong in Canada. */
export const taxLabel = () => currentRegion.taxLabel;
export const showsTax = () => current.showTax;
export const taxOn = (subtotalNgn) =>
  current.showTax ? Math.round(subtotalNgn * currentRegion.taxRate) : 0;

/** A tax row, or nothing at all in a market that does not display tax separately. */
export function taxRow(subtotalNgn) {
  if (!current.showTax) return '';
  return `<div><dt>${currentRegion.taxLabel} · ${currentRegion.name}</dt>` +
    `<dd>${money(taxOn(subtotalNgn))}</dd></div>`;
}
export const distance = (km) => `${km} ${current.distanceUnit}`;
