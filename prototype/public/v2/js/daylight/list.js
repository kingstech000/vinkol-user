/* DAYLIGHT · Shipments — chips, then rows. Lighter density than Midnight by design:
 * this register trades rows-per-screen for legibility and calm. */

import { icon, statusBar } from '../ui.js';
import { orders } from '../../../js/fixtures.js';
import { row, nav, tag } from './home.js';

export const meta = { dir: 'daylight', id: 'dl-list', title: 'Shipments', tag: 'list' };

export function render() {
  return `<div class="scr">
    ${statusBar()}
    <div class="scr__body">
      <div class="dl-head">
        <div class="dl-head__t"><h1 class="dl-title">Shipments</h1></div>
        <button class="dl-ico" aria-label="Filter">${icon('filter', 19)}</button>
      </div>

      <div class="dl-pad">
        <div style="display:flex;gap:8px;overflow-x:auto;margin:0 -20px;padding:2px 20px">
          ${chip('All', true)}${chip('In delivery')}${chip('Completed')}${chip('Pending')}${chip('Cancelled')}
        </div>

        <div class="dl-live" style="margin-top:18px">
          <div class="dl-live__top">
            <span class="dl-live__box">${icon('truck', 26)}</span>
            <span class="dl-live__t">
              <small>In delivery</small>
              <b>VK-8F2K-9130</b>
              <p>Victoria Island → Ikeja Mall · arriving 11:05</p>
            </span>
          </div>
          <div class="dl-live__foot">
            <div class="dl-track" style="flex:1;margin:0 12px 0 0">
              <span class="dl-track__n dl-track__n--on"></span><span class="dl-track__s dl-track__s--on"></span>
              <span class="dl-track__n dl-track__n--on"></span><span class="dl-track__s dl-track__s--on"></span>
              <span class="dl-track__n dl-track__n--now"></span><span class="dl-track__s"></span>
              <span class="dl-track__n"></span>
            </div>
            <span style="font-size:12px;font-weight:700;color:var(--acc)">3 / 4</span>
          </div>
        </div>

        <div class="dl-sec"><b>Earlier</b><span style="font-size:13px;color:var(--txt3)">
          ${orders.length - 1} shipments</span></div>
        <div class="dl-rows">${orders.slice(1).map(row).join('')}</div>
        <div style="height:20px"></div>
      </div>
    </div>
    ${nav('package')}
  </div>`;
}

function chip(label, on = false) {
  return `<button class="dl-tag ${on ? 'dl-tag--live' : 'dl-tag--off'}"
    style="flex:none;padding:10px 16px;font-size:13px;border:0;cursor:pointer"
    aria-pressed="${on}">${label}</button>`;
}
