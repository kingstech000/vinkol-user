/* Section 2 — Authentication. One form archetype covering every screen here: label above
 * field, error stated in words and tied to the field, one bottom-anchored primary action.
 * Route names mirror the Flutter app (login, signup, enter-otp, reset, set-new-password). */

import { icon, statusBar, bar, sp, go } from '../ui.js';

const field = (label, { ph = '', val = '', ic = '', type = '', err = '', hint = '', right = '' } = {}) => `
  <div class="f">
    <label>${label}</label>
    <div class="inp ${err ? 'inp--err' : ''}">
      ${ic ? `<span style="color:var(--txt3);display:grid">${icon(ic, 18)}</span>` : ''}
      <input placeholder="${ph}" value="${val}" ${type ? `type="${type}"` : ''} />
      ${right}
    </div>
    ${err ? `<div class="err">${icon('alert', 15)}<span>${err}</span></div>` : ''}
    ${hint ? `<div class="hint">${hint}</div>` : ''}
  </div>`;

export default {
  login: {
    section: 'Authentication', title: 'Log in',
    render: () => `<div class="scr">${statusBar()}${bar('Log in')}
      <div class="body pad">
        <h1 class="disp" style="font-size:27px;margin-top:6px">Welcome back</h1>
        <p class="lead" style="font-size:14.5px;margin-top:8px">Use the phone number or email on your account.</p>
        ${field('Phone number or email', { val: 'emeka@example.com', ic: 'user' })}
        ${field('Password', {
          val: 'hunter22', type: 'password', ic: 'shield',
          err: "That password doesn't match this account. Try again or reset it.",
        })}
        <div style="display:flex;justify-content:flex-end;margin-top:12px">
          <button style="background:none;border:0;color:var(--acc);font:inherit;font-size:13px;
            font-weight:600;cursor:pointer" ${go('reset-request')}>Forgot password?</button></div>
        ${sp(20)}
      </div>
      <div class="dock">
        <button class="btn" ${go('home')}>Log in</button>
        <div style="text-align:center;margin-top:16px;font-size:13.5px;color:var(--txt2)">New here?
          <b style="color:var(--acc);cursor:pointer" ${go('signup')}>Create an account</b></div>
      </div></div>`,
  },

  signup: {
    section: 'Authentication', title: 'Sign up',
    render: () => `<div class="scr">${statusBar()}${bar('Create account')}
      <div class="body pad">
        ${field('Full name', { ph: 'Emeka Obi', ic: 'user' })}
        ${field('Email', { ph: 'you@example.com', ic: 'inbox' })}
        ${field('Phone number', { ph: '801 234 5678', ic: 'phone',
          right: `<span style="font-size:14px;color:var(--txt3);font-weight:600;order:-1">+234</span>` })}
        ${field('Password', { ph: 'At least 8 characters', type: 'password', ic: 'shield',
          hint: 'Use 8 or more characters with a number.' })}
        <div style="display:flex;gap:12px;align-items:flex-start;margin-top:20px">
          <button class="sw" aria-pressed="true" aria-label="Accept terms"></button>
          <span style="font-size:13px;line-height:20px;color:var(--txt2)">I agree to the Terms of Service
            and Privacy Policy.</span></div>
        ${sp(20)}
      </div>
      <div class="dock"><button class="btn" ${go('enter-otp')}>Continue</button></div></div>`,
  },

  'enter-otp': {
    section: 'Authentication', title: 'Verify code',
    render: () => `<div class="scr">${statusBar()}${bar('Verify your number')}
      <div class="body pad">
        <p class="lead" style="font-size:14.5px;margin-top:4px">We sent a 6-digit code to
          <b style="color:var(--txt)">+234 801 234 5678</b>.</p>
        <div class="otp" style="margin-top:26px">
          <i class="on">4</i><i class="on">7</i><i class="on">1</i><i class="cur">|</i><i></i><i></i>
        </div>
        <div style="text-align:center;margin-top:24px;font-size:13.5px;color:var(--txt3)">
          Didn't get it? <b style="color:var(--acc);cursor:pointer">Resend in 0:24</b></div>
        ${sp(20)}
      </div>
      <div class="dock"><button class="btn" ${go('home')}>Verify</button></div></div>`,
  },

  'reset-request': {
    section: 'Authentication', title: 'Forgot password',
    render: () => `<div class="scr">${statusBar()}${bar('Reset password')}
      <div class="body pad">
        <p class="lead" style="font-size:14.5px;margin-top:4px">Tell us the email on your account and we'll
          send a code to reset it.</p>
        ${field('Email', { val: 'emeka@example.com', ic: 'inbox' })}
        ${sp(20)}
      </div>
      <div class="dock"><button class="btn" ${go('set-password')}>Send code</button></div></div>`,
  },

  'set-password': {
    section: 'Authentication', title: 'New password',
    render: () => `<div class="scr">${statusBar()}${bar('New password')}
      <div class="body pad">
        <p class="lead" style="font-size:14.5px;margin-top:4px">Choose something you haven't used here before.</p>
        ${field('New password', { ph: 'At least 8 characters', type: 'password', ic: 'shield' })}
        ${field('Confirm password', { ph: 'Repeat it', type: 'password', ic: 'shield' })}
        ${sp(20)}
      </div>
      <div class="dock"><button class="btn" ${go('reset-done')}>Save password</button></div></div>`,
  },

  'reset-done': {
    section: 'Authentication', title: 'Password saved',
    render: () => `<div class="scr">${statusBar()}
      <div class="mid">
        <div style="width:78px;height:78px;border-radius:999px;background:var(--ok-dim);color:var(--ok);
          display:grid;place-items:center;margin:0 auto 26px">${icon('check', 36)}</div>
        <h1 class="disp" style="font-size:27px">Password saved</h1>
        <p class="lead">You can log in with your new password now.</p>
      </div>
      <div class="pad" style="padding-bottom:26px"><button class="btn" ${go('login')}>Back to log in</button></div>
    </div>`,
  },
};
