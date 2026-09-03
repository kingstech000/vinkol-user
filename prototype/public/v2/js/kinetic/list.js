/* KINETIC · Shipments — one amber card for the thing in motion, blue-neutral rows for
 * everything settled. The colour split does the sorting before the eye reads a word. */

import { icon, statusBar } from '../ui.js';
import { orders, rider, activeOrder } from '../../../js/fixtures.js';
import { rec, nav } from './home.js';

export const meta = { dir: 'kinetic', id: 'kn-list', title: 'Shipments', tag: 'list' };

export function render() {
  return `<div class="scr">
    ${statusBar()}
    <div class="scr__body">
      <div class="kn-head">
        <div class="kn-head__t"><h1 class="kn-title">Shipments</h1></div>
        <button class="kn-ico" aria-label="Filter">${icon('filter', 19)}</button>
      </div>

      <div class="kn-pad">
        <div style="display:flex;gap:8px;overflow-x:auto;margin:0 -20px;padding:2px 20px 2px">
          ${chip('All', true)}${chip('In delivery')}${chip('Completed')}${chip('Pending')}${chip('Cancelled')}
        </div>

        <div class="kn-sec" style="margin-top:20px"><b>Moving now</b></div>
        <div class="kn-live">
          <div class="kn-live__top">
            <div>
              <span class="kn-live__lab"><i></i>In delivery</span>
              <div class="kn-live__eta">${activeOrder.etaMin}<span>min</span></div>
            </div>
            <span class="kn-live__id">8F2K-9130</span>
          </div>
          <div class="kn-grid" style="margin-top:20px;position:relative">
            <div><small>From</small><b>Victoria Island</b></div>
            <div><small>To</small><b>Ikeja Mall</b></div>
          </div>
          <div class="kn-live__foot">
            <div style="flex:1;min-width:0"><b>${rider.name}</b><small>Picked up 10:24</small></div>
            <button class="kn-live__call" aria-label="Call rider">${icon('phone', 18)}</button>
          </div>
        </div>

        <div class="kn-sec"><b>Settled</b><span style="font-size:13px;color:var(--txt3)">
          ${orders.length - 1} shipments</span></div>
        ${orders.slice(1).map(rec).join('')}
        <div style="height:20px"></div>
      </div>
    </div>
    ${nav('package')}
  </div>`;
}

function chip(l, on = false) {
  return `<button class="kn-tag ${on ? 'kn-tag--live' : 'kn-tag--off'}" aria-pressed="${on}"
    style="flex:none;padding:10px 16px;font-size:13px;border:0;cursor:pointer">${l}</button>`;
}
