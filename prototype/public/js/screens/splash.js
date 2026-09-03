/* Hero register. One message, display type, the Line as the only graphic.
 * No illustration, no gradient, no logo animation — the mark and the route are enough. */

export const meta = { id: 'splash', title: 'Splash', group: 'Entry', tag: 'hero' };

export function render() {
  return `<div class="screen" style="background:var(--neutral-900)">
    <div style="flex:1; display:grid; place-items:center;">
      <div style="text-align:center">
        <svg width="52" height="72" viewBox="0 0 52 72" fill="none" aria-hidden="true"
             style="margin-bottom:24px">
          <circle cx="26" cy="10" r="6" stroke="var(--brand-400)" stroke-width="3"/>
          <path d="M26 18 V50" stroke="var(--brand-500)" stroke-width="3" stroke-linecap="round"/>
          <rect x="19.5" y="51" width="13" height="13" rx="2" transform="rotate(45 26 57.5)"
                fill="var(--brand-500)"/>
        </svg>
        <div class="t-display-s" style="color:#fff">Vinkol</div>
      </div>
    </div>
    <div style="padding:0 var(--page-margin) 56px; text-align:center">
      <div class="t-label-s" style="color:var(--neutral-600)">Logistics, everywhere</div>
    </div>
  </div>`;
}
