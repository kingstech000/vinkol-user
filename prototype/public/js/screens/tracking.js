/* The screen the app does not have today, and the reason the Line signature exists.
 * Hierarchy answers, in order: where is it, who has it, when does it arrive, what next,
 * how do I get help. No pod here — nothing competes with the live state. */

import { statusBar, map, line, status } from '../components.js';
import { icon } from '../icons.js';
import { rider, activeOrder } from '../fixtures.js';

export const meta = { id: 'tracking', title: 'Live tracking', group: 'Core', tag: 'hero+ops' };

export function render() {
  return `<div class="screen">
    ${map({
      route: true,
      pins: [
        { x: 28, y: 29 },
        { x: 52, y: 44, label: `${activeOrder.etaMin} min away` },
        { x: 77, y: 65 },
      ],
    })}
    ${statusBar()}

    <div style="position:absolute;top:52px;left:var(--page-margin);right:var(--page-margin);
                z-index:3;display:flex;justify-content:space-between">
      <button class="btn-icon" aria-label="Back">${icon('back', 18)}</button>
      <button class="btn-icon" aria-label="Map layers">${icon('layers', 18)}</button>
    </div>

    <div class="sheet" style="max-height:64%">
      <div class="sheet__grip"></div>
      <div class="sheet__body">
        <div class="hstack" style="justify-content:space-between;align-items:flex-start">
          <div>
            ${status(activeOrder.status)}
            <div class="t-display-s c-primary mt-sm">${activeOrder.etaMin} min</div>
            <div class="t-body-s c-secondary">Arriving by 11:05</div>
          </div>
          <div class="t-mono c-tertiary" style="text-align:right">${activeOrder.ref}</div>
        </div>

        <hr class="divider mt-lg" />

        <div class="mt-lg">
          ${line([
            { title: 'Order placed', meta: '10:02', state: 'done' },
            { title: 'Picked up · Victoria Island', meta: '10:24', state: 'done' },
            { title: 'On the way', meta: `${activeOrder.etaMin} min to destination`, state: 'active' },
            { title: 'Ikeja City Mall', meta: 'Alausa', state: 'future' },
          ])}
        </div>

        <hr class="divider mt-lg" />

        <div class="hstack gap-md mt-lg">
          <div class="avatar">${rider.initials}</div>
          <div class="grow">
            <div class="hstack gap-sm">
              <span class="t-h4 c-primary">${rider.name}</span>
              ${
                rider.verified
                  ? `<span class="hstack gap-xs t-caption" style="color:var(--success)">
                       ${icon('shield', 13)} Verified</span>`
                  : ''
              }
            </div>
            <div class="t-body-s c-secondary">
              ${rider.vehicle} · ${rider.rating} ★ · ${rider.trips.toLocaleString()} trips
            </div>
          </div>
          <button class="btn-icon" aria-label="Message rider">${icon('message', 18)}</button>
          <button class="btn-icon" aria-label="Call rider">${icon('phone', 18)}</button>
        </div>

        <button class="btn btn--secondary btn--block mt-xl">Something's wrong with this delivery</button>
      </div>
    </div>
  </div>`;
}
