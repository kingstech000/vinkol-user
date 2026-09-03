/* MIDNIGHT · Delivery records
 * Filter chips, then records. The one in flight is promoted to the saturated card so the
 * list has a subject rather than being eight equal rows. Direct lift of the reference's
 * best idea — the selected record as a full accent surface. */

import { icon, statusBar, money } from '../ui.js';
import { orders } from '../../../js/fixtures.js';
import { rec, nav } from './home.js';

export const meta = { dir: 'midnight', id: 'mn-list', title: 'Delivery records', tag: 'list' };

export function render() {
  const live = orders[0];
  const rest = orders.slice(1).map(rec).join('');

  return `<div class="scr">
    ${statusBar()}
    <div class="scr__body">
      <div class="mn-head">
        <div class="mn-head__t"><h1 class="mn-title">Delivery records</h1></div>
        <button class="mn-icon" aria-label="Filter">${icon('filter', 19)}</button>
      </div>

      <div class="mn-pad">
        <div class="mn-chips">
          <button class="mn-chip" aria-pressed="true">All</button>
          <button class="mn-chip">In delivery</button>
          <button class="mn-chip">Completed</button>
          <button class="mn-chip">Pending</button>
          <button class="mn-chip">Cancelled</button>
        </div>

        <div class="mn-hero" style="margin-top:18px">
          <div class="mn-hero__top">
            <div>
              <div class="mn-hero__lab">ID Number</div>
              <div class="mn-hero__id">${live.ref.replace('VK-', '')}</div>
            </div>
            <span class="mn-hero__badge">In delivery</span>
          </div>
          <div class="mn-hero__route">
            <div><small>14 Jul, 2026</small><b>${live.from}</b></div>
            <span class="mn-hero__arrow"></span>
            <div style="text-align:right"><small>18 Jul, 2026</small><b>${live.to}</b></div>
          </div>
        </div>

        <div class="mn-sec"><b>Earlier</b><span style="font-size:13px;color:var(--txt3)">
          ${orders.length - 1} records</span></div>
        ${rest}
        <div style="height:20px"></div>
      </div>
    </div>
    ${nav('records')}
  </div>`;
}
