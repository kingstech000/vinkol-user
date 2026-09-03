/* Country selection — the entry point to the market layer.
 *
 * Listed as a required screen in the brief and absent from the app today, because the app
 * assumes Nigeria everywhere. Choosing here sets currency, decimals, whether tax is displayed
 * and what it is called, the administrative-region label, the address field order, the dial
 * code and support contact. No screen after this point knows what country it is in.
 *
 * No flag emoji: inconsistent across platforms and politically loaded. Country names only.
 */

import { icon, statusBar, bar, market, region, money, taxOn, MARKETS_LIST, sp, go } from '../ui.js';

function option(m, active) {
  return `<button class="row" ${go('home')} style="${active ? 'background:var(--acc-dim)' : ''}">
    <span class="row__i ${active ? 'row__i--acc' : ''}" style="font-size:12px;font-weight:800;
      letter-spacing:.5px">${m.flagless}</span>
    <span class="row__b"><b>${m.name}</b>
      <small>${m.currency} · ${m.regionLabel.toLowerCase()}s · ${m.showTax ? m.taxLabel + ' shown' : 'no separate tax'}</small></span>
    ${active ? `<span style="color:var(--acc)">${icon('check', 18)}</span>`
             : `<span class="row__c">${icon('chevron', 16)}</span>`}</button>`;
}

export default {
  'market-select': {
    section: 'Onboarding', title: 'Choose country',
    render: () => {
      const cur = market();
      return `<div class="scr">${statusBar()}${bar('Where are you?')}
        <div class="body pad">
          <p class="lead" style="font-size:14.5px;margin-top:2px">
            This sets your currency, how prices and tax are shown, and how addresses and phone
            numbers are entered. You can change it later in Settings.</p>

          <div class="sec"><b>Available markets</b></div>
          <div class="rows">
            ${MARKETS_LIST.map((m) => option(m, m.code === cur.code)).join('')}
          </div>

          <div class="sec"><b>${cur.regionLabel}</b>
            <span>${cur.showTax ? 'sets your tax rate' : 'same rate nationwide'}</span></div>
          <div class="chips">
            ${cur.regions.map((r) => `<button class="chip" aria-pressed="${r.code === region().code}"
              data-region="${r.code}">${r.name}</button>`).join('')}
          </div>
          ${cur.showTax ? `<div class="hint" style="margin-top:12px">
            ${region().name} charges <b style="color:var(--txt)">${region().taxLabel}</b> at
            ${(region().taxRate * 100).toFixed(region().taxRate * 100 % 1 ? 3 : 0)}% —
            ${money(10000, { plain: true })} of delivery becomes
            ${money(10000 + taxOn(10000), { plain: true })}. Rates differ by
            ${cur.regionLabel.toLowerCase()}, so tax cannot be one number per country.</div>` : ''}

          <div class="sec"><b>What changes</b></div>
          <div class="card">
            <div class="grid2">
              <div><small>Currency</small><b>${cur.currency} · ${cur.symbol}</b></div>
              <div><small>Decimals</small><b>${cur.decimals}</b></div>
              <div><small>Tax</small><b>${cur.showTax ? region().taxLabel + ' · shown' : 'Not shown separately'}</b></div>
              <div><small>${cur.regionLabel}</small><b>${region().name}</b></div>
              <div><small>Phone</small><b>${cur.dialCode} ${cur.phoneExample}</b></div>
              <div><small>Languages</small><b>${cur.languages.join(' · ')}</b></div>
              <div><small>Payment</small><b>${cur.paymentProviders.map((x) => x.name.replace('Vinkol ', '')).join(', ')}</b></div>
              <div><small>Support</small><b>${cur.supportHours}</b></div>
            </div>
            <hr class="hr"/>
            <small style="display:block;font-size:11px;letter-spacing:.5px;text-transform:uppercase;
              color:var(--txt3);font-weight:700">Address fields, in order</small>
            <div style="display:flex;flex-wrap:wrap;gap:7px;margin-top:10px">
              ${cur.addressFields.map((f, i) =>
                `<span class="chip" style="cursor:default;font-size:12px;padding:7px 13px">
                  ${i + 1}. ${f}</span>`).join('')}
            </div>
          </div>

          <div class="hint" style="margin-top:14px">More markets follow the same layer — a new
            country is configuration, not a new build.</div>
          ${sp(22)}
        </div>
        <div class="dock"><button class="btn" ${go('home')}>Continue in ${cur.name}</button></div>
      </div>`;
    },
  },

  'address-form': {
    section: 'Onboarding', title: 'Enter an address',
    render: () => {
      const m = market();
      const fields = m.addressFields;
      return `<div class="scr">${statusBar()}${bar('Enter an address')}
        <div class="body pad">
          <p class="lead" style="font-size:14.5px;margin-top:2px">
            Address fields and their order come from your market. Nigeria has no postal code in
            everyday use; Canada cannot deliver without one.</p>

          ${fields.map((f) => {
            const isRegion = f === m.regionLabel;
            const isPost = /postal|zip/i.test(f);
            return `<div class="f"><label>${f}</label>
              <div class="inp">
                ${isPost ? `<span style="color:var(--txt3);display:grid">${icon('pin', 17)}</span>` : ''}
                <input placeholder="${isPost ? m.postcodePattern
                  : isRegion ? region().name : ''}"
                  ${isRegion ? `value="${region().name}"` : ''} />
                ${isRegion ? icon('chevron', 16) : ''}
              </div>
              ${isPost ? `<div class="hint">Format ${m.postcodePattern}. Required for
                ${m.name} deliveries.</div>` : ''}
            </div>`;
          }).join('')}

          <div class="card" style="margin-top:22px;display:flex;gap:12px">
            <span style="color:var(--acc);flex:none">${icon('alert', 18)}</span>
            <span style="font-size:13px;line-height:19px;color:var(--txt2)">
              <b style="color:var(--txt)">${fields.length} fields for ${m.name}.</b>
              A fixed address struct will not survive the next market — the backend should store
              addresses as an ordered, market-defined field set.</span></div>
          ${sp(20)}
        </div>
        <div class="dock"><button class="btn" data-go="back">Save address</button></div>
      </div>`;
    },
  },
};
