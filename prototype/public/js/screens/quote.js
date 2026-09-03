/* Map + sheet. The price is visible before the commitment, itemised on the next screen.
 * Vehicle options are rows, not cards: three cards would make the choice feel heavier than
 * it is, and rows keep all three plus the price in one glance. */

import { statusBar, map, line, moneyLine } from '../components.js';
import { icon } from '../icons.js';
import { money, distance } from '../market.js';
import { vehicles, activeOrder } from '../fixtures.js';

export const meta = { id: 'quote', title: 'Quote', group: 'Core', tag: 'map' };

export function render() {
  const options = vehicles
    .map(
      (v) => `<button class="row" aria-current="${!!v.selected}"
        style="${v.selected ? 'background:var(--brand-subtle)' : ''}">
        <span class="row__icon" style="${v.selected ? 'background:var(--brand);color:var(--on-brand)' : ''}">
          ${icon(v.id === 'bike' ? 'truck' : v.id === 'car' ? 'package' : 'store', 18)}
        </span>
        <span class="row__body">
          <span class="row__title">${v.label}</span>
          <span class="row__meta">${v.meta}</span>
        </span>
        <span class="row__value">
          <span class="t-num c-primary" style="display:block">${money(v.price)}</span>
          <span class="t-caption c-tertiary">${v.eta}</span>
        </span>
      </button>`
    )
    .join('');

  return `<div class="screen">
    ${map({
      route: true,
      pins: [
        { x: 28, y: 29, label: 'Victoria Island' },
        { x: 77, y: 65, label: 'Ikeja City Mall' },
      ],
    })}
    ${statusBar()}

    <div style="position:absolute;top:52px;left:var(--page-margin);z-index:3">
      <button class="btn-icon" aria-label="Back">${icon('back', 18)}</button>
    </div>

    <div class="sheet">
      <div class="sheet__grip"></div>
      <div class="sheet__body">
        ${line([
          { title: '14 Adeola Odeku Street', meta: 'Victoria Island', state: 'active' },
          { title: 'Ikeja City Mall', meta: `Alausa · ${distance(activeOrder.distanceKm)}`, state: 'future' },
        ])}

        <hr class="divider mt-lg" />

        <div class="section__head" style="margin-top:var(--space-lg)">
          <span class="t-label-s c-tertiary">Choose a vehicle</span>
        </div>
        <div class="rows">${options}</div>

        <dl class="money mt-xl" style="margin-bottom:0">
          ${moneyLine('Delivery fee', money(activeOrder.fee))}
          ${moneyLine('Package protection', money(activeOrder.protection))}
        </dl>
      </div>
    </div>

    <div class="action-bar">
      <div class="action-bar__summary">
        <span class="t-body c-secondary">Total</span>
        <span class="t-num-l c-primary">${money(activeOrder.fee + activeOrder.protection)}</span>
      </div>
      <button class="btn btn--primary btn--block">Review and pay</button>
    </div>
  </div>`;
}
