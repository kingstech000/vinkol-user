import { setMarket } from './ui.js';

const DIRS = [
  {
    id: 'midnight',
    name: 'A · Midnight',
    kind: 'Dark · operational',
    blurb:
      'Dark-first operations with one saturated blue object per screen — always the shipment in flight. Highest density of the three. Vinkol blue does the work the reference gave to orange.',
    screens: ['home', 'list', 'detail', 'tracking'],
  },
  {
    id: 'daylight',
    name: 'B · Daylight',
    kind: 'Light · consumer',
    blurb:
      'Light, warm and friendly — soft white cards, circular quick actions, a rewards strip. Closest to the SwiftShip reference. Trades rows-per-screen for calm.',
    screens: ['home', 'list', 'detail', 'tracking'],
  },
  {
    id: 'kinetic',
    name: 'C · Kinetic',
    kind: 'Dark · dual accent',
    blurb:
      'The only direction with two accents, split by meaning: AMBER = moving right now, BLUE = Vinkol and everything settled. The orange is never chrome and never brand — it only ever means motion.',
    screens: ['home', 'list', 'detail', 'tracking'],
  },
];

const mods = {};
for (const d of DIRS) {
  for (const s of d.screens) {
    mods[`${d.id}/${s}`] = await import(`./${d.id}/${s}.js`);
  }
}

const state = { key: 'midnight/home', mkt: 'NG' };
const $rail = document.getElementById('rail');
const $dev = document.getElementById('dev');
const $note = document.getElementById('note');

function buildRail() {
  let html = '';
  for (const d of DIRS) {
    html += `<div class="h2x__dir"><b>${d.name}</b><span>${d.kind}</span></div>`;
    for (const s of d.screens) {
      const m = mods[`${d.id}/${s}`].meta;
      html += `<button class="h2x__link" data-key="${d.id}/${s}" data-dir="${d.id}">
        <span>${m.title}</span><span style="font-size:10px;color:#5c636e">${m.tag}</span></button>`;
    }
  }
  $rail.innerHTML = html;
}

function render() {
  setMarket(state.mkt);
  const [dirId] = state.key.split('/');
  const dir = DIRS.find((d) => d.id === dirId);
  $dev.setAttribute('data-dir', dirId);
  $dev.innerHTML = mods[state.key].render();
  $note.innerHTML = `<b>${dir.name}</b> — ${dir.blurb}`;

  $rail.querySelectorAll('[data-key]').forEach((b) =>
    b.setAttribute('aria-current', b.dataset.key === state.key)
  );
  document.querySelectorAll('[data-mkt]').forEach((b) => {
    const on = b.dataset.mkt === state.mkt;
    b.style.background = on ? '#17191d' : 'none';
    b.style.color = on ? '#fff' : '#6b7280';
  });
}

document.addEventListener('click', (e) => {
  const k = e.target.closest('[data-key]');
  if (k) { state.key = k.dataset.key; return render(); }
  const m = e.target.closest('[data-mkt]');
  if (m) { state.mkt = m.dataset.mkt; return render(); }
});

document.addEventListener('keydown', (e) => {
  if (e.target.matches('input, textarea')) return;
  const keys = DIRS.flatMap((d) => d.screens.map((s) => `${d.id}/${s}`));
  const i = keys.indexOf(state.key);
  if (e.key === 'j') state.key = keys[(i + 1) % keys.length];
  else if (e.key === 'k') state.key = keys[(i - 1 + keys.length) % keys.length];
  else if (e.key === 'm') state.mkt = state.mkt === 'NG' ? 'CA' : 'NG';
  else return;
  render();
});

buildRail();
render();
