/* KINETIC · Package detail — amber header while in motion, blue body for the settled facts.
 * When this shipment completes, the header turns blue and nothing else changes. */

import { icon, statusBar, money, taxLabel, taxOn } from '../ui.js';
import { activeOrder, rider } from '../../../js/fixtures.js';
import { nav } from './home.js';

export const meta = { dir: 'kinetic', id: 'kn-detail', title: 'Package detail', tag: 'data grid' };

export function render() {
  const tax = taxOn(activeOrder.fee);
  const total = activeOrder.fee + activeOrder.protection + tax;

  return `<div class="scr">
    ${statusBar()}
    <div class="scr__body">
      <div class="kn-head">
        <button class="kn-ico" aria-label="Back">${icon('back', 19)}</button>
        <div class="kn-head__t" style="text-align:center"><b style="font-size:17px">Package detail</b></div>
        <button class="kn-ico" aria-label="More">${icon('receipt', 19)}</button>
      </div>

      <div class="kn-pad">
        <div class="kn-live">
          <div class="kn-live__top">
            <div>
              <span class="kn-live__lab"><i></i>In delivery</span>
              <div class="kn-live__eta">${activeOrder.etaMin}<span>min</span></div>
              <div class="kn-live__sub">Arriving by 11:05</div>
            </div>
            <span class="kn-live__id">8F2K-9130</span>
          </div>
          <div class="kn-grid" style="margin-top:22px;position:relative">
            <div><small>Shipper</small><b>Donny Great</b></div>
            <div><small>Recipient</small><b>Julia Roberts</b></div>
            <div><small>From</small><b>Victoria Island</b></div>
            <div><small>To</small><b>Alausa, Ikeja</b></div>
          </div>
        </div>

        <div class="kn-card" style="margin-top:14px">
          <div class="kn-grid">
            <div><small>Service</small><b>Express bike</b></div>
            <div><small>Weight</small><b>1.3 kg</b></div>
            <div><small>Contents</small><b>Electronics</b></div>
            <div><small>Declared value</small><b>${money(activeOrder.itemValue, { plain: true })}</b></div>
          </div>
          <div style="height:1px;background:var(--line);margin:18px 0 16px"></div>
          <div class="kn-track">
            <span class="kn-track__n kn-track__n--on"></span><span class="kn-track__s kn-track__s--on"></span>
            <span class="kn-track__n kn-track__n--on"></span><span class="kn-track__s kn-track__s--on"></span>
            <span class="kn-track__n kn-track__n--now"></span><span class="kn-track__s"></span>
            <span class="kn-track__n"></span>
          </div>
          <div style="display:flex;justify-content:space-between">
            <div><small style="font-size:11px;color:var(--txt3);display:block">From</small>
              <b style="font-size:14.5px">Victoria Island</b></div>
            <div style="text-align:right"><small style="font-size:11px;color:var(--txt3);display:block">To</small>
              <b style="font-size:14.5px">Ikeja</b></div>
          </div>
        </div>

        <div class="kn-sec"><b>Status history</b></div>
        <div class="kn-card" style="padding:4px 18px">
          ${ev('Order received', 'Victoria Island', '08:00', true, false)}
          ${ev('Ready for dispatch', 'Victoria Island', '10:02', true, false)}
          ${ev('Picked up', `${rider.name} · ${rider.vehicle}`, '10:24', true, false)}
          ${ev('Out for delivery', 'On Third Mainland Bridge', '10:40', false, true)}
        </div>

        <div class="kn-sec"><b>Payment</b></div>
        <div class="kn-card">
          ${ln('Delivery fee', money(activeOrder.fee))}
          ${ln('Package protection', money(activeOrder.protection))}
          ${ln(taxLabel(), money(tax))}
          <div style="height:1px;background:var(--line);margin:14px 0"></div>
          <div style="display:flex;justify-content:space-between;align-items:center">
            <b style="font-size:15px">Total paid</b>
            <b style="font-size:23px;font-variant-numeric:tabular-nums">${money(total)}</b>
          </div>
        </div>

        <div style="display:flex;gap:10px;margin-top:18px">
          <button class="kn-btn kn-btn--q">Receipt</button>
          <button class="kn-btn kn-btn--live">${icon('pin', 17)} Track live</button>
        </div>
        <div style="height:22px"></div>
      </div>
    </div>
    ${nav('package')}
  </div>`;
}

function ev(t, m, time, done, now) {
  return `<div class="kn-ev">
    <span class="kn-ev__d ${now ? 'kn-ev__d--now' : done ? 'kn-ev__d--on' : ''}"></span>
    <span class="kn-ev__b"><b>${t}</b><small>${m}</small></span>
    <span class="kn-ev__t"><b>${time}</b><small>3 Sep</small></span>
  </div>`;
}

function ln(k, v) {
  return `<div style="display:flex;justify-content:space-between;padding:7px 0">
    <span style="font-size:14px;color:var(--txt2)">${k}</span>
    <span style="font-size:14px;font-weight:600;font-variant-numeric:tabular-nums">${v}</span></div>`;
}
