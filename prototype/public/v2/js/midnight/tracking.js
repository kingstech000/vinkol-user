/* MIDNIGHT · Tracking
 * Dark map, blue route, the rider reachable in one tap, the horizontal track repeating the
 * geometry from the detail screen, then the event log. Same components, different scale —
 * that repetition is what makes a system read as one product. */

import { icon, statusBar, mapArt } from '../ui.js';
import { rider, activeOrder } from '../../../js/fixtures.js';

export const meta = { dir: 'midnight', id: 'mn-track', title: 'Tracking', tag: 'map' };

export function render() {
  return `<div class="scr">
    <div class="mn-map">${mapArt({ road: '#20242a', ground: '#101215', water: '#0c1319', route: '#2e8bef' })}</div>
    <div class="mn-pin" style="left:27%;top:28%">${icon('truck', 22)}</div>
    <div class="mn-pin" style="left:77%;top:64%;background:#16181c;border-color:#2e8bef;color:#2e8bef">
      ${icon('home', 20)}
    </div>

    ${statusBar('')}
    <div style="position:absolute;top:52px;left:22px;right:22px;display:flex;justify-content:space-between;z-index:4">
      <button class="mn-icon" aria-label="Back">${icon('back', 19)}</button>
      <button class="mn-icon" aria-label="Recentre">${icon('locate', 19)}</button>
    </div>

    <div class="mn-sheet">
      <div class="mn-grip"></div>

      <div style="display:flex;align-items:center;gap:13px">
        <div class="mn-head__av" style="width:48px;height:48px">${rider.initials}</div>
        <div style="flex:1;min-width:0">
          <b style="font-size:17px;display:block">${rider.name}</b>
          <small style="font-size:12.5px;color:var(--txt3)">${rider.vehicle} · ${rider.rating} ★</small>
        </div>
        <button class="mn-icon" style="background:var(--acc);border-color:var(--acc);color:#fff"
          aria-label="Call rider">${icon('phone', 19)}</button>
        <button class="mn-icon" aria-label="Message rider">${icon('message', 19)}</button>
      </div>

      <div style="display:flex;align-items:baseline;justify-content:space-between;margin:22px 0 4px">
        <b style="font-size:30px;letter-spacing:-0.8px">${activeOrder.etaMin} min</b>
        <span class="mn-rec__st st-live"><i class="mn-rec__dot"></i>In delivery</span>
      </div>
      <small style="font-size:13px;color:var(--txt3)">Arriving by 11:05 · 4.2 km remaining</small>

      <div class="mn-track" style="margin-top:20px">
        <span class="mn-track__n mn-track__n--on"></span><span class="mn-track__s mn-track__s--on"></span>
        <span class="mn-track__n mn-track__n--on"></span><span class="mn-track__s mn-track__s--on"></span>
        <span class="mn-track__n mn-track__n--now"></span><span class="mn-track__s"></span>
        <span class="mn-track__n"></span>
      </div>
      <div class="mn-track__ends">
        <div><small>From</small><b>Victoria Island</b></div>
        <div style="text-align:right"><small>To</small><b>Ikeja</b></div>
      </div>

      <div style="height:1px;background:var(--line);margin:20px 0 4px"></div>

      <div class="mn-ev">
        <span class="mn-ev__d mn-ev__d--on"></span>
        <span class="mn-ev__b"><b>Picked up</b><small>Victoria Island</small></span>
        <span class="mn-ev__t"><b>10:24</b><small>3 Sep</small></span>
      </div>
      <div class="mn-ev">
        <span class="mn-ev__d mn-ev__d--on"></span>
        <span class="mn-ev__b"><b>Out for delivery</b><small>On Third Mainland Bridge</small></span>
        <span class="mn-ev__t"><b>10:40</b><small>3 Sep</small></span>
      </div>

      <button class="mn-btn mn-btn--q" style="margin-top:16px">Something's wrong with this delivery</button>
    </div>
  </div>`;
}
