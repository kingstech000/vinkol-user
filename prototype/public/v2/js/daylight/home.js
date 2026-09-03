/* DAYLIGHT · Home — the SwiftShip register: greeting, search, rewards, circular actions,
 * then the live shipment. Warmer and more consumer than Midnight; same information. */

import { icon, statusBar, money } from '../ui.js';
import { orders } from '../../../js/fixtures.js';

export const meta = { dir: 'daylight', id: 'dl-home', title: 'Home', tag: 'consumer' };

const ST = {
  inTransit: ['live', 'In delivery'], findingRider: ['live', 'Finding rider'],
  awaitingPayment: ['wait', 'Unpaid'], delivered: ['done', 'Completed'],
  failed: ['bad', 'Failed'], cancelled: ['off', 'Cancelled'],
};

export function tag(status) {
  const [k, label] = ST[status] || ST.delivered;
  return `<span class="dl-tag dl-tag--${k}"><i></i>${label}</span>`;
}

export function row(o) {
  return `<button class="dl-row">
    <span class="dl-row__i">${icon('package', 19)}</span>
    <span class="dl-row__b"><b>${o.from} → ${o.to}</b><small>${o.ref} · ${o.when}</small></span>
    ${tag(o.status)}
  </button>`;
}

export function nav(active) {
  const items = [['home', 'Home'], ['package', 'Shipments'], ['wallet', 'Wallet'], ['user', 'Profile']];
  return `<nav class="dl-nav">${items
    .map(([i, l]) => `<button aria-current="${i === active}">${icon(i, 22)}<span>${l}</span></button>`)
    .join('')}</nav>`;
}

export function render() {
  return `<div class="scr">
    ${statusBar()}
    <div class="scr__body">
      <div class="dl-head">
        <div class="dl-av">EO</div>
        <div class="dl-head__t"><small>Tuesday, 3 September</small><b>Hello, Emeka</b></div>
        <button class="dl-ico" aria-label="Notifications">${icon('inbox', 19)}</button>
      </div>

      <div class="dl-pad">
        <div class="dl-search">${icon('search', 19)}
          <input placeholder="Track a package" value="" /> ${icon('filter', 18)}
        </div>

        <div class="dl-streak" style="margin-top:14px">
          <i>${icon('star', 20)}</i>
          <div class="dl-streak__b">
            <b>4 of 6 deliveries</b>
            <small>Two more this month unlocks free protection</small>
            <div class="dl-bar"><i style="width:66%"></i></div>
          </div>
        </div>

        <div class="dl-sec" style="margin-top:24px"><b>What do you need?</b></div>
        <div class="dl-acts">
          ${act('plus', 'Send')}${act('pin', 'Track')}${act('receipt', 'Rates')}${act('store', 'Agents')}
        </div>

        <div class="dl-sec"><b>In flight</b><button>See all</button></div>
        <div class="dl-live">
          <div class="dl-live__top">
            <span class="dl-live__box">${icon('truck', 26)}</span>
            <span class="dl-live__t">
              <small>Arriving in 12 min</small>
              <b>Victoria Island → Ikeja Mall</b>
              <p>Emeka has your package and is 4.2 km away.</p>
            </span>
          </div>
          <div class="dl-live__foot">
            <span style="font-size:13px;color:var(--txt2);font-weight:600">VK-8F2K-9130</span>
            <button class="dl-pill">${icon('pin', 16)} Live tracking</button>
          </div>
        </div>

        <div class="dl-sec"><b>Recent</b><button>See all</button></div>
        <div class="dl-rows">${orders.slice(1, 5).map(row).join('')}</div>
        <div style="height:20px"></div>
      </div>
    </div>
    ${nav('home')}
  </div>`;
}

function act(i, label) {
  return `<button class="dl-act"><i>${icon(i, 21)}</i><span>${label}</span></button>`;
}
