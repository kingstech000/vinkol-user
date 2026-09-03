/* Shared chrome and components for the Vinkol prototype.
 * Anything with data-go="<screen-id>" navigates; data-go="back" returns. That single
 * convention is what makes the whole prototype clickable — no per-screen wiring. */

export { icon } from '../../js/icons.js';
/* The market layer is the redesign's whole purpose, so everything it decides is exported.
 * `taxRow` renders nothing in a market that does not display tax separately — Nigeria today —
 * and a real row in one that must, so switching market changes structure, not just glyphs. */
export { money, setMarket, market, region, setRegion, taxLabel, taxOn, showsTax, taxRow }
  from '../../js/market.js';
import { MARKETS } from '../../js/market.js';
export const MARKETS_LIST = Object.values(MARKETS);
import { icon } from '../../js/icons.js';

export const go = (id) => `data-go="${id}"`;

export function statusBar() {
  return `<div class="sb">
    <span>9:41</span>
    <span class="sb__r">
      <svg width="17" height="11" viewBox="0 0 17 11" fill="currentColor"><rect y="7" width="3" height="4" rx="1"/>
        <rect x="4.5" y="5" width="3" height="6" rx="1"/><rect x="9" y="2.5" width="3" height="8.5" rx="1"/>
        <rect x="13.5" width="3" height="11" rx="1"/></svg>
      <svg width="16" height="12" viewBox="0 0 16 12" fill="none" stroke="currentColor" stroke-width="1.3">
        <path d="M1 4.5a10 10 0 0 1 14 0M3.5 7.2a6.5 6.5 0 0 1 9 0"/>
        <circle cx="8" cy="10" r="1" fill="currentColor"/></svg>
      <svg width="25" height="12" viewBox="0 0 25 12" fill="none" stroke="currentColor">
        <rect x=".6" y=".6" width="20" height="10.8" rx="3" stroke-width="1.1" opacity=".45"/>
        <rect x="2.3" y="2.3" width="15.5" height="7.4" rx="1.8" fill="currentColor" stroke="none"/>
        <path d="M22.6 4.3v3.4" stroke-width="2" stroke-linecap="round" opacity=".45"/></svg>
    </span></div>`;
}

/** Back + centred title. */
export function bar(title, right = '') {
  return `<div class="top">
    <button class="ico" data-go="back" aria-label="Back">${icon('back', 19)}</button>
    <div class="top__t" style="text-align:center"><b style="font-size:17px">${title}</b></div>
    ${right || '<span style="width:42px;flex:none"></span>'}</div>`;
}

/** Large screen title, no back. */
export function title(t, right = '') {
  return `<div class="top"><div class="top__t"><h1>${t}</h1></div>${right}</div>`;
}

const NAV = [
  ['home', 'Home', 'home'],
  ['shop', 'Shop', 'store'],
  ['records', 'Records', 'package'],
  ['wallet', 'Wallet', 'wallet'],
  ['profile', 'Profile', 'user'],
];

/** The floating pod. Nav at rest; the active tab expands into a pill so the selected state
 *  has shape as well as colour. This is the app's existing black floating bar, evolved. */
export function nav(active) {
  return `<nav class="pod">${NAV.map(
    ([id, label, ic]) => `<button ${go(id)} aria-current="${id === active}" aria-label="${label}">
      ${icon(ic, 21)}<span>${label}</span></button>`
  ).join('')}</nav>`;
}

/* The complete status vocabulary, from the switch in delivery_item.dart. There is no
 * "finding a rider", "at pickup", "preparing" or "refunded" state in this API. */
const ST = {
  pending: ['wait', 'Pending'],
  'with rider': ['live', 'With rider'],
  'with shopper': ['live', 'With shopper'],
  delivered: ['done', 'Delivered'],
  cancelled: ['off', 'Cancelled'],
  unattended: ['bad', 'Unattended'],
};

/** Status is always label + shape + colour — never colour alone (decision D-05). */
export function st(key) {
  const [k, label] = ST[key] || ST.pending;
  return `<span class="st st--${k}"><i></i>${label}</span>`;
}

export function track(done, total = 4) {
  let h = '';
  for (let i = 0; i < total; i++) {
    const cls = i < done - 1 ? 'trk__n--on' : i === done - 1 ? 'trk__n--now' : '';
    h += `<span class="trk__n ${cls}"></span>`;
    if (i < total - 1) h += `<span class="trk__s ${i < done - 1 ? 'trk__s--on' : ''}"></span>`;
  }
  return `<div class="trk">${h}</div>`;
}

export function trackEnds(from, to) {
  return `<div class="trk__e"><div><small>From</small><b>${from}</b></div>
    <div style="text-align:right"><small>To</small><b>${to}</b></div></div>`;
}

export function ev(t, meta, time, date, done) {
  return `<div class="ev"><span class="ev__d ${done ? 'ev__d--on' : ''}"></span>
    <span class="ev__b"><b>${t}</b><small>${meta}</small></span>
    <span class="ev__t"><b>${time}</b><small>${date}</small></span></div>`;
}

export function row({ icon: ic, title, meta, value, sub, to, chevron = true, accent = false }) {
  return `<button class="row" ${to ? go(to) : ''}>
    ${ic ? `<span class="row__i ${accent ? 'row__i--acc' : ''}">${icon(ic, 19)}</span>` : ''}
    <span class="row__b"><b>${title}</b>${meta ? `<small>${meta}</small>` : ''}</span>
    ${value ? `<span class="row__v"><b>${value}</b>${sub ? `<small>${sub}</small>` : ''}</span>` : ''}
    ${chevron && !value ? `<span class="row__c">${icon('chevron', 16)}</span>` : ''}</button>`;
}

/** Map art. `me` places the pulsing current-location dot, as the live app does. */
export function mapArt({ route = false, routes = null } = {}) {
  const road = 'var(--map-road)';
  return `<svg viewBox="0 0 390 700" preserveAspectRatio="xMidYMid slice">
    <rect width="390" height="700" fill="var(--map-ground)"/>
    <path d="M-20 520 200 470 410 500 410 660-20 680Z" fill="var(--map-water)"/>
    <g stroke="${road}" fill="none">
      <path d="M-10 120H400" stroke-width="13"/><path d="M-10 300H400" stroke-width="19"/>
      <path d="M-10 450H400" stroke-width="9"/><path d="M70-10V710" stroke-width="15"/>
      <path d="M250-10V710" stroke-width="11"/><path d="M340-10V710" stroke-width="7"/>
      <path d="M-10 210H180L250 150" stroke-width="7"/></g>
    <g fill="${road}" opacity=".5">
      <rect x="95" y="145" width="60" height="40" rx="4"/><rect x="170" y="145" width="55" height="40" rx="4"/>
      <rect x="95" y="330" width="48" height="52" rx="4"/><rect x="160" y="330" width="70" height="52" rx="4"/>
      <rect x="270" y="330" width="52" height="52" rx="4"/><rect x="95" y="230" width="70" height="42" rx="4"/></g>
    ${route ? `<path d="M105 195C150 200 150 255 200 300s65 100 100 152" stroke="var(--acc)" stroke-width="5"
      fill="none" stroke-linecap="round"/>` : ''}
    ${(routes || []).map((r) => `<path d="${r.d}" stroke="var(--${r.color})" stroke-width="4.5"
      fill="none" stroke-linecap="round" opacity=".95"/>`).join('')}
  </svg>`;
}

/** The five batch-order hues, mirroring _orderColors in multi_map_with_quote_screen.dart. */
export const ORDER_COLORS = ['o1', 'o2', 'o3', 'o4', 'o5'];

export function sp(h = 24) { return `<div style="height:${h}px"></div>`; }
