/* DAYLIGHT · Tracking — light map, white sheet, the rider first. */

import { icon, statusBar, mapArt } from '../ui.js';
import { rider, activeOrder } from '../../../js/fixtures.js';

export const meta = { dir: 'daylight', id: 'dl-track', title: 'Tracking', tag: 'map' };

export function render() {
  return `<div class="scr">
    <div class="dl-map">${mapArt({ road: '#ffffff', ground: '#e6ebf1', water: '#d5e2ec', route: '#0e74d8' })}</div>
    <div class="dl-pin" style="left:27%;top:28%">${icon('truck', 21)}</div>
    <div class="dl-pin" style="left:77%;top:64%;background:#fff;color:var(--acc)">${icon('home', 20)}</div>

    ${statusBar()}
    <div style="position:absolute;top:52px;left:20px;right:20px;display:flex;justify-content:space-between;z-index:4">
      <button class="dl-ico" aria-label="Back">${icon('back', 19)}</button>
      <button class="dl-ico" aria-label="Recentre">${icon('locate', 19)}</button>
    </div>

    <div class="dl-sheet">
      <div class="dl-grip"></div>

      <div style="display:flex;align-items:baseline;justify-content:space-between">
        <b style="font-size:29px;letter-spacing:-0.8px">${activeOrder.etaMin} min</b>
        <span class="dl-tag dl-tag--live"><i></i>In delivery</span>
      </div>
      <small style="font-size:13px;color:var(--txt3)">Arriving by 11:05 · 4.2 km remaining</small>

      <div class="dl-track" style="margin-top:18px">
        <span class="dl-track__n dl-track__n--on"></span><span class="dl-track__s dl-track__s--on"></span>
        <span class="dl-track__n dl-track__n--on"></span><span class="dl-track__s dl-track__s--on"></span>
        <span class="dl-track__n dl-track__n--now"></span><span class="dl-track__s"></span>
        <span class="dl-track__n"></span>
      </div>
      <div style="display:flex;justify-content:space-between;margin-bottom:18px">
        <div><small style="font-size:11.5px;color:var(--txt3);display:block">From</small>
          <b style="font-size:14.5px">Victoria Island</b></div>
        <div style="text-align:right"><small style="font-size:11.5px;color:var(--txt3);display:block">To</small>
          <b style="font-size:14.5px">Ikeja</b></div>
      </div>

      <div class="dl-card" style="background:var(--surf2);display:flex;align-items:center;gap:13px">
        <span class="dl-av" style="width:46px;height:46px">${rider.initials}</span>
        <span style="flex:1;min-width:0">
          <b style="font-size:15.5px;display:block">${rider.name}</b>
          <small style="font-size:12.5px;color:var(--txt3)">${rider.vehicle} · ${rider.rating} ★</small>
        </span>
        <button class="dl-ico" aria-label="Message">${icon('message', 18)}</button>
        <button class="dl-ico" style="background:var(--acc);color:#fff" aria-label="Call">${icon('phone', 18)}</button>
      </div>

      <button class="dl-btn dl-btn--q" style="margin-top:14px">Something's wrong with this delivery</button>
    </div>
  </div>`;
}
