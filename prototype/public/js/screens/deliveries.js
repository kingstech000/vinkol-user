/* The operational heart. Density is the feature: eight rows visible without scrolling.
 * Status is the triple, money is right-aligned and tabular on a shared axis, and the Line
 * appears as its compressed 2-node glyph.
 *
 * This module renders four states from one source — the loading, empty and error states are
 * first-class screens here, not fallbacks bolted on later. */

import { statusBar, appbar, pod, status, lineGlyph, empty, skeletonRow } from '../components.js';
import { icon } from '../icons.js';
import { money } from '../market.js';
import { orders, rider, activeOrder } from '../fixtures.js';

export const meta = { id: 'deliveries', title: 'Deliveries', group: 'Operations', tag: 'list' };

const live = { initials: rider.initials, rider: rider.name, state: 'In transit', eta: activeOrder.etaMin };

function row(o) {
  return `<button class="row" style="align-items:stretch">
    ${lineGlyph()}
    <span class="row__body" style="align-self:center">
      <span class="row__title">${o.from} → ${o.to}</span>
      <span class="row__meta">${o.when} · ${o.ref}</span>
    </span>
    <span class="row__value" style="align-self:center">
      <span class="t-num c-primary" style="display:block">${money(o.amount)}</span>
      <span class="mt-xs" style="display:block">${status(o.status)}</span>
    </span>
  </button>`;
}

function shell(inner, { tab = 'active' } = {}) {
  return `<div class="screen">
    ${statusBar()}
    ${appbar({
      title: 'Deliveries',
      hero: true,
      back: false,
      action: `<span style="display:inline-flex">${icon('filter', 20)}</span>`,
    })}
    <div style="padding:0 var(--page-margin)">
      <div class="tabs">
        <button aria-selected="${tab === 'active'}">Active</button>
        <button aria-selected="${tab === 'past'}">Past</button>
      </div>
    </div>
    <div class="content" style="padding-top:var(--space-lg)">${inner}</div>
    ${pod('deliveries', live)}
  </div>`;
}

export function render() {
  return shell(`<div class="rows">${orders.map(row).join('')}</div>`);
}

export function renderLoading() {
  return shell(`<div class="rows">${Array.from({ length: 6 }, skeletonRow).join('')}</div>`);
}

export function renderEmpty() {
  return shell(
    empty({
      mark: 'package',
      title: 'No active deliveries',
      body: 'When you book a delivery it will appear here, with live tracking from pickup to drop-off.',
      action: 'Book a delivery',
    })
  );
}

export function renderError() {
  return shell(`
    <div class="banner banner--danger">
      ${icon('alert', 20)}
      <div class="banner__body">
        <div class="t-h4">We couldn't load your deliveries</div>
        <div class="t-body-s c-secondary mt-xs">
          Your connection dropped. Any delivery in progress is unaffected.
        </div>
        <button class="btn btn--secondary mt-md" style="min-height:44px">Try again</button>
      </div>
    </div>
  `);
}
