/* Section 7 — Wallet. Keeps the app's existing Payments / Withdrawals tab split and its
 * balance-plus-history structure; the balance becomes the one large number on the screen and
 * every amount lands on a shared tabular axis. */

import { icon, statusBar, bar, nav, market, money, sp, go, row } from '../ui.js';
import { transactions, walletBalance } from '../../../js/fixtures.js';

const tx = (t) => `<button class="row" ${go('transaction')}>
  <span class="row__i ${t.kind === 'in' ? 'row__i--acc' : ''}" ${t.kind === 'in' ? 'style="color:var(--ok);background:var(--ok-dim)"' : ''}>
    ${icon(t.kind === 'in' ? 'arrowDown' : 'arrowUp', 19)}</span>
  <span class="row__b"><b>${t.title}</b><small>${t.when} · ${t.ref}</small></span>
  <span class="row__v"><b style="${t.kind === 'in' ? 'color:var(--ok)' : ''}">${
    t.kind === 'in' ? '+' : '−'}${money(Math.abs(t.amount))}</b></span></button>`;

export default {
  wallet: {
    section: 'Wallet', title: 'Wallet',
    render: () => `<div class="scr">${statusBar()}
      <div class="top"><div class="top__t"><h1>Wallet</h1></div>
        <button class="ico" aria-label="History">${icon('receipt', 19)}</button></div>
      <div class="body body--pod pad">
        <div class="hero">
          <div class="hero__lab">Available balance</div>
          <div style="font-size:38px;font-weight:800;letter-spacing:-1.3px;margin-top:8px;
            font-variant-numeric:tabular-nums">${money(walletBalance)}</div>
          <div class="hero__foot" style="gap:10px">
            <button class="btn" style="background:#fff;color:var(--acc-deep);min-height:46px;font-size:14px"
              ${go('fund')}>${icon('plus', 17)} Add money</button>
            <button class="btn" style="background:rgba(255,255,255,.18);color:#fff;min-height:46px;font-size:14px"
              ${go('withdraw')}>Withdraw</button></div>
        </div>

        <div class="sec" style="margin-bottom:0"><b>History</b></div>
        <div class="tabs" style="margin-bottom:14px">
          <button aria-selected="true">Payments</button><button>Withdrawals</button></div>
        <div class="rows">${transactions.map(tx).join('')}</div>
        ${sp(22)}
      </div>${nav('wallet')}</div>`,
  },

  fund: {
    section: 'Wallet', title: 'Add money',
    render: () => `<div class="scr">${statusBar()}${bar('Add money')}
      <div class="body pad">
        <div class="f" style="margin-top:8px"><label>Amount</label>
          <div class="inp" style="min-height:74px">
            <span style="font-size:26px;color:var(--txt3);font-weight:600">${money(0, { plain: true }).replace(/[\d.,]/g, '')}</span>
            <input value="25,000" style="font-size:26px;font-weight:700;font-variant-numeric:tabular-nums" /></div>
          <div class="hint">Balance after top-up: ${money(walletBalance + 25000, { plain: true })}</div></div>

        <div style="display:flex;gap:9px;margin-top:14px">
          ${[5000, 10000, 25000, 50000].map((a, i) =>
            `<button class="chip" aria-pressed="${i === 2}" style="flex:1;text-align:center">${money(a, { plain: true })}</button>`
          ).join('')}
        </div>

        <div class="sec"><b>Pay with</b></div>
        <div class="rows">
          ${market().paymentProviders.filter((p) => p.id !== 'wallet')
            .map((p, i) => row({ icon: p.icon, title: p.name, meta: p.note, accent: i === 0,
                                 chevron: false })).join('')}
        </div>
        ${sp(20)}
      </div>
      <div class="dock">
        <div class="dock__s"><span>Adding</span><b>${money(25000)}</b></div>
        <button class="btn" ${go('wallet')}>Add money</button></div></div>`,
  },

  withdraw: {
    section: 'Wallet', title: 'Withdraw',
    render: () => `<div class="scr">${statusBar()}${bar('Withdraw')}
      <div class="body pad">
        <div class="f" style="margin-top:8px"><label>Amount</label>
          <div class="inp" style="min-height:74px">
            <span style="font-size:26px;color:var(--txt3);font-weight:600">${money(0, { plain: true }).replace(/[\d.,]/g, '')}</span>
            <input value="100,000" style="font-size:26px;font-weight:700;font-variant-numeric:tabular-nums" /></div>
          <div class="hint">Available: ${money(walletBalance, { plain: true })}</div></div>

        <div class="sec"><b>To account</b><button>Change</button></div>
        <div class="rows">
          ${row({ icon: 'store', title: 'GTBank · 0123456789', meta: 'Emeka Obi', accent: true })}
        </div>

        <div class="card" style="margin-top:14px;background:var(--warn-dim);border-color:transparent;
          display:flex;gap:13px">
          <span style="color:var(--warn);flex:none">${icon('alert', 20)}</span>
          <span><b style="display:block;font-size:14.5px;color:var(--warn)">Withdrawals are final</b>
            <small style="display:block;font-size:12.5px;color:var(--txt2);margin-top:4px;line-height:18px">
              Once sent we can't reverse it. Check the account number.</small></span></div>
        ${sp(20)}
      </div>
      <div class="dock">
        <div class="dock__s"><span>Withdrawing</span><b>${money(100000)}</b></div>
        <button class="btn" ${go('wallet')}>Confirm withdrawal</button></div></div>`,
  },

  transaction: {
    section: 'Wallet', title: 'Transaction',
    render: () => `<div class="scr">${statusBar()}${bar('Transaction')}
      <div class="body pad">
        <div class="card" style="text-align:center;padding:26px 18px">
          <div style="width:60px;height:60px;border-radius:999px;background:var(--acc-dim);color:var(--acc);
            display:grid;place-items:center;margin:0 auto 18px">${icon('arrowUp', 26)}</div>
          <div style="font-size:34px;font-weight:800;letter-spacing:-1.2px;
            font-variant-numeric:tabular-nums">−${money(3200)}</div>
          <div style="font-size:13.5px;color:var(--txt3);margin-top:8px">Delivery to Ikeja City Mall</div>
          <div style="margin-top:14px;display:inline-flex"><span class="st st--done"><i></i>Successful</span></div>
        </div>

        <div class="card" style="margin-top:14px">
          <div class="grid2">
            <div><small>Reference</small><b>8F2K-9130</b></div>
            <div><small>Date</small><b>3 Sep, 10:24</b></div>
            <div><small>Method</small><b>Vinkol wallet</b></div>
            <div><small>Type</small><b>Debit</b></div>
          </div>
        </div>

        <div style="display:flex;gap:10px;margin-top:18px">
          <button class="btn btn--q">${icon('receipt', 17)} Receipt</button>
          <button class="btn" ${go('detail')}>View delivery</button></div>
        ${sp(22)}
      </div></div>`,
  },
};
