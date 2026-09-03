/* Section 1 — Onboarding. Three panels, each answering one question a first-time user has.
 * The route Line is the only graphic: no stock illustration, no 3D boxes. */

import { icon, statusBar, sp, go } from '../ui.js';

const panels = [
  { k: 'send', t: 'Send anything,<br/>anywhere.', p: 'Book a rider in under a minute. Bike, car or van — priced before you commit.' },
  { k: 'track', t: 'Watch every<br/>step of it.', p: 'Live location, a named rider you can call, and a timeline that never leaves you guessing.' },
  { k: 'trust', t: 'Covered if<br/>it goes wrong.', p: 'Every package is protected. Lost or damaged means refunded in full within 3 working days.' },
];

function art(k) {
  if (k === 'send')
    return `<svg width="100%" height="180" viewBox="0 0 320 180" fill="none" aria-hidden="true">
      <circle cx="42" cy="38" r="9" stroke="var(--acc)" stroke-width="3"/>
      <path d="M42 47c0 56 118 36 118 76s118 20 118 30" stroke="var(--acc)" stroke-width="3"
        stroke-linecap="round" fill="none"/>
      <rect x="270" y="145" width="16" height="16" rx="2" transform="rotate(45 278 153)" fill="var(--acc)"/>
      <circle cx="160" cy="123" r="5" fill="var(--bg)" stroke="var(--acc)" stroke-width="3"/></svg>`;
  if (k === 'track')
    return `<svg width="100%" height="180" viewBox="0 0 320 180" fill="none" aria-hidden="true">
      <circle cx="160" cy="90" r="58" stroke="var(--line)" stroke-width="2"/>
      <circle cx="160" cy="90" r="34" stroke="var(--line2)" stroke-width="2"/>
      <circle cx="160" cy="90" r="11" fill="var(--acc)"/>
      <path d="M160 90 214 52" stroke="var(--acc)" stroke-width="3" stroke-linecap="round"/>
      <circle cx="214" cy="52" r="7" fill="var(--bg)" stroke="var(--acc)" stroke-width="3"/></svg>`;
  return `<svg width="100%" height="180" viewBox="0 0 320 180" fill="none" aria-hidden="true">
    <path d="M160 26 108 48v42c0 30 21 53 52 62 31-9 52-32 52-62V48l-52-22Z" stroke="var(--acc)" stroke-width="3"
      fill="none" stroke-linejoin="round"/>
    <path d="m140 92 14 14 28-30" stroke="var(--acc)" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
}

function panel(i) {
  const p = panels[i];
  const next = i < 2 ? `ob-${panels[i + 1].k}` : 'market-select';
  return `<div class="scr">${statusBar()}
    <div style="display:flex;justify-content:flex-end;padding:0 12px">
      <button class="btn btn--q" style="width:auto;min-height:40px;padding:0 18px;font-size:13px;border:0;background:none;color:var(--txt3)"
        ${go('market-select')}>Skip</button></div>
    <div class="mid">
      ${art(p.k)}
      <h1 class="disp" style="margin-top:34px;text-align:left">${p.t}</h1>
      <p class="lead" style="text-align:left">${p.p}</p>
    </div>
    <div class="pad" style="padding-bottom:26px">
      <div class="dots">${panels.map((_, j) => `<i class="${j === i ? 'on' : ''}"></i>`).join('')}</div>
      <button class="btn" ${go(next)}>${i < 2 ? 'Continue' : 'Get started'}</button>
    </div></div>`;
}

export default {
  splash: {
    section: 'Onboarding', title: 'Splash',
    render: () => `<div class="scr" >
      <div style="flex:1;display:grid;place-items:center">
        <button style="background:none;border:0;cursor:pointer;text-align:center" ${go('ob-send')}>
          <svg width="54" height="76" viewBox="0 0 54 76" fill="none" style="margin-bottom:22px">
            <circle cx="27" cy="11" r="7" stroke="var(--acc)" stroke-width="3"/>
            <path d="M27 20v32" stroke="var(--acc)" stroke-width="3" stroke-linecap="round"/>
            <rect x="20" y="53" width="14" height="14" rx="2" transform="rotate(45 27 60)" fill="var(--acc)"/></svg>
          <div style="font-size:27px;font-weight:800;letter-spacing:-.8px;color:var(--txt)">Vinkol</div>
        </button></div>
      <div style="padding:0 20px 54px;text-align:center;font-size:11px;letter-spacing:.6px;
        text-transform:uppercase;color:var(--txt3);font-weight:700">Logistics, everywhere</div></div>`,
  },
  'ob-send': { section: 'Onboarding', title: 'Onboarding 1', render: () => panel(0) },
  'ob-track': { section: 'Onboarding', title: 'Onboarding 2', render: () => panel(1) },
  'ob-trust': { section: 'Onboarding', title: 'Onboarding 3', render: () => panel(2) },

  'auth-choice': {
    section: 'Onboarding', title: 'Get started',
    render: () => `<div class="scr">${statusBar()}
      <div class="mid" style="text-align:left">
        <svg width="46" height="64" viewBox="0 0 54 76" fill="none" style="margin-bottom:26px">
          <circle cx="27" cy="11" r="7" stroke="var(--acc)" stroke-width="3"/>
          <path d="M27 20v32" stroke="var(--acc)" stroke-width="3" stroke-linecap="round"/>
          <rect x="20" y="53" width="14" height="14" rx="2" transform="rotate(45 27 60)" fill="var(--acc)"/></svg>
        <h1 class="disp">Let's get your<br/>first delivery moving.</h1>
        <p class="lead">Create an account in a minute, or carry on as a guest and sign in when you book.</p>
      </div>
      <div class="pad" style="padding-bottom:26px">
        <button class="btn" ${go('signup')}>Create an account</button>
        ${sp(10)}
        <button class="btn btn--q" ${go('login')}>I already have one</button>
        ${sp(14)}
        <button style="width:100%;background:none;border:0;color:var(--txt3);font:inherit;font-size:13.5px;
          font-weight:600;cursor:pointer" ${go('home')}>Continue as guest</button>
      </div></div>`,
  },
};
