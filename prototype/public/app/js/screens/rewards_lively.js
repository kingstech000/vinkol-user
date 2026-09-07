/* Rewards — option 1, colour up.
 *
 * The meter card kept everything blue and let the artwork supply the only warmth. Here colour
 * temperature *is* the progress signal: cool and quiet at zero, heating through amber, a full
 * celebration at three.
 *
 * Every state drives one variable — `--heat`, 0 to 1 — and the wash, the glow behind the box,
 * the waterline bloom and the ray burst all read off it. One knob, not four decisions, which
 * is what stops "more colourful" turning into "more of everything".
 *
 * The palette is lifted from the artwork (its gold, its ribbon red) rather than invented. A
 * warm card built from colours the gift already contains still looks like Vinkol; one built
 * from a fresh set looks like a different app.
 *
 * Two intensities, so the ceiling is a choice and not a guess:
 *   A · Warm    — the wash rises with progress, the card stays a card
 *   B · Festive — the earned state goes full colour: gradient ground, rays, shine, confetti
 */

import { bar, statusBar, go, row, sp } from '../ui.js';

const GIFT = '/app/img/gift-box.png';
const TARGET = 3;

/* The artwork's box occupies y 114..430 of a 500px canvas. The meter fills that band, not the
 * canvas, or an empty reward reads as two thirds won. */
const TOP = 23;
const BOTTOM = 14;
const fillTop = (done) => (TOP + (1 - done / TARGET) * (100 - TOP - BOTTOM)).toFixed(1);

/* Heat runs ahead of the raw fraction — even zero carries a little colour, because a card that
 * starts fully grey reads as disabled rather than as "not yet". */
const HEAT = [0.16, 0.42, 0.68, 1];

const COPY = [
  { k: 'Reward', h: 'Three deliveries unlock 20% off', s: 'Courier bookings and store orders both count' },
  { k: 'Reward', h: 'Two more deliveries unlock it', s: '20% off your next booking' },
  { k: 'Reward', h: 'One more delivery unlocks it', s: '20% off your next booking' },
  { k: 'Ready', h: 'Your 20% off is ready', s: 'Applied to your next booking automatically' },
];

const card = (done, { festive = false } = {}) => {
  const c = COPY[done];
  const won = done >= TARGET;
  const hot = done >= 2;
  const cls = ['lv', hot ? 'lv--hot' : '', won ? 'lv--won' : '', festive && won ? 'lv--festive' : '']
    .filter(Boolean).join(' ');

  return `<button class="${cls}" style="--heat:${HEAT[done]};--fill:${fillTop(done)}%"
      ${go('rewardsLively')}>
    ${festive && won ? '<span class="lv__cf"><i></i><i></i><i></i><i></i></span>' : ''}
    <span class="lv__txt">
      <span class="lv__eyebrow">
        <span class="lv__k">${c.k}</span>
        <span class="lv__chip">${done} of ${TARGET}</span>
      </span>
      <b class="lv__h">${c.h}</b>
      <small class="lv__sub">${c.s}</small>
    </span>
    <span class="lv__meter">
      <span class="lv__glow"></span>
      <span class="lv__rays"></span>
      <img class="is-base" src="${GIFT}" alt="" />
      <img class="is-fill" src="${GIFT}" alt="" />
      <span class="lv__line"></span>
      <span class="lv__shine"></span>
    </span>
  </button>`;
};

const gap = (h = 9) => `<div style="height:${h}px"></div>`;

export default {
  rewardsLively: {
    section: 'Home & booking',
    title: 'Rewards · lively',
    render: () => `<div class="scr">${statusBar()}${bar('Rewards')}
      <div class="body pad">

        <div class="mez">A · Warm — colour rises with the count</div>
        ${card(0)}${gap()}${card(1)}${gap()}${card(2)}${gap()}${card(3)}

        <div class="mez">B · Festive — the earned card, all the way up</div>
        ${card(2)}${gap()}${card(3, { festive: true })}

        <div class="mez">How it works</div>
        <div class="rows">
          ${row({ icon: 'truck', title: 'Three deliveries', meta: 'Courier bookings and store orders both count', chevron: false })}
          ${row({ icon: 'star', title: 'Unlocks 20% off', meta: 'Applied to the next booking automatically', chevron: false })}
        </div>

        ${sp(22)}
      </div></div>`,
  },
};
