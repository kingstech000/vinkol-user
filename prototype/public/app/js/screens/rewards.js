/* Rewards detail — and the unlocked state the prototype never had.
 *
 * The app's existing unlocked banner is 🎉 + "Congratulations!" + "Use it now! 🚀" on Tailwind
 * emerald #10B981. The mechanic is kept (3 bookings a month → 20% off the next one); the
 * emoji, the exclamation marks and the off-brand green are not. The reward earns the
 * saturated treatment here because on this screen it *is* the subject.
 */

import { icon, statusBar, bar, money, sp, go, row } from '../ui.js';

const stop = (state, inner, label, labOn = false) =>
  `<span class="rw__stop"><span class="rw__n rw__n--${state}">${inner}</span>
    <span class="rw__lab ${labOn ? 'rw__lab--on' : ''}">${label}</span></span>`;

export default {
  rewards: {
    section: 'Home & booking', title: 'Rewards',
    render: () => `<div class="scr">${statusBar()}${bar('Rewards')}
      <div class="body pad">
        <!-- Earned: all three stops complete, the destination filled. -->
        <div class="rw rw--won">
          <div class="rw__top">
            <span class="rw__eyebrow">August reward · earned</span>
            <span class="rw__chip">Ready</span>
          </div>
          <div class="rw__route">
            ${stop('done', icon('check', 12), 'Done')}
            <span class="rw__seg rw__seg--on"></span>
            ${stop('done', icon('check', 12), 'Done')}
            <span class="rw__seg rw__seg--on"></span>
            ${stop('done', icon('check', 12), 'Done')}
            <span class="rw__seg rw__seg--on"></span>
            ${stop('won', `<span>${icon('star', 12)}</span>`, 'Yours', true)}
          </div>
          <div class="rw__body">
            <div class="rw__prize">20<span>% off</span></div>
            <small>Applies automatically to your next booking. Expires 30 September.</small>
          </div>
        </div>
        <div style="margin-top:12px"><button class="btn" ${go('home')}>Use it on a booking</button></div>

        <!-- In progress -->
        <div class="sec"><b>September</b><span>2 of 3</span></div>
        <div class="rw">
          <div class="rw__top">
            <span class="rw__eyebrow">In progress</span>
            <span class="rw__chip">20% OFF</span>
          </div>
          <div class="rw__route">
            ${stop('done', icon('check', 12), 'Done')}
            <span class="rw__seg rw__seg--on"></span>
            ${stop('done', icon('check', 12), 'Done')}
            <span class="rw__seg rw__seg--on"></span>
            ${stop('now', '3', 'Next', true)}
            <span class="rw__seg rw__seg--dash"></span>
            ${stop('goal', `<span>${icon('star', 11)}</span>`, 'Reward')}
          </div>
          <div class="rw__body">
            <b>One more delivery unlocks it</b>
            <small>Store orders count too. Resets 30 September.</small>
          </div>
        </div>

        <div class="sec"><b>How it works</b></div>
        <div class="rows">
          ${row({ icon: 'truck', title: 'Three deliveries a month', meta: 'Courier bookings and store orders both count', chevron: false })}
          ${row({ icon: 'star', title: 'Unlocks 20% off', meta: 'Applied to the next booking automatically', chevron: false })}
          ${row({ icon: 'clock', title: 'Resets monthly', meta: 'Unused rewards expire at month end', chevron: false })}
        </div>

        ${sp(22)}
      </div></div>`,
  },
};
