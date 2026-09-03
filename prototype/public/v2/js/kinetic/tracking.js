/* KINETIC · Tracking — amber route and rider pin because both are in motion; the destination
 * pin is blue because it is fixed. The colour is doing work here, not decoration. */

import { icon, statusBar, mapArt } from '../ui.js';
import { rider, activeOrder } from '../../../js/fixtures.js';

export const meta = { dir: 'kinetic', id: 'kn-track', title: 'Tracking', tag: 'map' };

export function render() {
  return `<div class="scr">
    <div class="kn-map">${mapArt({ road: '#1e2126', ground: '#0d0f11', water: '#0a1014', route: '#ff6b2c' })}</div>
    <div class="kn-pin" style="left:27%;top:28%">${icon('truck', 22)}</div>
    <div class="kn-pin" style="left:77%;top:64%;background:#131518;border-color:#2e8bef;color:#2e8bef">
      ${icon('home', 20)}
    </div>

    ${statusBar()}
    <div style="position:absolute;top:52px;left:20px;right:20px;display:flex;justify-content:space-between;z-index:4">
      <button class="kn-ico" aria-label="Back">${icon('back', 19)}</button>
      <button class="kn-ico" aria-label="Recentre">${icon('locate', 19)}</button>
    </div>

    <div class="kn-sheet">
      <div class="kn-grip"></div>

      <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px">
        <div>
          <span class="kn-tag kn-tag--live"><i></i>In delivery</span>
          <div style="font-size:42px;font-weight:800;letter-spacing:-1.4px;line-height:1;margin-top:11px;
                      font-variant-numeric:tabular-nums">${activeOrder.etaMin}<span
            style="font-size:17px;font-weight:700;margin-left:6px">min away</span></div>
          <div style="font-size:13px;color:var(--txt3);margin-top:7px">Arriving by 11:05 · 4.2 km left</div>
        </div>
        <span class="kn-tag kn-tag--off" style="font-size:11.5px">8F2K-9130</span>
      </div>

      <div class="kn-track" style="margin-top:22px">
        <span class="kn-track__n kn-track__n--on"></span><span class="kn-track__s kn-track__s--on"></span>
        <span class="kn-track__n kn-track__n--on"></span><span class="kn-track__s kn-track__s--on"></span>
        <span class="kn-track__n kn-track__n--now"></span><span class="kn-track__s"></span>
        <span class="kn-track__n"></span>
      </div>
      <div style="display:flex;justify-content:space-between;margin-bottom:20px">
        <div><small style="font-size:11px;color:var(--txt3);display:block">From</small>
          <b style="font-size:14.5px">Victoria Island</b></div>
        <div style="text-align:right"><small style="font-size:11px;color:var(--txt3);display:block">To</small>
          <b style="font-size:14.5px">Ikeja</b></div>
      </div>

      <div class="kn-card" style="background:var(--surf2);display:flex;align-items:center;gap:13px;padding:14px">
        <span class="kn-av" style="width:46px;height:46px;background:var(--surf)">${rider.initials}</span>
        <span style="flex:1;min-width:0">
          <b style="font-size:15.5px;display:block">${rider.name}</b>
          <small style="font-size:12.5px;color:var(--txt3)">${rider.vehicle} · ${rider.rating} ★</small>
        </span>
        <button class="kn-ico" aria-label="Message">${icon('message', 18)}</button>
        <button class="kn-ico" style="background:var(--live);border-color:var(--live);color:#fff"
          aria-label="Call">${icon('phone', 18)}</button>
      </div>

      <button class="kn-btn kn-btn--q" style="margin-top:14px">Something's wrong with this delivery</button>
    </div>
  </div>`;
}
