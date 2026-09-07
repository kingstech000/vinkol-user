/* Router. Every element carrying data-go="<id>" navigates; data-go="back" pops the stack.
 * That one convention is what makes the prototype clickable end to end — screens declare
 * their own links and nothing needs central wiring. */

import { setMarket, setRegion } from './ui.js';
import onboarding from './screens/onboarding.js';
import auth from './screens/auth.js';
import booking from './screens/booking.js';
import multistop from './screens/multistop.js';
import shop from './screens/shop.js';
import rewards from './screens/rewards.js';
import rewardsGift from './screens/rewards_gift.js';
import rewardsCompact from './screens/rewards_compact.js';
import rewardsLively from './screens/rewards_lively.js';
import marketSel from './screens/market.js';
import records from './screens/records.js';
import wallet from './screens/wallet.js';
import profile from './screens/profile.js';

const SCREENS = { ...onboarding, ...marketSel, ...auth, ...booking, ...multistop, ...shop,
  ...rewards, ...rewardsGift, ...rewardsCompact, ...rewardsLively, ...records, ...wallet, ...profile };

const SECTIONS = [
  'Onboarding', 'Authentication', 'Home & booking', 'Shop',
  'Delivery records', 'Package detail', 'Wallet', 'Profile & settings',
];

const state = { id: 'splash', mkt: 'NG', region: null, theme: 'dark', stack: [] };

const $dev = document.getElementById('dev');
const $rail = document.getElementById('rail');
const $hint = document.getElementById('hint');

function buildRail() {
  let html = '';
  for (const sec of SECTIONS) {
    const ids = Object.keys(SCREENS).filter((id) => SCREENS[id].section === sec);
    if (!ids.length) continue;
    html += `<div class="hx__sec">${sec}</div>`;
    for (const id of ids) {
      html += `<button class="hx__l" data-jump="${id}">${SCREENS[id].title}</button>`;
    }
  }
  $rail.innerHTML = html;
}

function render() {
  setMarket(state.mkt);
  if (state.region) setRegion(state.region);
  const s = SCREENS[state.id];
  // The theme lives on the device, not the document — the harness chrome stays dark.
  $dev.setAttribute('data-theme', state.theme);
  $dev.innerHTML = s.render();
  $rail.querySelectorAll('[data-jump]').forEach((b) =>
    b.setAttribute('aria-current', b.dataset.jump === state.id)
  );
  document.querySelectorAll('[data-mkt]').forEach((b) =>
    b.setAttribute('aria-pressed', b.dataset.mkt === state.mkt)
  );
  document.querySelectorAll('[data-theme-set]').forEach((b) =>
    b.setAttribute('aria-pressed', b.dataset.themeSet === state.theme)
  );
  $hint.innerHTML = `<b>${s.section} · ${s.title}</b> — tap anything in the phone to move through the
    flow. <b>${state.stack.length}</b> screens deep · <b>b</b> back · <b>m</b> switch market`;
  const url = `/app/${state.id}`;
  if (location.pathname !== url) history.replaceState({}, '', url);
}

function goTo(id) {
  if (!SCREENS[id]) return;
  state.stack.push(state.id);
  state.id = id;
  render();
}

function back() {
  if (!state.stack.length) return;
  state.id = state.stack.pop();
  render();
}

document.addEventListener('click', (e) => {
  const jump = e.target.closest('[data-jump]');
  if (jump) { state.stack = []; state.id = jump.dataset.jump; return render(); }

  const mkt = e.target.closest('[data-mkt]');
  if (mkt) { state.mkt = mkt.dataset.mkt; state.region = null; return render(); }

  // Tax follows region, so the region picker must drive the whole prototype.
  const rg = e.target.closest('[data-region]');
  if (rg) { state.region = rg.dataset.region; return render(); }

  const th = e.target.closest('[data-theme-set]');
  if (th) { state.theme = th.dataset.themeSet; return render(); }

  const go = e.target.closest('[data-go]');
  if (!go || !$dev.contains(go)) return;
  e.preventDefault();
  const target = go.dataset.go;
  if (target === 'back') back();
  else goTo(target);
});

document.addEventListener('keydown', (e) => {
  if (e.target.matches('input, textarea')) return;
  if (e.key === 'b') back();
  else if (e.key === 't') { state.theme = state.theme === 'dark' ? 'light' : 'dark'; render(); }
  else if (e.key === 'm') { state.mkt = state.mkt === 'NG' ? 'CA' : 'NG'; state.region = null; render(); }
  else return;
});

const deep = location.pathname.match(/^\/app\/(.+)$/);
if (deep && SCREENS[deep[1]]) state.id = deep[1];

buildRail();
render();
