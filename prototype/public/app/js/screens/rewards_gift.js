/* Rewards — the gift variant.
 *
 * A second run at the reward card, built around the gift-box artwork the app already ships
 * (`assets/images/gift-box.png`). The first version drew the destination as the rail's
 * diamond terminus; this one makes the destination the box itself.
 *
 * The problem the artwork poses is that it is photographic gold and red, and Midnight has no
 * gold and no red. Rather than tint it, recolour it or hide it in a corner, the design turns
 * that into the mechanic: while the reward is locked the box is greyscale and half-present,
 * and the moment it is earned it gains its full colour. Colour arriving *is* the reward. It
 * also means the one warm object on the screen only ever appears on the one screen that has
 * something to celebrate — the rest of the app stays blue.
 *
 * Three placements, so the object can be judged where it actually lands:
 *   1. the rewards screen, in progress — the route ends in the locked box
 *   2. the rewards screen, earned      — the box becomes the subject, saturated
 *   3. home                            — the same object compressed to a banner
 */

import { icon, bar, statusBar, go, row, sp } from '../ui.js';

const GIFT = '/app/img/gift-box.png';

/** A delivery stop on the route. */
const stop = (state, inner, label, labOn = false) =>
  `<span class="gf__cell">
    <span class="gf__band"><span class="gf__n gf__n--${state}">${inner}</span></span>
    <span class="gf__lab ${labOn ? 'gf__lab--on' : ''}">${label}</span>
  </span>`;

/** The destination. The box, in its well — dashed and grey until it is yours. */
const giftStop = (won) =>
  `<span class="gf__cell">
    <span class="gf__band">
      <span class="gf__gift ${won ? 'gf__gift--won' : ''}">
        <img src="${GIFT}" alt="" />
      </span>
    </span>
    <span class="gf__lab ${won ? 'gf__lab--on' : ''}">${won ? 'Yours' : 'Reward'}</span>
  </span>`;

const seg = (mod) => `<span class="gf__seg ${mod}"></span>`;

export default {
  rewardsGift: {
    section: 'Home & booking',
    title: 'Rewards · gift',
    render: () => `<div class="scr">${statusBar()}${bar('Rewards')}
      <div class="body pad">

        <!-- 1 · In progress. The route runs into a box that has no colour yet. -->
        <div class="sec"><b>September</b><span>2 of 3</span></div>
        <div class="gf">
          <div class="rw__top">
            <span class="rw__eyebrow">Your next reward</span>
            <span class="rw__chip">20% OFF</span>
          </div>
          <div class="gf__route">
            ${stop('done', icon('check', 12), 'Done')}
            ${seg('gf__seg--on')}
            ${stop('done', icon('check', 12), 'Done')}
            ${seg('gf__seg--on')}
            ${stop('now', '3', 'Next', true)}
            ${seg('gf__seg--dash')}
            ${giftStop(false)}
          </div>
          <div class="gf__body">
            <b>One more delivery unlocks it</b>
            <small>Store orders count too.</small>
          </div>
        </div>

        <!-- 2 · Earned. The box leaves the route and becomes the subject. -->
        <div class="sec"><b>Unlocked</b></div>
        <div class="gf gf--won">
          <div class="rw__top">
            <span class="rw__eyebrow">Reward earned</span>
            <span class="rw__chip">Ready</span>
          </div>
          <div class="gf__hero">
            <div class="gf__prize">20<span>% off</span></div>
            <div class="gf__heroBox"><img src="${GIFT}" alt="Your reward" /></div>
          </div>
          <div class="gf__route">
            ${stop('done', icon('check', 12), 'Done')}
            ${seg('gf__seg--on')}
            ${stop('done', icon('check', 12), 'Done')}
            ${seg('gf__seg--on')}
            ${stop('done', icon('check', 12), 'Done')}
            ${seg('gf__seg--on')}
            ${giftStop(true)}
          </div>
          <div class="gf__body">
            <small>Applies automatically to your next booking.</small>
          </div>
        </div>
        <div style="margin-top:12px"><button class="btn" ${go('home')}>Use it on a booking</button></div>

        <!-- 3 · Home. The same object, compressed: no route, four pips and the box. -->
        <div class="sec"><b>On home</b><span>both states</span></div>
        <button class="gf gf--home" ${go('rewardsGift')}>
          <div class="gf__body">
            <span class="gf__mini">In progress
              <span class="gf__pips"><i class="gf__pip gf__pip--on"></i>
                <i class="gf__pip gf__pip--on"></i><i class="gf__pip"></i></span>
            </span>
            <b>One more delivery unlocks it</b>
            <small>20% off your next booking</small>
            <span class="gf__go">Details ${icon('chevron', 14)}</span>
          </div>
          <div class="gf__homeBox"><img src="${GIFT}" alt="" /></div>
        </button>

        <div style="height:10px"></div>
        <button class="gf gf--home" ${go('rewardsGift')}>
          <div class="gf__body">
            <span class="gf__mini">Ready
              <span class="gf__pips"><i class="gf__pip gf__pip--on"></i>
                <i class="gf__pip gf__pip--on"></i><i class="gf__pip gf__pip--on"></i></span>
            </span>
            <b>Your 20% off is ready</b>
            <small>Applied to your next booking</small>
            <span class="gf__go">Details ${icon('chevron', 14)}</span>
          </div>
          <div class="gf__homeBox gf__homeBox--won"><img src="${GIFT}" alt="" /></div>
        </button>

        <div class="sec"><b>How it works</b></div>
        <div class="rows">
          ${row({ icon: 'truck', title: 'Three deliveries', meta: 'Courier bookings and store orders both count', chevron: false })}
          ${row({ icon: 'star', title: 'Unlocks 20% off', meta: 'Applied to the next booking automatically', chevron: false })}
          ${row({ icon: 'clock', title: 'Then it starts again', meta: 'The count resets once a reward is spent', chevron: false })}
        </div>

        ${sp(22)}
      </div></div>`,
  },
};
