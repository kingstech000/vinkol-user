/* MIDNIGHT · Package detail
 * The reference's two-column label/value grid, held inside the accent card so the package
 * identity and its parties read as one object. The horizontal track summarises progress;
 * the event log below carries the detail. */

import { icon, statusBar, money, taxLabel, taxOn } from '../ui.js';
import { activeOrder, rider } from '../../../js/fixtures.js';
import { nav } from './home.js';

export const meta = { dir: 'midnight', id: 'mn-detail', title: 'Package detail', tag: 'data grid' };

export function render() {
  const tax = taxOn(activeOrder.fee);
  const total = activeOrder.fee + activeOrder.protection + tax;

  return `<div class="scr">
    ${statusBar()}
    <div class="scr__body">
      <div class="mn-head">
        <button class="mn-icon" aria-label="Back">${icon('back', 19)}</button>
        <div class="mn-head__t" style="text-align:center"><b style="font-size:17px">Package details</b></div>
        <button class="mn-icon" aria-label="More">${icon('filter', 19)}</button>
      </div>

      <div class="mn-pad">
        <div class="mn-hero">
          <div class="mn-hero__top">
            <div>
              <div class="mn-hero__lab">ID Number</div>
              <div class="mn-hero__id">8F2K-9130</div>
            </div>
            <span class="mn-hero__badge">In delivery</span>
          </div>
          <div class="mn-grid" style="margin-top:24px;position:relative">
            <div><small>Shipper</small><b>Donny Great</b></div>
            <div><small>Recipient</small><b>Julia Roberts</b></div>
            <div><small>From</small><b>Victoria Island, Lagos</b></div>
            <div><small>To</small><b>Alausa, Ikeja</b></div>
            <div><small>Service</small><b>Express bike</b></div>
            <div><small>Weight</small><b>1.3 kg</b></div>
          </div>
        </div>

        <div class="mn-card" style="margin-top:14px">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
            <b style="font-size:16px">Progress</b>
            <span class="mn-rec__st st-live"><i class="mn-rec__dot"></i>3 of 4</span>
          </div>
          <div class="mn-track">
            <span class="mn-track__n mn-track__n--on"></span><span class="mn-track__s mn-track__s--on"></span>
            <span class="mn-track__n mn-track__n--on"></span><span class="mn-track__s mn-track__s--on"></span>
            <span class="mn-track__n mn-track__n--now"></span><span class="mn-track__s"></span>
            <span class="mn-track__n"></span>
          </div>
          <div class="mn-track__ends">
            <div><small>From</small><b>Victoria Island</b></div>
            <div style="text-align:right"><small>To</small><b>Ikeja</b></div>
          </div>
        </div>

        <div class="mn-sec"><b>Status history</b></div>
        <div class="mn-card" style="padding:4px 18px">
          ${ev('Order received', 'Victoria Island', '08:00', '3 Sep', true)}
          ${ev('Ready for dispatch', 'Victoria Island', '10:02', '3 Sep', true)}
          ${ev('Picked up by rider', `${rider.name} · ${rider.vehicle}`, '10:24', '3 Sep', true)}
          ${ev('Out for delivery', 'Estimated 11:05', '10:40', '3 Sep', false)}
        </div>

        <div class="mn-sec"><b>Payment</b></div>
        <div class="mn-card">
          ${row('Delivery fee', money(activeOrder.fee))}
          ${row('Package protection', money(activeOrder.protection))}
          ${row(taxLabel(), money(tax))}
          <div style="height:1px;background:var(--line);margin:14px 0"></div>
          <div style="display:flex;justify-content:space-between;align-items:center">
            <b style="font-size:15px">Total paid</b>
            <b style="font-size:22px;font-variant-numeric:tabular-nums">${money(total)}</b>
          </div>
        </div>

        <div style="display:flex;gap:10px;margin-top:18px">
          <button class="mn-btn mn-btn--q">${icon('receipt', 18)} Receipt</button>
          <button class="mn-btn">${icon('pin', 18)} Track live</button>
        </div>
        <div style="height:22px"></div>
      </div>
    </div>
    ${nav('records')}
  </div>`;
}

function ev(title, meta, time, date, done) {
  return `<div class="mn-ev">
    <span class="mn-ev__d ${done ? 'mn-ev__d--on' : ''}"></span>
    <span class="mn-ev__b"><b>${title}</b><small>${meta}</small></span>
    <span class="mn-ev__t"><b>${time}</b><small>${date}</small></span>
  </div>`;
}

function row(k, v) {
  return `<div style="display:flex;justify-content:space-between;padding:7px 0">
    <span style="font-size:14px;color:var(--txt2)">${k}</span>
    <span style="font-size:14px;font-weight:600;font-variant-numeric:tabular-nums">${v}</span>
  </div>`;
}
