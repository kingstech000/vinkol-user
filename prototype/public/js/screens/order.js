/* Order detail. The Line carries the history; the price breakdown carries the trust.
 * The reference is set in mono because people transcribe and read it aloud. */

import { statusBar, appbar, line, status, moneyLine } from '../components.js';
import { icon } from '../icons.js';
import { money, taxLabel, taxOn } from '../market.js';
import { rider, activeOrder } from '../fixtures.js';

export const meta = { id: 'order', title: 'Order detail', group: 'Operations', tag: 'list' };

export function render() {
  const tax = taxOn(activeOrder.fee);
  const total = activeOrder.fee + activeOrder.protection + tax;

  return `<div class="screen">
    ${statusBar()}
    ${appbar({ title: 'Delivery', subtitle: activeOrder.ref })}

    <div class="content">
      <div class="surface pad">
        <div class="hstack" style="justify-content:space-between;align-items:flex-start">
          <div>
            ${status(activeOrder.status)}
            <div class="t-h2 c-primary mt-sm">Arriving in ${activeOrder.etaMin} min</div>
          </div>
          <span style="color:var(--text-disabled)">${icon('package', 22)}</span>
        </div>
        <button class="btn btn--secondary btn--block mt-lg">Track live</button>
      </div>

      <div class="section">
        <div class="section__head"><span class="t-label-s c-tertiary">Route</span></div>
        <div class="surface pad">
          ${line([
            { title: activeOrder.pickup.title, meta: activeOrder.pickup.meta, state: 'done' },
            { title: activeOrder.dropoff.title, meta: activeOrder.dropoff.meta, state: 'active' },
          ])}
        </div>
      </div>

      <div class="section">
        <div class="section__head"><span class="t-label-s c-tertiary">Rider</span></div>
        <div class="surface pad hstack gap-md">
          <div class="avatar">${rider.initials}</div>
          <div class="grow">
            <div class="t-h4 c-primary">${rider.name}</div>
            <div class="t-body-s c-secondary">${rider.rating} ★ · ${rider.trips.toLocaleString()} trips</div>
          </div>
          <span class="hstack gap-xs t-caption" style="color:var(--success)">
            ${icon('shield', 14)} Verified
          </span>
        </div>
      </div>

      <div class="section">
        <div class="section__head"><span class="t-label-s c-tertiary">Payment</span></div>
        <div class="surface pad">
          <dl class="money" style="margin:0">
            ${moneyLine('Delivery fee', money(activeOrder.fee))}
            ${moneyLine('Package protection', money(activeOrder.protection))}
            ${moneyLine(taxLabel(), money(tax))}
          </dl>
          <hr class="divider mt-md" />
          <dl class="money mt-md" style="margin-bottom:0">
            ${moneyLine('Total paid', money(total), 'money__line--total')}
          </dl>
          <div class="hstack gap-sm mt-md t-body-s c-secondary">
            ${icon('card', 16)} Wallet · balance after payment ${money(128400 - total, { plain: true })}
          </div>
        </div>
      </div>

      <div class="section">
        <button class="btn btn--secondary btn--block">
          ${icon('receipt', 18)} Download receipt
        </button>
        <button class="btn btn--danger btn--block mt-md">Report a problem</button>
      </div>
    </div>
  </div>`;
}
