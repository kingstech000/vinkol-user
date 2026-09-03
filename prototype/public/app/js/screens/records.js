/* Sections 4–6 — Delivery records, package detail, tracking.
 * The list is the operational heart: chips, the live one promoted to the saturated card,
 * everything settled below in dense rows. */

import { icon, statusBar, bar, nav, money, taxOn, taxRow, st, track, trackEnds, ev, sp, go } from '../ui.js';
import { orders, rider, activeOrder } from '../../../js/fixtures.js';

function rec(o) {
  return `<button class="rec" ${go('detail')}>
    <div class="rec__t">
      <span class="row__i">${icon('package', 19)}</span>
      <span class="rec__id"><small>ID Number</small><b>${o.ref.replace('VK-', '')}</b></span>
      ${st(o.status)}
    </div>
    <div class="rec__r">
      <div><small>${o.when}</small><b>${o.from}</b></div>
      <span class="rec__l"></span>
      <div style="text-align:right"><small>${money(o.amount, { plain: true })}</small><b>${o.to}</b></div>
    </div></button>`;
}

export default {
  records: {
    section: 'Delivery records', title: 'Records',
    render: () => `<div class="scr">${statusBar()}
      <div class="top"><div class="top__t"><h1>Delivery records</h1></div>
        <button class="ico" aria-label="Filter">${icon('filter', 19)}</button></div>
      <div class="body body--pod pad">
        <!-- Two order types, two tabs — mirrors the TabController in delivery_screen.dart -->
        <div class="tabs" style="margin-bottom:16px">
          <button aria-selected="true">Deliveries</button>
          <button data-go="records-store">Store orders</button>
        </div>
        <div class="chips">
          <button class="chip" aria-pressed="true">All</button>
          <button class="chip">Pending</button><button class="chip">With rider</button>
          <button class="chip">Delivered</button><button class="chip">Cancelled</button>
        </div>

        <button class="hero" style="display:block;width:100%;text-align:left;border:0;cursor:pointer;
          font:inherit;margin-top:18px" ${go('detail')}>
          <div class="hero__top">
            <div><span class="hero__lab"><i></i>With rider</span>
              <div class="hero__id">8F2K-9130</div></div>
            <span class="hero__badge">Tracking ID</span></div>
          <div class="hero__route">
            <div><small>Picked up 10:24</small><b>Victoria Island</b></div>
            <span class="hero__arrow"></span>
            <div style="text-align:right"><small>Drop off</small><b>Ikeja Mall</b></div></div>
        </button>

        <div class="sec"><b>Earlier</b><span>${orders.length - 1} records</span></div>
        ${orders.slice(1).map(rec).join('')}
        ${sp(22)}
      </div>${nav('records')}</div>`,
  },

  detail: {
    section: 'Package detail', title: 'Package detail',
    render: () => {
      const total = activeOrder.fee + taxOn(activeOrder.fee);
      return `<div class="scr">${statusBar()}
        ${bar('Package detail', `<button class="ico" aria-label="Share">${icon('receipt', 19)}</button>`)}
        <div class="body pad">
          <div class="hero">
            <div class="hero__top">
              <div><span class="hero__lab"><i></i>With rider</span>
                <div class="hero__id">8F2K-9130</div></div>
              <span class="hero__badge">Tracking ID</span></div>
            <div class="grid2" style="margin-top:22px">
              <div><small>Shipper</small><b>Donny Great</b></div>
              <div><small>Recipient</small><b>Julia Roberts</b></div>
              <div><small>From</small><b>Victoria Island</b></div>
              <div><small>To</small><b>Alausa, Ikeja</b></div>
            </div>
          </div>

          <div class="card" style="margin-top:14px">
            <div class="grid2">
              <div><small>Service</small><b>Express bike</b></div>
              <div><small>Weight</small><b>1.3 kg</b></div>
              <div><small>Contents</small><b>Documents</b></div>
              <div><small>Distance</small><b>${activeOrder.distanceKm} km</b></div>
            </div>
            <hr class="hr"/>
            ${track(3)}${trackEnds('Victoria Island', 'Ikeja')}
          </div>

          <div class="sec"><b>Rider</b></div>
          <div class="card" style="display:flex;align-items:center;gap:13px">
            <span class="av">${rider.initials}</span>
            <span style="flex:1;min-width:0"><b style="display:block;font-size:15.5px">${rider.name}</b>
              <small style="display:block;font-size:12.5px;color:var(--txt3)">${rider.vehicle} ·
                ${rider.rating} ★</small></span>
            <button class="ico ico--on" aria-label="Call rider">${icon('phone', 18)}</button></div>

          <div class="sec"><b>Status history</b></div>
          <div class="card" style="padding:4px 18px">
            ${ev('Pending', 'Order created', '10:02', '3 Sep', true)}
            ${ev('With rider', `${rider.name} · ${rider.vehicle}`, '10:24', '3 Sep', true)}
            ${ev('Delivered', 'Not yet', '—', '', false)}
          </div>

          <div class="sec"><b>Payment</b></div>
          <div class="card">
            <dl class="money" style="margin:0">
              <div><dt>Delivery fee</dt><dd>${money(activeOrder.fee)}</dd></div>
              ${taxRow(activeOrder.fee)}
            </dl><hr class="hr"/>
            <dl class="money" style="margin:0"><div class="tot"><dt>Total paid</dt><dd>${money(total)}</dd></div></dl>
          </div>

          <div style="display:flex;gap:10px;margin-top:18px">
            <button class="btn btn--q">${icon('receipt', 17)} Receipt</button>
            <button class="btn btn--q" ${go('support')}>Get help</button></div>
          ${sp(22)}
        </div></div>`;
    },
  },

  'records-store': {
    section: 'Delivery records', title: 'Records · store orders',
    render: () => `<div class="scr">${statusBar()}
      <div class="top"><div class="top__t"><h1>Delivery records</h1></div>
        <button class="ico" aria-label="Filter">${icon('filter', 19)}</button></div>
      <div class="body body--pod pad">
        <div class="tabs" style="margin-bottom:16px">
          <button data-go="records">Deliveries</button>
          <button aria-selected="true">Store orders</button>
        </div>
        <div class="chips">
          <button class="chip" aria-pressed="true">All</button>
          <button class="chip">Pending</button><button class="chip">With shopper</button>
          <button class="chip">Delivered</button>
        </div>

        <button class="hero" style="display:block;width:100%;text-align:left;border:0;cursor:pointer;
          font:inherit;margin-top:18px" ${go('store-order')}>
          <div class="hero__top">
            <div><span class="hero__lab"><i></i>With shopper</span>
              <div class="hero__id">SH-4B71-2208</div></div>
            <span class="hero__badge">3 items</span></div>
          <div class="hero__route">
            <div><small>The Place · VI</small><b>Victoria Island</b></div>
            <span class="hero__arrow"></span>
            <div style="text-align:right"><small>Drop off</small><b>Ikoyi</b></div></div>
        </button>

        <div class="sec"><b>Earlier</b><span>${storeOrders.length} orders</span></div>
        ${storeOrders.map(storeRec).join('')}
        ${sp(22)}
      </div>${nav('records')}</div>`,
  },

  'store-order': {
    section: 'Package detail', title: 'Store order detail',
    render: () => {
      const subtotal = 11400;
      const fee = 1450;
      return `<div class="scr">${statusBar()}
        ${bar('Store order', `<button class="ico" aria-label="Receipt">${icon('receipt', 19)}</button>`)}
        <div class="body pad">
          <div class="hero">
            <div class="hero__top">
              <div><span class="hero__lab"><i></i>With shopper</span>
                <div class="hero__id">SH-4B71-2208</div></div>
              <span class="hero__badge">3 items</span></div>
            <div class="grid2" style="margin-top:22px">
              <div><small>Store</small><b>The Place · VI</b></div>
              <div><small>Ordered</small><b>Today, 11:52</b></div>
              <div><small>Pickup from</small><b>22B Adeola Odeku St</b></div>
              <div><small>Deliver to</small><b>22 Bourdillon Rd, Ikoyi</b></div>
            </div>
          </div>

          <div class="card" style="margin-top:14px">
            ${track(2)}${trackEnds('The Place · VI', 'Ikoyi')}
          </div>

          <div class="sec"><b>Items</b></div>
          <div class="rows">
            ${[['Jollof rice & chicken', 2, 4500], ['Moi moi (2 wraps)', 1, 1800],
               ['Chapman · 50cl', 2, 1200]]
              .map(([t, q, pr]) => `<div class="row" style="cursor:default">
                <span class="row__i">${icon('package', 19)}</span>
                <span class="row__b"><b>${t}</b><small>${q} × ${money(pr, { plain: true })}</small></span>
                <span class="row__v"><b>${money(q * pr)}</b></span></div>`).join('')}
          </div>

          <div class="sec"><b>Status history</b></div>
          <div class="card" style="padding:4px 18px">
            ${ev('Pending', 'Paid with wallet', '11:52', '3 Sep', true)}
            ${ev('With shopper', 'The Place · VI', '11:55', '3 Sep', true)}
            ${ev('Delivered', 'Not yet', '—', '', false)}
          </div>

          <div class="sec"><b>Payment</b></div>
          <div class="card">
            <dl class="money" style="margin:0">
              <div><dt>Subtotal</dt><dd>${money(subtotal)}</dd></div>
              <div><dt>Delivery fee</dt><dd>${money(fee)}</dd></div>
              ${taxRow(subtotal + fee)}
            </dl><hr class="hr"/>
            <dl class="money" style="margin:0">
              <div class="tot"><dt>Total paid</dt>
                <dd>${money(subtotal + fee + taxOn(subtotal + fee))}</dd></div></dl>
          </div>

          <div style="display:flex;gap:10px;margin-top:18px">
            <button class="btn btn--q">${icon('receipt', 17)} Receipt</button>
            <button class="btn btn--q" ${go('support')}>Get help</button></div>
          ${sp(22)}
        </div></div>`;
    },
  },
};

/* Store orders — orderType "Shopping". Different lifecycle from a courier booking: the store
 * has to confirm and prepare before a rider is even involved. */
const storeOrders = [
  { ref: 'SH-3A60-1194', store: 'Mega Foods', items: 7, when: 'Yesterday', amount: 24300, status: 'delivered' },
  { ref: 'SH-2Z59-0083', store: 'HealthPlus Adeola', items: 2, when: 'Yesterday', amount: 8600, status: 'delivered' },
  { ref: 'SH-1Y48-9972', store: 'The Place · VI', items: 4, when: '31 Aug', amount: 13750, status: 'cancelled' },
  { ref: 'SH-0X37-8861', store: 'Slot Systems', items: 1, when: '29 Aug', amount: 189000, status: 'delivered' },
];

function storeRec(o) {
  return `<button class="rec" ${go('store-order')}>
    <div class="rec__t">
      <span class="row__i">${icon('store', 19)}</span>
      <span class="rec__id"><small>Order</small><b>${o.ref.replace('SH-', '')}</b></span>
      ${st(o.status)}
    </div>
    <div class="rec__r">
      <div><small>${o.when} · ${o.items} items</small><b>${o.store}</b></div>
      <span class="rec__l"></span>
      <div style="text-align:right"><small>Total</small><b>${money(o.amount, { plain: true })}</b></div>
    </div></button>`;
}
