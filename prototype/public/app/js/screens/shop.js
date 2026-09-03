/* Section — Shop.
 *
 * The app's second order type: orderType "Shopping" rather than "Delivery". You buy from a
 * store and Vinkol delivers it, so the money is subtotal + a *quoted* delivery fee (which may
 * come from an external provider like Chowdeck, or internal), and the pickup point is the
 * store's address rather than one you choose.
 *
 * Browse order follows the app: TagsScreen (categories) → StoresScreen → ProductListScreen →
 * ProductDetailScreen → CartScreen.
 *
 * Product and store imagery is a placeholder block here — the prototype has no asset library
 * and inventing one would misrepresent how these screens will actually look.
 */

import { icon, statusBar, bar, nav, market, money, taxOn, taxRow, sp, go, row, st } from '../ui.js';

const cats = [
  ['Restaurants', 'store', 128], ['Groceries', 'package', 86],
  ['Pharmacy', 'shield', 34], ['Electronics', 'card', 51],
  ['Fashion', 'star', 72], ['Home & living', 'home', 45],
];

/* StoreModel has name, address, lga, state, avatar and opening hours. It has no rating,
 * no distance and no prep-time estimate — so none of those appear. */
const stores = [
  { name: 'Mega Foods', cat: 'Groceries', area: 'Adeola Odeku, VI', open: true },
  { name: 'The Place · VI', cat: 'Restaurants', area: 'Ligali Ayorinde, VI', open: true },
  { name: 'HealthPlus Adeola', cat: 'Pharmacy', area: 'Akin Adesola, VI', open: true },
  { name: 'Slot Systems', cat: 'Electronics', area: 'Saka Tinubu, VI', open: false },
];

const products = [
  { t: 'Jollof rice & chicken', p: 4500, cat: 'Main' },
  { t: 'Suya platter (large)', p: 7200, cat: 'Main' },
  { t: 'Moi moi (2 wraps)', p: 1800, cat: 'Sides' },
  { t: 'Chapman · 50cl', p: 1200, cat: 'Drinks' },
  { t: 'Puff puff (6 pcs)', p: 1500, cat: 'Sides' },
  { t: 'Zobo · 50cl', p: 900, cat: 'Drinks' },
];

const cart = [
  { t: 'Jollof rice & chicken', p: 4500, q: 2 },
  { t: 'Moi moi (2 wraps)', p: 1800, q: 1 },
  { t: 'Chapman · 50cl', p: 1200, q: 2 },
];

const SUBTOTAL = cart.reduce((a, c) => a + c.p * c.q, 0);
const DELIVERY_FEE = 1450;

/* Neutral placeholder — no asset library, and a fake photo would flatter the design unfairly. */
const shot = (h = 96, ic = 'package') => `<div style="height:${h}px;border-radius:var(--r-md);
  background:var(--surf2);display:grid;place-items:center;color:var(--txt3);flex:none">
  ${icon(ic, Math.round(h / 3.4))}</div>`;

const qty = (n) => `<div style="display:flex;align-items:center;gap:12px;background:var(--surf2);
  border-radius:999px;padding:5px">
  <button style="width:30px;height:30px;border-radius:999px;border:0;background:var(--surf3);
    color:var(--txt);cursor:pointer;display:grid;place-items:center" aria-label="Fewer">${icon('close', 13)}</button>
  <b style="font-size:14px;font-variant-numeric:tabular-nums;min-width:14px;text-align:center">${n}</b>
  <button style="width:30px;height:30px;border-radius:999px;border:0;background:var(--acc);
    color:var(--on-acc);cursor:pointer;display:grid;place-items:center" aria-label="More">${icon('plus', 13)}</button>
</div>`;

export default {
  shop: {
    section: 'Shop', title: 'Shop (categories)',
    render: () => `<div class="scr">${statusBar()}
      <div class="top"><div class="top__t"><h1>Shop</h1>
        <small style="font-size:13px;color:var(--txt3)">Browse stores by category</small></div>
        <button class="ico" ${go('cart')} aria-label="Cart">${icon('package', 19)}</button></div>
      <div class="body body--pod pad">
        <div class="inp" style="border-radius:999px">${icon('search', 18)}
          <input placeholder="Search stores and products" /></div>

        <div class="sec"><b>Categories</b></div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
          ${cats
            .map(
              ([name, ic, n]) => `<button class="card" style="padding:16px;text-align:left;cursor:pointer"
                ${go('stores')}>
                <span style="display:grid;place-items:center;width:42px;height:42px;border-radius:14px;
                  background:var(--acc-dim);color:var(--acc);margin-bottom:12px">${icon(ic, 20)}</span>
                <b style="display:block;font-size:15px">${name}</b>
                <small style="display:block;font-size:12px;color:var(--txt3);margin-top:3px">
                  ${n} stores</small></button>`
            )
            .join('')}
        </div>

        <div class="sec"><b>Near you</b><button ${go('stores')}>See all</button></div>
        <div class="rows">
          ${stores
            .slice(0, 3)
            .map((s) => row({ icon: 'store', title: s.name, meta: `${s.cat} · ${s.area}`, to: 'store' }))
            .join('')}
        </div>
        ${sp(20)}
      </div>${nav('shop')}</div>`,
  },

  stores: {
    section: 'Shop', title: 'Stores',
    render: () => `<div class="scr">${statusBar()}
      ${bar('Groceries', `<button class="ico" aria-label="Filter">${icon('filter', 19)}</button>`)}
      <div class="body pad">
        <div class="inp" style="border-radius:999px">${icon('search', 18)}
          <input placeholder="Search in Groceries" /></div>

        <div class="chips" style="margin-top:14px">
          <button class="chip" aria-pressed="true">All</button>
          <button class="chip">Open now</button>
        </div>

        <div class="sec"><b>${stores.length} stores</b><span>Victoria Island</span></div>
        ${stores
          .map(
            (s) => `<button class="card" style="display:flex;gap:13px;align-items:center;width:100%;
              text-align:left;cursor:pointer;margin-bottom:10px;${s.open ? '' : 'opacity:.6'}"
              ${go('store')}>
              ${shot(58, 'store')}
              <span style="flex:1;min-width:0">
                <b style="display:block;font-size:15.5px">${s.name}</b>
                <small style="display:block;font-size:12.5px;color:var(--txt3);margin-top:3px">
                  ${s.cat} · ${s.area}</small>
                <span style="display:inline-flex;margin-top:8px">
                  ${s.open ? '<span class="st st--done"><i></i>Open</span>'
                           : '<span class="st st--off"><i></i>Closed</span>'}</span>
              </span>
              <span class="row__c">${icon('chevron', 16)}</span></button>`
          )
          .join('')}
        ${sp(20)}
      </div></div>`,
  },

  store: {
    section: 'Shop', title: 'Store & products',
    render: () => `<div class="scr">${statusBar()}
      ${bar('The Place · VI', `<button class="ico" ${go('cart')} aria-label="Cart">${icon('package', 19)}</button>`)}
      <div class="body pad">
        <div class="card" style="display:flex;gap:13px;align-items:center">
          ${shot(56, 'store')}
          <span style="flex:1;min-width:0">
            <b style="display:block;font-size:16px">The Place · VI</b>
            <small style="display:block;font-size:12.5px;color:var(--txt3);margin-top:3px">
              Restaurants · Ligali Ayorinde, VI</small></span>
          <span class="st st--done"><i></i>Open</span></div>

        <div class="card" style="margin-top:10px;display:flex;gap:12px;align-items:center;padding:14px 16px">
          <span style="color:var(--acc);flex:none">${icon('pin', 18)}</span>
          <span style="flex:1;min-width:0;font-size:13px;color:var(--txt2)">
            22B Adeola Odeku Street, Victoria Island</span>
          <button class="addr__go">Directions</button></div>

        <div class="chips" style="margin-top:16px">
          <button class="chip" aria-pressed="true">All</button><button class="chip">Main</button>
          <button class="chip">Sides</button><button class="chip">Drinks</button>
        </div>

        <div class="sec"><b>Menu</b><span>${products.length} items</span></div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
          ${products
            .map(
              (pr) => `<button class="card" style="padding:10px;text-align:left;cursor:pointer"
                ${go('product')}>
                ${shot(84)}
                <b style="display:block;font-size:14px;margin-top:10px;line-height:19px">${pr.t}</b>
                <div style="display:flex;align-items:center;justify-content:space-between;margin-top:8px">
                  <span style="font-size:14.5px;font-weight:700;
                    font-variant-numeric:tabular-nums">${money(pr.p)}</span>
                  <span style="width:28px;height:28px;border-radius:999px;background:var(--acc);
                    color:var(--on-acc);display:grid;place-items:center">${icon('plus', 15)}</span>
                </div></button>`
            )
            .join('')}
        </div>
        ${sp(20)}
      </div>
      <div class="dock">
        <div class="dock__s"><span>${cart.length} items in cart</span><b>${money(SUBTOTAL)}</b></div>
        <button class="btn" ${go('cart')}>View cart</button></div></div>`,
  },

  product: {
    section: 'Shop', title: 'Product',
    render: () => `<div class="scr">${statusBar()}
      ${bar('Jollof rice & chicken', `<button class="ico" aria-label="Save">${icon('star', 19)}</button>`)}
      <div class="body pad">
        ${shot(210)}
        <h1 style="font-size:22px;font-weight:700;letter-spacing:-.4px;margin:18px 0 0">
          Jollof rice & chicken</h1>
        <div style="font-size:24px;font-weight:800;margin-top:10px;
          font-variant-numeric:tabular-nums">${money(4500)}</div>
        <p style="font-size:14.5px;line-height:23px;color:var(--txt2);margin:14px 0 0">
          Party-style jollof with grilled chicken thigh, fried plantain and a side of coleslaw.
          Served hot.</p>

        <div class="sec"><b>Sold by</b></div>
        <div class="rows">${row({
          icon: 'store', title: 'The Place · VI', meta: 'Ligali Ayorinde, VI', to: 'store',
        })}</div>

        <div class="sec"><b>Quantity</b></div>
        <div class="card" style="display:flex;align-items:center;justify-content:space-between">
          <span style="font-size:14.5px;color:var(--txt2)">How many?</span>${qty(2)}</div>
        ${sp(20)}
      </div>
      <div class="dock">
        <div class="dock__s"><span>2 × ${money(4500, { plain: true })}</span><b>${money(9000)}</b></div>
        <button class="btn" ${go('cart')}>${icon('plus', 17)} Add to cart</button></div></div>`,
  },

  cart: {
    section: 'Shop', title: 'Cart & checkout',
    render: () => {
      const goods = SUBTOTAL + DELIVERY_FEE;
      const total = goods + taxOn(goods);
      return `<div class="scr">${statusBar()}
        ${bar('Your cart', `<button class="ico" aria-label="Clear cart">${icon('close', 19)}</button>`)}
        <div class="body pad">
          <div class="derived">${icon('store', 16)}
            <span><b>The Place · VI</b> — one store per order. Items from another store start a new cart.</span>
          </div>

          <div class="sec"><b>Items</b><span>${cart.length}</span></div>
          ${cart
            .map(
              (c) => `<div class="card" style="display:flex;gap:12px;align-items:center;margin-bottom:10px;
                padding:12px">
                ${shot(52)}
                <span style="flex:1;min-width:0">
                  <b style="display:block;font-size:14.5px">${c.t}</b>
                  <small style="display:block;font-size:13px;color:var(--txt3);margin-top:3px;
                    font-variant-numeric:tabular-nums">${money(c.p, { plain: true })} each</small></span>
                ${qty(c.q)}</div>`
            )
            .join('')}

          <div class="sec"><b>Delivering to</b><button ${go('location-search')}>Change</button></div>
          <div class="rows">${row({
            icon: 'pin', title: '22 Bourdillon Road, Ikoyi', meta: 'Set on this order',
            accent: true, to: 'location-search',
          })}</div>

          <div class="sec"><b>Delivery option</b></div>
          <div class="rows">
            <button class="row" style="background:var(--acc-dim)">
              <span class="row__i row__i--acc">${icon('truck', 19)}</span>
              <span class="row__b"><b>Vinkol rider</b><small>Quoted by shopping-delivery-fee</small></span>
              <span class="row__v"><b>${money(DELIVERY_FEE)}</b></span></button>
            <button class="row">
              <span class="row__i">${icon('store', 19)}</span>
              <span class="row__b"><b>Partner courier</b><small>Chowdeck</small></span>
              <span class="row__v"><b>${money(1100)}</b></span></button>
          </div>

          <div class="sec"><b>Payment</b></div>
          <div class="card">
            <dl class="money" style="margin:0">
              <div><dt>Subtotal</dt><dd>${money(SUBTOTAL)}</dd></div>
              <div><dt>Delivery fee</dt><dd>${money(DELIVERY_FEE)}</dd></div>
              ${taxRow(goods)}
            </dl><hr class="hr"/>
            <dl class="money" style="margin:0"><div class="tot"><dt>Total</dt><dd>${money(total)}</dd></div></dl>
          </div>

          <!-- Providers are market-scoped: Paystack has no Canadian presence, and Interac
               has no Nigerian one. -->
          <div class="rows" style="margin-top:12px">
            ${market().paymentProviders.map((pr, i) => `<button class="row"
              ${i === 0 ? 'style="background:var(--acc-dim)"' : ''}>
              <span class="row__i ${i === 0 ? 'row__i--acc' : ''}">${icon(pr.icon, 19)}</span>
              <span class="row__b"><b>${pr.name}</b><small>${
                pr.id === 'wallet' ? `Balance ${money(128400, { plain: true })}` : pr.note}</small></span>
              ${i === 0 ? `<span style="color:var(--acc)">${icon('check', 17)}</span>`
                        : `<span class="row__c">${icon('chevron', 16)}</span>`}</button>`).join('')}
          </div>
          ${sp(20)}
        </div>
        <div class="dock">
          <div class="dock__s"><span>Total</span><b>${money(total)}</b></div>
          <button class="btn" ${go('store-order')}>Place order</button></div></div>`;
    },
  },
};
