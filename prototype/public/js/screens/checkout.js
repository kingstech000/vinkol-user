/* The commitment screen. Everything the user is agreeing to is visible without scrolling
 * past the button: what, where, when, how much, paid with what, and what happens if it goes
 * wrong. Trust is shown — verified rider, protection, refund terms — never claimed. */

import { statusBar, appbar, line, moneyLine } from '../components.js';
import { icon } from '../icons.js';
import { money, taxLabel, taxOn } from '../market.js';
import { activeOrder } from '../fixtures.js';

export const meta = { id: 'checkout', title: 'Checkout', group: 'Money', tag: 'money' };

export function render() {
  const tax = taxOn(activeOrder.fee);
  const total = activeOrder.fee + activeOrder.protection + tax;

  return `<div class="screen">
    ${statusBar()}
    ${appbar({ title: 'Review and pay', hero: true })}

    <div class="content">
      <div class="surface pad">
        ${line([
          { title: activeOrder.pickup.title, meta: 'Victoria Island', state: 'active' },
          { title: activeOrder.dropoff.title, meta: 'Alausa', state: 'future' },
        ])}
        <hr class="divider mt-lg" />
        <div class="hstack gap-sm mt-md t-body-s c-secondary">
          ${icon('clock', 16)} Bike · picked up in 8–12 min, delivered by 11:05
        </div>
      </div>

      <div class="section">
        <div class="section__head"><span class="t-label-s c-tertiary">Package</span></div>
        <div class="rows">
          <div class="row" style="cursor:default">
            <span class="row__icon">${icon('package', 18)}</span>
            <span class="row__body">
              <span class="row__title">Documents · under 2 kg</span>
              <span class="row__meta">Declared value ${money(activeOrder.itemValue, { plain: true })}</span>
            </span>
            <button class="appbar__action">Edit</button>
          </div>
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
            ${moneyLine('Total', money(total), 'money__line--total')}
          </dl>
        </div>

        <button class="row surface mt-md" style="border-radius:var(--radius-sm);width:100%">
          <span class="row__icon">${icon('wallet', 18)}</span>
          <span class="row__body">
            <span class="row__title">Vinkol wallet</span>
            <span class="row__meta">Balance ${money(128400, { plain: true })}</span>
          </span>
          <span class="row__chevron">${icon('chevron', 16)}</span>
        </button>
      </div>

      <div class="banner banner--info mt-lg">
        ${icon('shield', 20)}
        <div class="banner__body">
          <div class="t-h4">Covered to ${money(activeOrder.itemValue, { plain: true })}</div>
          <div class="t-body-s c-secondary mt-xs">
            If your package is lost or damaged, you're refunded in full within 3 working days.
          </div>
        </div>
      </div>
    </div>

    <div class="action-bar">
      <div class="action-bar__summary">
        <span class="t-body c-secondary">Total</span>
        <span class="t-num-l c-primary">${money(total)}</span>
      </div>
      <button class="btn btn--primary btn--block">Pay and book</button>
    </div>
  </div>`;
}
