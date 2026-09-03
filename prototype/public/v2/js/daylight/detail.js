/* DAYLIGHT · Package detail — the reference's Shipper/Recipient/From/To grid on white,
 * with the progress track and the event log beneath. */

import { icon, statusBar, money, taxLabel, taxOn } from '../ui.js';
import { activeOrder, rider } from '../../../js/fixtures.js';
import { nav, tag } from './home.js';

export const meta = { dir: 'daylight', id: 'dl-detail', title: 'Package detail', tag: 'data grid' };

export function render() {
  const tax = taxOn(activeOrder.fee);
  const total = activeOrder.fee + activeOrder.protection + tax;

  return `<div class="scr">
    ${statusBar()}
    <div class="scr__body">
      <div class="dl-head">
        <button class="dl-ico" aria-label="Back">${icon('back', 19)}</button>
        <div class="dl-head__t" style="text-align:center"><b style="font-size:17px">Package detail</b></div>
        <button class="dl-ico" aria-label="Share">${icon('receipt', 19)}</button>
      </div>

      <div class="dl-pad">
        <div class="dl-card">
          <div style="display:flex;align-items:center;gap:12px">
            <span class="dl-row__i" style="background:var(--acc-soft);color:var(--acc)">${icon('package', 20)}</span>
            <span style="flex:1;min-width:0">
              <b style="font-size:17px;letter-spacing:.2px;display:block">VK-8F2K-9130</b>
              <small style="font-size:12.5px;color:var(--txt3)">Electronics · 1.3 kg</small>
            </span>
            ${tag('inTransit')}
          </div>

          <div style="height:1px;background:var(--line);margin:16px 0"></div>

          <div class="dl-grid">
            <div><small>Shipper</small><b>Donny Great</b></div>
            <div><small>Recipient</small><b>Julia Roberts</b></div>
            <div><small>From</small><b>14 Adeola Odeku St, Victoria Island</b></div>
            <div><small>To</small><b>Ikeja City Mall, Alausa</b></div>
            <div><small>Service</small><b>Express bike</b></div>
            <div><small>Weight</small><b>1.3 kg</b></div>
          </div>
        </div>

        <div class="dl-card" style="margin-top:14px">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px">
            <b style="font-size:16px">Progress</b>
            <span style="font-size:13px;font-weight:700;color:var(--acc)">3 of 4</span>
          </div>
          <div class="dl-track">
            <span class="dl-track__n dl-track__n--on"></span><span class="dl-track__s dl-track__s--on"></span>
            <span class="dl-track__n dl-track__n--on"></span><span class="dl-track__s dl-track__s--on"></span>
            <span class="dl-track__n dl-track__n--now"></span><span class="dl-track__s"></span>
            <span class="dl-track__n"></span>
          </div>
          <div style="display:flex;justify-content:space-between">
            <div><small style="font-size:11.5px;color:var(--txt3);display:block">From</small>
              <b style="font-size:14.5px">Victoria Island</b></div>
            <div style="text-align:right"><small style="font-size:11.5px;color:var(--txt3);display:block">To</small>
              <b style="font-size:14.5px">Ikeja</b></div>
          </div>
        </div>

        <div class="dl-sec"><b>Rider</b></div>
        <div class="dl-card" style="display:flex;align-items:center;gap:13px">
          <span class="dl-av" style="width:46px;height:46px">${rider.initials}</span>
          <span style="flex:1;min-width:0">
            <b style="font-size:15.5px;display:block">${rider.name}</b>
            <small style="font-size:12.5px;color:var(--txt3)">${rider.rating} ★ · ${rider.trips.toLocaleString()} trips</small>
          </span>
          <button class="dl-ico" aria-label="Message">${icon('message', 18)}</button>
          <button class="dl-ico" style="background:var(--acc);color:#fff" aria-label="Call">${icon('phone', 18)}</button>
        </div>

        <div class="dl-sec"><b>Payment</b></div>
        <div class="dl-card">
          ${ln('Delivery fee', money(activeOrder.fee))}
          ${ln('Package protection', money(activeOrder.protection))}
          ${ln(taxLabel(), money(tax))}
          <div style="height:1px;background:var(--line);margin:13px 0"></div>
          <div style="display:flex;justify-content:space-between;align-items:center">
            <b style="font-size:15px">Total paid</b>
            <b style="font-size:22px;font-variant-numeric:tabular-nums">${money(total)}</b>
          </div>
        </div>

        <div style="display:flex;gap:10px;margin-top:18px">
          <button class="dl-btn dl-btn--q">Receipt</button>
          <button class="dl-btn">${icon('pin', 17)} Track live</button>
        </div>
        <div style="height:22px"></div>
      </div>
    </div>
    ${nav('package')}
  </div>`;
}

function ln(k, v) {
  return `<div style="display:flex;justify-content:space-between;padding:6px 0">
    <span style="font-size:14px;color:var(--txt2)">${k}</span>
    <span style="font-size:14px;font-weight:600;font-variant-numeric:tabular-nums">${v}</span></div>`;
}
