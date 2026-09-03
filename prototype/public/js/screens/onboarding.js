/* Hero register. The Line at graphic scale is the illustration — no stock art, no 3D object.
 * One proposition per panel, and the user can leave at any point. */

import { statusBar } from '../components.js';

export const meta = { id: 'onboarding', title: 'Onboarding', group: 'Entry', tag: 'hero' };

export function render() {
  return `<div class="screen">
    ${statusBar()}
    <div style="display:flex;justify-content:flex-end;padding:0 var(--page-margin)">
      <button class="btn btn--ghost">Skip</button>
    </div>

    <div style="flex:1;display:flex;flex-direction:column;justify-content:center;
                padding:0 var(--page-margin)">
      <svg width="100%" height="200" viewBox="0 0 320 200" fill="none" aria-hidden="true"
           style="margin-bottom:var(--space-huge)">
        <circle cx="40" cy="40" r="9" stroke="var(--brand)" stroke-width="3"/>
        <path d="M40 49 C 40 110, 160 90, 160 130 S 280 150, 280 160"
              stroke="var(--brand)" stroke-width="3" stroke-linecap="round" fill="none"/>
        <rect x="272" y="152" width="16" height="16" rx="2"
              transform="rotate(45 280 160)" fill="var(--brand)"/>
        <circle cx="160" cy="130" r="5" fill="var(--surface)" stroke="var(--brand)" stroke-width="3"/>
      </svg>

      <h1 class="t-display-l c-primary" style="margin:0">Send anything,<br/>anywhere.</h1>
      <p class="t-body-l c-secondary mt-lg" style="margin:0;max-width:30ch">
        Book a rider in under a minute. Watch every step. Know the price before you commit.
      </p>
    </div>

    <div style="padding:0 var(--page-margin) var(--space-xxl)">
      <div class="hstack gap-sm" style="justify-content:center;margin-bottom:var(--space-xl)">
        <span style="width:20px;height:4px;border-radius:999px;background:var(--brand)"></span>
        <span style="width:4px;height:4px;border-radius:999px;background:var(--border-default)"></span>
        <span style="width:4px;height:4px;border-radius:999px;background:var(--border-default)"></span>
      </div>
      <button class="btn btn--primary btn--block">Continue</button>
    </div>
  </div>`;
}
