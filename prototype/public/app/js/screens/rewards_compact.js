/* Rewards — the compact card.
 *
 * Third run. The first two were rewards-screen cards that happened to appear on home; this one
 * is designed for home first, where the reward is the fourth thing on the screen, under a map
 * and a service picker, with the nav pod eating the last 90px. Anything ~200px tall pushes
 * itself below the fold and gets scrolled past.
 *
 * Two takes, both a single row:
 *
 *   1 · METER — the box *is* the progress. Colour rises through it as deliveries land, so one
 *       object carries the count, the prize and the state at once. No route, no pips, no
 *       second graphic. It is the smallest honest drawing of "you are two thirds of the way
 *       to a gift", and the artwork finally has a job only artwork can do.
 *
 *   2 · STRIP — for when the meter reads too clever to trust. The route survives, collapsed
 *       to a hairline of ticks under the copy: the Line at its smallest scale, worn the way
 *       the order row wears it, with the box quiet on the end.
 *
 * Both keep the rule from the gift variant: no colour until it is yours.
 */

import { icon, bar, statusBar, go, row, sp } from '../ui.js';

const GIFT = '/app/img/gift-box.png';
const TARGET = 3;

/* The artwork's box occupies y 114..430 of a 500px canvas — 23% down from the top, 14% up
 * from the bottom. The meter fills that band, not the canvas, or an empty reward would read
 * as two thirds won. */
const TOP = 23;
const BOTTOM = 14;
const fillTop = (done) => TOP + (1 - done / TARGET) * (100 - TOP - BOTTOM);

/** Take 1. The count is the object. */
const meter = ({ done, eyebrow, head, sub }) => `
  <button class="gc ${done >= TARGET ? 'gc--won' : ''}" ${go('rewardsCompact')}>
    <span class="gc__txt">
      <span class="gc__eyebrow">${eyebrow}<i></i><b>${done} of ${TARGET}</b></span>
      <b class="gc__h">${head}</b>
      <small class="gc__sub">${sub}</small>
    </span>
    <span class="gc__meter" style="--fill:${fillTop(done).toFixed(1)}%">
      <img class="is-base" src="${GIFT}" alt="" />
      <img class="is-fill" src="${GIFT}" alt="" />
    </span>
  </button>`;

/** Take 2. The route, four ticks wide. */
const strip = ({ done, eyebrow, head }) => `
  <button class="gc ${done >= TARGET ? 'gc--won' : ''}" ${go('rewardsCompact')}>
    <span class="gc__txt">
      <span class="gc__eyebrow">${eyebrow}<i></i><b>${done} of ${TARGET}</b></span>
      <b class="gc__h">${head}</b>
      <span class="gc__rail">
        ${Array.from({ length: TARGET }, (_, i) =>
          `<i class="gc__tick ${i < done ? 'gc__tick--on' : i === done ? 'gc__tick--now' : ''}"></i>`
        ).join('')}
        <i class="gc__end ${done >= TARGET ? 'gc__end--on' : ''}"></i>
      </span>
    </span>
    <span class="gc__box"><img src="${GIFT}" alt="" /></span>
  </button>`;

export default {
  rewardsCompact: {
    section: 'Home & booking',
    title: 'Rewards · compact',
    render: () => `<div class="scr">${statusBar()}${bar('Rewards')}
      <div class="body pad">

        <div class="mez">1 · Meter — the box is the progress</div>
        ${meter({ done: 0, eyebrow: 'Reward', head: 'Three deliveries unlock 20% off',
                  sub: 'Store orders count too' })}
        <div style="height:8px"></div>
        ${meter({ done: 2, eyebrow: 'Reward', head: 'One more delivery unlocks it',
                  sub: '20% off your next booking' })}
        <div style="height:8px"></div>
        ${meter({ done: 3, eyebrow: 'Ready', head: 'Your 20% off is ready',
                  sub: 'Applied to your next booking' })}

        <div class="mez">2 · Strip — the route, four ticks wide</div>
        ${strip({ done: 0, eyebrow: 'Reward', head: 'Three deliveries unlock 20% off' })}
        <div style="height:8px"></div>
        ${strip({ done: 2, eyebrow: 'Reward', head: 'One more delivery unlocks it' })}
        <div style="height:8px"></div>
        ${strip({ done: 3, eyebrow: 'Ready', head: 'Your 20% off is ready' })}

        <div class="mez">Against the full card</div>
        <div class="gf">
          <div class="rw__top">
            <span class="rw__eyebrow">Your next reward</span>
            <span class="rw__chip">20% OFF</span>
          </div>
          <div class="gf__route">
            <span class="gf__cell"><span class="gf__band">
              <span class="gf__n gf__n--done">${icon('check', 12)}</span></span>
              <span class="gf__lab">Done</span></span>
            <span class="gf__seg gf__seg--on"></span>
            <span class="gf__cell"><span class="gf__band">
              <span class="gf__n gf__n--done">${icon('check', 12)}</span></span>
              <span class="gf__lab">Done</span></span>
            <span class="gf__seg gf__seg--on"></span>
            <span class="gf__cell"><span class="gf__band">
              <span class="gf__n gf__n--now">3</span></span>
              <span class="gf__lab gf__lab--on">Next</span></span>
            <span class="gf__seg gf__seg--dash"></span>
            <span class="gf__cell"><span class="gf__band">
              <span class="gf__gift"><img src="${GIFT}" alt="" /></span></span>
              <span class="gf__lab">Reward</span></span>
          </div>
          <div class="gf__body">
            <b>One more delivery unlocks it</b>
            <small>Store orders count too.</small>
          </div>
        </div>

        <div class="mez">How it works</div>
        <div class="rows">
          ${row({ icon: 'truck', title: 'Three deliveries', meta: 'Courier bookings and store orders both count', chevron: false })}
          ${row({ icon: 'star', title: 'Unlocks 20% off', meta: 'Applied to the next booking automatically', chevron: false })}
        </div>

        ${sp(22)}
      </div></div>`,
  },
};
