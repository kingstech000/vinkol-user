/* MIDNIGHT · Home
 * One saturated object owns the screen — the shipment in flight. Everything else is quiet
 * dark surface. This is the answer to "it felt generic": the live thing is unmissable. */

import { icon, statusBar, money } from '../ui.js';
import { orders } from '../../../js/fixtures.js';

export const meta = { dir: 'midnight', id: 'mn-home', title: 'Home', tag: 'hero card' };

export function render() {
  const recent = orders.slice(1, 4).map(rec).join('');
  return `<div class="scr">
    ${statusBar()}
    <div class="scr__body">
      <div class="mn-head">
        <div class="mn-head__av">EO</div>
        <div class="mn-head__t"><small>Tuesday, 3 September</small><b>Hello, Emeka</b></div>
        <button class="mn-icon" aria-label="Scan">${icon('search', 19)}</button>
        <button class="mn-icon" aria-label="Alerts">${icon('inbox', 19)}</button>
      </div>

      <div class="mn-pad">
        <div class="mn-hero">
          <div class="mn-hero__top">
            <div>
              <div class="mn-hero__lab">In flight now</div>
              <div class="mn-hero__id">VK-8F2K-9130</div>
            </div>
            <span class="mn-hero__badge">12 min away</span>
          </div>
          <div class="mn-hero__route">
            <div><small>From</small><b>Victoria Island</b></div>
            <span class="mn-hero__arrow"></span>
            <div style="text-align:right"><small>To</small><b>Ikeja Mall</b></div>
          </div>
        </div>

        <div class="mn-sec"><b>Quick actions</b></div>
        <div class="mn-acts">
          ${act('plus', 'Send')}${act('pin', 'Track')}${act('receipt', 'Rates')}${act('store', 'Agents')}
        </div>

        <div class="mn-sec"><b>Recent</b><button>See all</button></div>
        ${recent}
        <div style="height:20px"></div>
      </div>
    </div>
    ${nav('home')}
  </div>`;
}

function act(i, label) {
  return `<button class="mn-act"><i>${icon(i, 22)}</i><span>${label}</span></button>`;
}

const ST = {
  inTransit: ['st-live', 'In Delivery', ''],
  findingRider: ['st-live', 'Finding rider', 'mn-rec__dot--ring'],
  awaitingPayment: ['st-wait', 'Unpaid', 'mn-rec__dot--ring'],
  delivered: ['st-done', 'Completed', ''],
  failed: ['st-bad', 'Failed', 'mn-rec__dot--sq'],
  cancelled: ['st-off', 'Cancelled', 'mn-rec__dot--sq'],
};

export function rec(o) {
  const [cls, label, dot] = ST[o.status] || ST.delivered;
  return `<button class="mn-rec">
    <div class="mn-rec__top">
      <span class="mn-rec__box">${icon('package', 19)}</span>
      <span class="mn-rec__id"><small>ID Number</small><b>${o.ref.replace('VK-', '')}</b></span>
      <span class="mn-rec__st ${cls}"><i class="mn-rec__dot ${dot}"></i>${label}</span>
    </div>
    <div class="mn-rec__route">
      <div><small>${o.when}</small><b>${o.from}</b></div>
      <span class="mn-rec__line"></span>
      <div style="text-align:right"><small>${money(o.amount, { plain: true })}</small><b>${o.to}</b></div>
    </div>
  </button>`;
}

export function nav(active) {
  const items = [['home', 'Home'], ['package', 'Records'], ['inbox', 'Alerts'], ['user', 'Profile']];
  return `<nav class="mn-nav">${items
    .map(([i, l]) => `<button aria-current="${i === active || (active === 'records' && i === 'package')}">
      ${icon(i, 22)}<span>${l}</span></button>`)
    .join('')}</nav>`;
}
