/* Section 8 — Profile and settings.
 * Menu structure follows the existing app exactly: Personal Info · Security · Settings ·
 * Support & Help · Log Out, with Settings holding Notification · Language · Delete Account.
 * Everything here maps to users/profile, users/update-profile, or an existing screen. Saved
 * addresses, payment methods, 2FA, device lists and a notifications inbox were removed — none
 * has an endpoint. */

import { icon, statusBar, bar, nav, market, region, money, sp, go, row } from '../ui.js';
import { rider, savedPlaces } from '../../../js/fixtures.js';

const toggle = (label, meta, on) => `<div class="row" style="cursor:default">
  <span class="row__b"><b>${label}</b>${meta ? `<small>${meta}</small>` : ''}</span>
  <button class="sw" aria-pressed="${on}" aria-label="${label}"></button></div>`;

export default {
  profile: {
    section: 'Profile & settings', title: 'Profile',
    render: () => `<div class="scr">${statusBar()}
      <div class="top"><div class="top__t"><h1>Profile</h1></div>
        <button class="ico" ${go('settings')} aria-label="Settings">${icon('filter', 19)}</button></div>
      <div class="body body--pod pad">
        <div class="card" style="display:flex;align-items:center;gap:14px">
          <span class="av" style="width:56px;height:56px;font-size:17px">EO</span>
          <span style="flex:1;min-width:0">
            <b style="display:block;font-size:18px;letter-spacing:-.3px">Emeka Obi</b>
            <small style="display:block;font-size:13px;color:var(--txt3);margin-top:3px">
              emeka@example.com</small></span>
          <button class="ico" ${go('personal-info')} aria-label="Edit">${icon('chevron', 18)}</button></div>

        <div class="sec"><b>Account</b></div>
        <div class="rows">
          ${row({ icon: 'user', title: 'Personal info', meta: 'Manage your personal information', to: 'personal-info' })}
          ${row({ icon: 'shield', title: 'Security', meta: 'Password and security settings', to: 'security' })}
          ${row({ icon: 'store', title: 'Bank account', meta: 'For wallet withdrawals' })}
        </div>

        <div class="sec"><b>App</b></div>
        <div class="rows">
          ${row({ icon: 'filter', title: 'Settings', meta: 'App preferences and configuration', to: 'settings' })}
          ${row({ icon: 'receipt', title: 'Download report', meta: 'Your order history as a file' })}
          ${row({ icon: 'message', title: 'Support & help', meta: 'Get help and contact support', to: 'support' })}
        </div>

        <div style="margin-top:18px"><button class="btn btn--bad" ${go('auth-choice')}>Log out</button></div>
        <div style="text-align:center;margin-top:16px;font-size:12px;color:var(--txt3)">Vinkol 2.0.3 (35)</div>
        ${sp(22)}
      </div>${nav('profile')}</div>`,
  },

  'personal-info': {
    section: 'Profile & settings', title: 'Personal info',
    render: () => `<div class="scr">${statusBar()}
      ${bar('Personal info', `<button class="ico" aria-label="Save"
        style="width:auto;padding:0 15px;border-radius:999px;color:var(--acc);font-size:13px;font-weight:700">Save</button>`)}
      <div class="body pad">
        <div style="text-align:center;margin:6px 0 4px">
          <span class="av" style="width:78px;height:78px;font-size:24px;margin:0 auto">EO</span>
          <button style="display:block;margin:12px auto 0;background:none;border:0;color:var(--acc);
            font:inherit;font-size:13px;font-weight:600;cursor:pointer">Change photo</button></div>

        <div class="f"><label>Full name</label><div class="inp"><input value="Emeka Obi" /></div></div>
        <div class="f"><label>Email</label><div class="inp"><input value="emeka@example.com" /></div></div>
        <div class="f"><label>Phone number</label>
          <div class="inp"><span style="font-size:14px;color:var(--txt3);font-weight:600">
            ${market().dialCode}</span>
            <input value="${market().phoneExample}" /></div></div>
        <div class="f"><label>${market().regionLabel}</label>
          <div class="inp"><input value="${region().name}" />${icon('chevron', 16)}</div>
          <div class="hint">Used to price deliveries and match riders near you.</div></div>
        ${sp(22)}
      </div></div>`,
  },

  security: {
    section: 'Profile & settings', title: 'Security',
    render: () => `<div class="scr">${statusBar()}${bar('Security')}
      <div class="body pad">
        <div class="sec" style="margin-top:6px"><b>Sign in</b></div>
        <div class="rows">
          ${row({ icon: 'shield', title: 'Change password', meta: 'Sends a reset code to your email',
                  to: 'reset-request' })}
        </div>

        <div class="sec"><b>Transactions</b></div>
        <div class="rows">
          ${row({ icon: 'card', title: 'Transaction PIN', meta: 'Required to confirm wallet withdrawals' })}
        </div>
        ${sp(22)}
      </div></div>`,
  },

  settings: {
    section: 'Profile & settings', title: 'Settings',
    render: () => `<div class="scr">${statusBar()}${bar('Settings')}
      <div class="body pad">
        <div class="sec" style="margin-top:6px"><b>Preferences</b></div>
        <div class="rows">
          ${row({ icon: 'inbox', title: 'Notifications', meta: 'Delivery updates', to: 'notifications' })}
          ${row({ icon: 'message', title: 'Language',
                  meta: market().languages.length > 1
                    ? `English · ${market().languages.length} available`
                    : 'English', chevron: true })}
          ${row({ icon: 'pin', title: 'Country',
                  meta: `${market().name} · ${region().name} · ${market().currency}`,
                  to: 'market-select' })}
        </div>

        <div class="sec"><b>Legal</b></div>
        <div class="rows">
          ${row({ icon: 'receipt', title: 'Terms of service' })}
          ${row({ icon: 'shield', title: 'Privacy policy' })}
        </div>

        <div class="sec"><b>Danger zone</b></div>
        <div class="rows">
          <button class="row"><span class="row__i" style="background:var(--bad-dim);color:var(--bad)">
            ${icon('alert', 19)}</span>
            <span class="row__b"><b style="color:var(--bad)">Delete account</b>
              <small>Permanently removes your data</small></span>
            <span class="row__c">${icon('chevron', 16)}</span></button>
        </div>
        ${sp(22)}
      </div></div>`,
  },

  notifications: {
    section: 'Profile & settings', title: 'Notifications',
    render: () => `<div class="scr">${statusBar()}${bar('Notifications')}
      <div class="body pad">
        <div class="rows" style="margin-top:6px">
          ${toggle('Push notifications', 'Order updates sent to this device', true)}
        </div>
        <div class="hint" style="margin-top:14px">Vinkol sends push notifications when an order
          changes status. There is no message history — notifications are not stored.</div>
        ${sp(22)}
      </div></div>`,
  },

  support: {
    section: 'Profile & settings', title: 'Support',
    render: () => `<div class="scr">${statusBar()}${bar('Support & help')}
      <div class="body pad">
        <div class="sec" style="margin-top:6px"><b>Contact</b></div>
        <div class="rows">
          ${row({ icon: 'phone', title: 'Call support', meta: `${market().support} · ${market().supportHours}` })}
          ${row({ icon: 'inbox', title: 'Email', meta: 'help@vinkol.com' })}
        </div>
        <div class="hint" style="margin-top:14px">Support contacts come from your market —
          you're seeing ${market().name}. Phone and email only; there is no in-app chat.</div>
        ${sp(22)}
      </div></div>`,
  },
};
