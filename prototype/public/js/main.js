/* Harness. Owns the rail, the theme toggle and the market toggle, and nothing else —
 * no screen module knows any of this exists. Switching market re-renders with different
 * currency, decimals and tax label without a line of screen code changing, which is the
 * whole point of the market layer. */

import { setMarket } from './market.js';

import * as splash from './screens/splash.js';
import * as onboarding from './screens/onboarding.js';
import * as login from './screens/login.js';
import * as home from './screens/home.js';
import * as quote from './screens/quote.js';
import * as tracking from './screens/tracking.js';
import * as deliveries from './screens/deliveries.js';
import * as order from './screens/order.js';
import * as checkout from './screens/checkout.js';
import * as wallet from './screens/wallet.js';

const ENTRIES = [
  { ...splash.meta, render: splash.render, note: 'Hero register. No gradient, no logo animation — the mark and the route are the whole screen.' },
  { ...onboarding.meta, render: onboarding.render, note: 'The Line at graphic scale replaces the stock illustration. One proposition, and an exit.' },
  { ...login.meta, render: login.render, note: 'The form archetype — one solution covering 12 screens. Shown in its error state, which the current app handles worst.' },
  { ...home.meta, render: home.render, note: 'Signature #5: the map is the canvas, controls are hairline e0 surfaces. The pod sits at rest.' },
  { ...quote.meta, render: quote.render, note: 'Vehicle options are rows, not cards — three cards would make the choice feel heavier than it is.' },
  { ...tracking.meta, render: tracking.render, note: 'The screen the app does not have. The Line at full scale, and the reason signature #1 exists.' },
  { ...deliveries.meta, render: deliveries.render, note: 'Density is the feature: eight rows, status triple, money on a shared axis. The pod has morphed into live state.' },
  { ...order.meta, render: order.render, note: 'The Line carries the history; the breakdown carries the trust. The reference is mono because people read it aloud.' },
  { ...checkout.meta, render: checkout.render, note: 'Everything being agreed to is visible above the button. Protection terms are shown, not claimed.' },
  { ...wallet.meta, render: wallet.render, note: 'One num.xl on the screen. Switch to Canada — the column stays aligned. That is signature #4 working.' },

  { id: 'deliveries-loading', title: 'List · loading', group: 'Edge states', tag: 'skeleton', render: deliveries.renderLoading, note: 'A skeleton, not a spinner: the layout is known, so show it.' },
  { id: 'deliveries-empty', title: 'List · empty', group: 'Edge states', tag: 'empty', render: deliveries.renderEmpty, note: 'An empty state without an action is a dead end. This one offers the next step.' },
  { id: 'deliveries-error', title: 'List · error', group: 'Edge states', tag: 'error', render: deliveries.renderError, note: 'States the cause, reassures about the in-flight delivery, and offers a retry.' },
];

const state = {
  screen: ENTRIES[0].id,
  theme: 'light',
  market: 'NG',
};

const $screen = document.getElementById('screen');
const $rail = document.getElementById('rail');
const $note = document.getElementById('note');

function buildRail() {
  let html = '';
  let group = null;
  for (const e of ENTRIES) {
    if (e.group !== group) {
      group = e.group;
      html += `<div class="harness__group">${group}</div>`;
    }
    html += `<button class="harness__link" data-screen="${e.id}" aria-current="${e.id === state.screen}">
      <span>${e.title}</span><span class="harness__tag">${e.tag}</span>
    </button>`;
  }
  $rail.innerHTML = html;
}

function render() {
  const entry = ENTRIES.find((e) => e.id === state.screen) || ENTRIES[0];
  document.documentElement.setAttribute('data-theme', state.theme);
  setMarket(state.market);

  $screen.innerHTML = entry.render();
  $note.innerHTML = `<b>${entry.title}</b> — ${entry.note}`;

  $rail.querySelectorAll('[data-screen]').forEach((b) => {
    b.setAttribute('aria-current', b.dataset.screen === state.screen);
  });
  document.querySelectorAll('[data-theme-set]').forEach((b) => {
    b.setAttribute('aria-pressed', b.dataset.themeSet === state.theme);
  });
  document.querySelectorAll('[data-market-set]').forEach((b) => {
    b.setAttribute('aria-pressed', b.dataset.marketSet === state.market);
  });

  const url = `/screen/${entry.id}`;
  if (location.pathname !== url) history.replaceState({}, '', url);
}

document.addEventListener('click', (ev) => {
  const screenBtn = ev.target.closest('[data-screen]');
  if (screenBtn) {
    state.screen = screenBtn.dataset.screen;
    return render();
  }
  const themeBtn = ev.target.closest('[data-theme-set]');
  if (themeBtn) {
    state.theme = themeBtn.dataset.themeSet;
    return render();
  }
  const marketBtn = ev.target.closest('[data-market-set]');
  if (marketBtn) {
    state.market = marketBtn.dataset.marketSet;
    return render();
  }
});

// Keyboard: j/k walk the screen list, t flips theme, m flips market.
document.addEventListener('keydown', (ev) => {
  if (ev.target.matches('input, textarea')) return;
  const i = ENTRIES.findIndex((e) => e.id === state.screen);
  if (ev.key === 'j') state.screen = ENTRIES[(i + 1) % ENTRIES.length].id;
  else if (ev.key === 'k') state.screen = ENTRIES[(i - 1 + ENTRIES.length) % ENTRIES.length].id;
  else if (ev.key === 't') state.theme = state.theme === 'light' ? 'dark' : 'light';
  else if (ev.key === 'm') state.market = state.market === 'NG' ? 'CA' : 'NG';
  else return;
  render();
});

const deep = location.pathname.match(/^\/screen\/(.+)$/);
if (deep && ENTRIES.some((e) => e.id === deep[1])) state.screen = deep[1];

buildRail();
render();
