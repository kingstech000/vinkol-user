/* Wallet. The balance is the one num.xl on the screen; everything else is a row.
 * Transaction amounts sit on a shared right-hand optical axis in tabular figures — switch
 * the market in the harness and the column stays aligned. That is signature #4 working. */

import { statusBar, appbar, pod, moneyLine } from '../components.js';
import { icon } from '../icons.js';
import { money } from '../market.js';
import { transactions, walletBalance } from '../fixtures.js';

export const meta = { id: 'wallet', title: 'Wallet', group: 'Operations', tag: 'numerics' };

export function render() {
  const rows = transactions
    .map(
      (t) => `<button class="row">
        <span class="row__icon" style="${
          t.kind === 'in' ? 'color:var(--success)' : ''
        }">${icon(t.kind === 'in' ? 'arrowDown' : 'arrowUp', 18)}</span>
        <span class="row__body">
          <span class="row__title">${t.title}</span>
          <span class="row__meta">${t.when} · ${t.ref}</span>
        </span>
        <span class="row__value t-num" style="${
          t.kind === 'in' ? 'color:var(--success)' : 'color:var(--text-primary)'
        }">${t.kind === 'in' ? '+' : '−'}${money(Math.abs(t.amount))}</span>
      </button>`
    )
    .join('');

  return `<div class="screen">
    ${statusBar()}
    ${appbar({ title: 'Wallet', hero: true, back: false })}

    <div class="content">
      <div class="surface pad">
        <div class="t-label-s c-tertiary">Available balance</div>
        <div class="t-num-xl c-primary mt-sm">${money(walletBalance)}</div>
        <div class="hstack gap-md mt-lg">
          <button class="btn btn--primary grow">${icon('plus', 18)} Add money</button>
          <button class="btn btn--secondary grow">Withdraw</button>
        </div>
      </div>

      <div class="section">
        <div class="section__head">
          <span class="t-label-s c-tertiary">This month</span>
        </div>
        <div class="surface pad">
          <dl class="money" style="margin:0">
            ${moneyLine('Spent on deliveries', money(11800))}
            ${moneyLine('Refunded', money(5400))}
          </dl>
        </div>
      </div>

      <div class="section">
        <div class="section__head">
          <span class="t-label-s c-tertiary">Transactions</span>
          <button class="btn btn--ghost" style="padding:0;min-height:auto">See all</button>
        </div>
        <div class="rows">${rows}</div>
      </div>
    </div>

    ${pod('wallet')}
  </div>`;
}
