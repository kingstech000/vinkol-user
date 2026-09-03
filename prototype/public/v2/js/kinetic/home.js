/* KINETIC · Home
 * The ETA is the largest thing on the screen because it is the only number the user opened
 * the app for. Amber marks it as moving; everything settled stays blue. */

import { icon, statusBar, money } from '../ui.js';
import { orders, rider, activeOrder } from '../../../js/fixtures.js';

export const meta = { dir: 'kinetic', id: 'kn-home', title: 'Home', tag: 'dual accent' };

const ST = {
  inTransit: ['live', 'In delivery'], findingRider: ['live', 'Finding rider'],
  awaitingPayment: ['wait', 'Unpaid'], delivered: ['done', 'Completed'],
  failed: ['bad', 'Failed'], cancelled: ['off', 'Cancelled'],
};

export function tag(s) {
  const [k, l] = ST[s] || ST.delivered;
  return `<span class="kn-tag kn-tag--${k}"><i></i>${l}</span>`;
}

export function rec(o) {
  const isLive = o.status === 'inTransit' || o.status === 'findingRider';
  return `<button class="kn-rec">
    <span class="kn-rec__i ${isLive ? 'kn-rec__i--live' : ''}">${icon('package', 20)}</span>
    <span class="kn-rec__b"><b>${o.from} → ${o.to}</b>
      <small>${o.ref} · ${o.when} · ${money(o.amount, { plain: true })}</small></span>
    ${tag(o.status)}
  </button>`;
}

export function nav(active) {
  const items = [['home', 'Home'], ['package', 'Shipments'], ['inbox', 'Alerts'], ['user', 'Profile']];
  return `<nav class="kn-nav">${items
    .map(([i, l]) => `<button aria-current="${i === active}">${icon(i, 22)}<span>${l}</span></button>`)
    .join('')}</nav>`;
}

export function render() {
  return `<div class="scr">
    ${statusBar()}
    <div class="scr__body">
      <div class="kn-head">
        <div class="kn-av">EO</div>
        <div class="kn-head__t"><small>3 September 2026</small><b>Emeka Obi</b></div>
        <div class="kn-points"><i>${icon('star', 17)}</i>
          <div><small>Points</small><b>4,251</b></div></div>
      </div>

      <div class="kn-pad">
        <div class="kn-search">${icon('search', 19)}
          <input placeholder="Track a package" /> ${icon('package', 18)}
        </div>

        <div class="kn-live" style="margin-top:16px">
          <div class="kn-live__top">
            <div>
              <span class="kn-live__lab"><i></i>Arriving now</span>
              <div class="kn-live__eta">${activeOrder.etaMin}<span>min</span></div>
              <div class="kn-live__sub">Victoria Island → Ikeja Mall · 4.2 km left</div>
            </div>
            <span class="kn-live__id">8F2K-9130</span>
          </div>
          <div class="kn-live__foot">
            <div style="flex:1;min-width:0">
              <b>${rider.name}</b><small>${rider.vehicle}</small>
            </div>
            <button class="kn-live__call" aria-label="Message rider">${icon('message', 18)}</button>
            <button class="kn-live__call" aria-label="Call rider">${icon('phone', 18)}</button>
          </div>
        </div>

        <div class="kn-sec"><b>Send something</b></div>
        <div class="kn-acts">
          ${act('plus', 'New')}${act('receipt', 'Rates')}${act('store', 'Agents')}${act('shield', 'Claims')}
        </div>

        <div class="kn-sec"><b>Recent shipments</b><button>See all</button></div>
        ${orders.slice(1, 5).map(rec).join('')}
        <div style="height:20px"></div>
      </div>
    </div>
    ${nav('home')}
  </div>`;
}

function act(i, l) {
  return `<button class="kn-act"><i>${icon(i, 22)}</i><span>${l}</span></button>`;
}
