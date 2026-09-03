/* Shared render helpers. Every screen composes these — nothing here is invented per screen. */

import { icon } from './icons.js';

/* --- Status: the triple. --------------------------------------------------------------
 * label + shape + colour, in that priority order (decision D-05). The shape and the label
 * carry the meaning; colour reinforces. `cancelled` is neutral, not red — cancellation is an
 * outcome, not an error. */
export const STATUS = {
  draft: { label: 'Draft', shape: '' },
  awaitingPayment: { label: 'Awaiting payment', shape: 'half' },
  findingRider: { label: 'Finding a rider', shape: 'ring' },
  riderAssigned: { label: 'Rider assigned', shape: 'filled' },
  atPickup: { label: 'At pickup', shape: 'tick' },
  inTransit: { label: 'In transit', shape: 'filled' },
  delivered: { label: 'Delivered', shape: 'tick' },
  cancelled: { label: 'Cancelled', shape: 'slash' },
  failed: { label: 'Failed', shape: 'alert' },
  refunded: { label: 'Refunded', shape: '' },
};

export function status(key) {
  const s = STATUS[key];
  const shape = s.shape ? ` status__shape--${s.shape}` : '';
  return `<span class="status status--${key}"><span class="status__shape${shape}"></span>${s.label}</span>`;
}

/* --- Chrome ---------------------------------------------------------------------------- */

export function statusBar(time = '9:41') {
  return `<div class="status-bar">
    <span>${time}</span>
    <span class="status-bar__icons">
      <svg width="17" height="11" viewBox="0 0 17 11" fill="currentColor" aria-hidden="true">
        <rect x="0" y="7" width="3" height="4" rx="1"/><rect x="4.5" y="5" width="3" height="6" rx="1"/>
        <rect x="9" y="2.5" width="3" height="8.5" rx="1"/><rect x="13.5" y="0" width="3" height="11" rx="1"/>
      </svg>
      <svg width="24" height="11" viewBox="0 0 24 11" fill="none" stroke="currentColor" aria-hidden="true">
        <rect x="0.6" y="0.6" width="19" height="9.8" rx="2.5" stroke-width="1.2" opacity="0.5"/>
        <rect x="2.2" y="2.2" width="14" height="6.6" rx="1.4" fill="currentColor" stroke="none"/>
        <path d="M21.5 4v3" stroke-width="2" stroke-linecap="round" opacity="0.5"/>
      </svg>
    </span>
  </div>`;
}

export function appbar({ title, subtitle, back = true, action, hero = false }) {
  return `<header class="appbar">
    ${back ? `<button class="appbar__back" aria-label="Back">${icon('back', 20)}</button>` : ''}
    <div class="appbar__title">
      <div class="${hero ? 't-h1' : 't-h3'} c-primary">${title}</div>
      ${subtitle ? `<div class="t-body-s c-secondary">${subtitle}</div>` : ''}
    </div>
    ${action ? `<button class="appbar__action">${action}</button>` : ''}
  </header>`;
}

/* --- The Pod: nav at rest, live-delivery status when a delivery is active. One object. --- */

const NAV = [
  { id: 'home', label: 'Home', icon: 'home' },
  { id: 'shop', label: 'Shop', icon: 'store' },
  { id: 'deliveries', label: 'Deliveries', icon: 'truck' },
  { id: 'wallet', label: 'Wallet', icon: 'wallet' },
  { id: 'profile', label: 'Profile', icon: 'user' },
];

export function pod(active = 'home', live = null) {
  const nav = NAV.map(
    (n) => `<button class="pod__item" aria-current="${n.id === active}">
      ${icon(n.icon, 22)}<span>${n.label}</span>
    </button>`
  ).join('');

  const liveRow = live
    ? `<div class="pod__live">
        <div class="pod__live-avatar">${live.initials}</div>
        <div class="pod__live-body">
          <div class="t-label-s" style="color:var(--brand-300)">${live.state}</div>
          <div class="t-h4">${live.rider}</div>
        </div>
        <div class="pod__live-eta">
          <div class="t-num-l">${live.eta}</div>
          <div class="t-label-s" style="color:#6e7784">min away</div>
        </div>
      </div>`
    : '';

  return `<nav class="pod ${live ? 'pod--live' : ''}">${liveRow}<div class="pod__nav">${nav}</div></nav>`;
}

/* --- The Line: signature #1, rendered at four scales, same geometry every time. --------- */

/** Full timeline. stops: [{ title, meta, state: 'done'|'active'|'future' }] */
export function line(stops) {
  return `<div class="line">
    <div class="line__rail">
      ${stops
        .map((s, i) => {
          const last = i === stops.length - 1;
          const nodeMod =
            s.state === 'done' ? 'line__node--done' : s.state === 'active' ? 'line__node--filled' : 'line__node--future';
          const terminus = last ? ' line__node--terminus' : '';
          const pathMod =
            s.state === 'done' ? 'line__path--done' : s.state === 'active' ? 'line__path--active' : '';
          return `<span class="line__node ${nodeMod}${terminus}"></span>${
            last ? '' : `<span class="line__path ${pathMod}"></span>`
          }`;
        })
        .join('')}
    </div>
    <div>
      ${stops
        .map(
          (s) => `<div class="line__stop">
            <div class="t-h4 c-primary">${s.title}</div>
            ${s.meta ? `<div class="t-body-s c-secondary">${s.meta}</div>` : ''}
          </div>`
        )
        .join('')}
    </div>
  </div>`;
}

/** The compressed 2-node glyph for a list row. Same geometry, smaller scale. */
export function lineGlyph() {
  return `<div class="line-glyph" aria-hidden="true">
    <span class="line-glyph__node"></span>
    <span class="line-glyph__path"></span>
    <span class="line-glyph__node line-glyph__node--end"></span>
  </div>`;
}

/* --- Map. The canvas, not a widget. Controls are e0 hairline surfaces. ------------------ */

export function map({ route = true, pins = [] } = {}) {
  const pinMarkup = pins
    .map(
      (p) => `<div class="map__pin" style="left:${p.x}%; top:${p.y}%">
        ${p.label ? `<div class="map__pin-label">${p.label}</div>` : ''}
        <div class="map__pin-dot" style="${p.color ? `background:${p.color}` : ''}"></div>
      </div>`
    )
    .join('');

  return `<div class="map">
    <svg viewBox="0 0 390 700" preserveAspectRatio="xMidYMid slice">
      <rect width="390" height="700" fill="var(--map-ground)"/>
      <path d="M-20 520 L200 470 L410 500 L410 620 L-20 640Z" fill="var(--map-water)" opacity="0.7"/>
      <g stroke="var(--map-road)" fill="none">
        <path d="M-10 120 H400" stroke-width="14"/>
        <path d="M-10 300 H400" stroke-width="20"/>
        <path d="M-10 440 H400" stroke-width="10"/>
        <path d="M70 -10 V710" stroke-width="16"/>
        <path d="M250 -10 V710" stroke-width="11"/>
        <path d="M340 -10 V710" stroke-width="8"/>
        <path d="M-10 210 L180 210 L250 150" stroke-width="8"/>
      </g>
      <g fill="var(--map-road)" opacity="0.55">
        <rect x="95" y="145" width="60" height="40" rx="3"/>
        <rect x="170" y="145" width="55" height="40" rx="3"/>
        <rect x="95" y="330" width="48" height="52" rx="3"/>
        <rect x="160" y="330" width="70" height="52" rx="3"/>
        <rect x="270" y="330" width="52" height="52" rx="3"/>
        <rect x="95" y="230" width="70" height="42" rx="3"/>
      </g>
      ${
        route
          ? `<path d="M110 205 C 150 205, 150 260, 200 300 S 265 400, 300 455"
               stroke="var(--brand-500)" stroke-width="5" fill="none" stroke-linecap="round"/>`
          : ''
      }
    </svg>
    ${pinMarkup}
  </div>`;
}

/* --- Feedback states. First-class screens, not fallbacks. ------------------------------ */

export function empty({ mark = 'package', title, body, action }) {
  return `<div class="empty">
    <div class="empty__mark" style="color:var(--text-disabled)">${icon(mark, 40, 1.25)}</div>
    <h3 class="t-h2 c-primary">${title}</h3>
    <p class="t-body">${body}</p>
    ${action ? `<button class="btn btn--secondary">${action}</button>` : ''}
  </div>`;
}

export function skeletonRow() {
  return `<div class="row" style="cursor:default">
    <div class="skeleton" style="width:36px;height:36px;border-radius:8px"></div>
    <div class="row__body">
      <div class="skeleton" style="height:14px;width:62%"></div>
      <div class="skeleton mt-sm" style="height:12px;width:40%"></div>
    </div>
    <div class="skeleton" style="height:14px;width:56px"></div>
  </div>`;
}

export function moneyLine(label, value, mod = '') {
  return `<div class="money__line ${mod}"><dt>${label}</dt><dd>${value}</dd></div>`;
}
