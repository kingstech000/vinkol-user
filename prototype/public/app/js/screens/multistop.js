/* Multi-stop booking.
 *
 * The API already models three different products; the names it uses ("Delivery", "Bulk",
 * "Multi") describe the payload, not what the user is doing, which is why the flow has never
 * been discoverable. Renamed for the job:
 *
 *   One drop-off   orderType "Delivery"  CreateOrderRequest      1 pickup → 1 drop-off
 *   Multi-drop     orderType "Bulk"      CreateBulkOrderRequest  1 pickup → N drop-offs,
 *                                        chained into ONE route (route[] legs, stops,
 *                                        totalDistance) carried by ONE rider
 *   Batch          orderType "Multi"     CreateMultiOrderRequest N independent deliveries,
 *                                        each its own pickup+drop-off, own colour, own rider
 *
 * The distinction that matters to a user: multi-drop is one trip where order of stops
 * changes the price; batch is several trips that happen to be booked together. So multi-drop
 * gets a numbered, reorderable list, and batch gets separate colour-coded cards.
 *
 * The type is also *derived* — add a second drop-off and you are in multi-drop; add a second
 * pickup and you are in batch. The selector is a shortcut, not a gate.
 */

import { icon, statusBar, bar, mapArt, money, taxOn, taxRow, sp, go, ORDER_COLORS } from '../ui.js';

const PICKUP = '14 Adeola Odeku Street, Victoria Island';

const drops = [
  { to: 'Ikeja City Mall, Alausa', who: 'Julia Roberts', pkg: 'Documents', km: 18.4, price: 3200 },
  { to: '12 Opebi Road, Ikeja', who: 'Tunde Bakare', pkg: 'Laptop sleeve', km: 4.1, price: 1650 },
  { to: '7 Allen Avenue, Ikeja', who: 'Ngozi Eze', pkg: 'Sample pack', km: 2.3, price: 1400 },
];

const batch = [
  { from: 'Victoria Island', to: 'Ikeja City Mall', who: 'Julia Roberts', pkg: 'Documents', km: 18.4, price: 3200 },
  { from: 'Lekki Phase 1', to: 'Yaba', who: 'Tunde Bakare', pkg: 'Laptop', km: 22.7, price: 4100 },
  { from: 'Surulere', to: 'Apapa', who: 'Ngozi Eze', pkg: 'Fabric roll', km: 9.8, price: 2650 },
];

const total = (list) => list.reduce((a, b) => a + b.price, 0);
const km = (list) => list.reduce((a, b) => a + b.km, 0).toFixed(1);

/* Shown at the top of both editors: what the current stop set actually adds up to, in the
 * terms that decide the price. */
function derived(text) {
  return `<div class="derived">${icon('alert', 16)}<span>${text}</span></div>`;
}

export default {
  'stops-multidrop': {
    section: 'Home & booking', title: 'Multi-drop stops',
    render: () => `<div class="scr">${statusBar()}
      ${bar('Multi-drop', `<button class="ico" aria-label="Reorder">${icon('filter', 19)}</button>`)}
      <div class="body pad">
        ${derived(`<b>1 pickup · ${drops.length} drop-offs</b> — one rider, one route. Stops run in the order below.`)}

        <div class="sec"><b>Pickup</b><button ${go('location-search')}>Change</button></div>
        <div class="card" style="padding:14px 16px">
          <div class="mstop" style="padding:0">
            <span class="mstop__n mstop__n--pick">${icon('pin', 14)}</span>
            <span class="mstop__b"><b>${PICKUP}</b>
              <small>Collect everything here · today, now</small></span>
          </div>
        </div>

        <div class="sec"><b>Drop-offs</b><span>${km(drops)} km total</span></div>
        <div class="card" style="padding:2px 16px">
          ${drops
            .map(
              (d, i) => `<div class="mstop">
                <span class="mstop__n">${i + 1}</span>
                <span class="mstop__b"><b>${d.to}</b>
                  <small>${d.who} · ${d.pkg} · ${d.km} km</small></span>
                <span class="mstop__drag" aria-hidden="true">${icon('filter', 16)}</span>
                <button class="mstop__x" aria-label="Remove stop ${i + 1}">${icon('close', 16)}</button>
              </div>`
            )
            .join('')}
        </div>

        <div style="margin-top:12px">
          <button class="btn btn--q" ${go('location-search')}>${icon('plus', 18)} Add a drop-off</button>
        </div>

        <div class="sec"><b>Or</b></div>
        <button class="row" style="border:1px solid var(--line);border-radius:var(--r-md);
          background:var(--surf)" ${go('stops-batch')}>
          <span class="row__i">${icon('store', 19)}</span>
          <span class="row__b"><b>These come from different places</b>
            <small>Switch to Batch — separate pickups, separate riders</small></span>
          <span class="row__c">${icon('chevron', 16)}</span></button>
        ${sp(20)}
      </div>
      <div class="dock">
        <div class="dock__s"><span>${drops.length} stops · ${km(drops)} km</span><b>${money(total(drops))}</b></div>
        <button class="btn" ${go('quote-multidrop')}>Get a quote</button>
      </div></div>`,
  },

  'stops-batch': {
    section: 'Home & booking', title: 'Batch deliveries',
    render: () => `<div class="scr">${statusBar()}${bar('Batch')}
      <div class="body pad">
        ${derived(`<b>${batch.length} separate deliveries</b> — each gets its own rider and its own price.`)}

        <div class="sec"><b>Deliveries</b><span>${km(batch)} km total</span></div>
        ${batch
          .map(
            (b, i) => `<div class="batch" style="--oc:var(--${ORDER_COLORS[i % 5]})">
              <div class="batch__h">
                <span class="batch__dot"></span>
                <b>Delivery ${i + 1}</b>
                <span style="font-size:13px;font-weight:700;font-variant-numeric:tabular-nums">
                  ${money(b.price)}</span>
                <button class="mstop__x" aria-label="Remove delivery ${i + 1}">${icon('close', 16)}</button>
              </div>
              <div class="batch__leg">
                <div class="batch__rail">
                  <span class="batch__n"></span><span class="batch__p"></span>
                  <span class="batch__n batch__n--end"></span>
                </div>
                <div>
                  <div class="batch__s"><small>Pickup</small><b>${b.from}</b></div>
                  <div class="batch__s"><small>Drop off</small><b>${b.to}</b>
                    <small style="text-transform:none;letter-spacing:0;font-weight:400;margin-top:4px">
                      ${b.who} · ${b.pkg} · ${b.km} km</small></div>
                </div>
              </div>
            </div>`
          )
          .join('')}

        <button class="btn btn--q" ${go('location-search')}>${icon('plus', 18)} Add a delivery</button>

        <div class="sec"><b>Or</b></div>
        <button class="row" style="border:1px solid var(--line);border-radius:var(--r-md);
          background:var(--surf)" ${go('stops-multidrop')}>
          <span class="row__i">${icon('truck', 19)}</span>
          <span class="row__b"><b>These all leave from one place</b>
            <small>Switch to Multi-drop — one rider, cheaper per stop</small></span>
          <span class="row__c">${icon('chevron', 16)}</span></button>
        ${sp(20)}
      </div>
      <div class="dock">
        <div class="dock__s"><span>${batch.length} deliveries</span><b>${money(total(batch))}</b></div>
        <button class="btn" ${go('quote-batch')}>Get quotes</button>
      </div></div>`,
  },

  'quote-multidrop': {
    section: 'Home & booking', title: 'Multi-drop quote',
    render: () => {
      return `<div class="scr">
        <div class="mapwrap">${mapArt({ route: true })}</div>
        <div class="pin" style="left:26%;top:23%">${icon('pin', 20)}</div>
        ${drops
          .map(
            (_, i) => `<div class="pin pin--dest" style="left:${[52, 68, 79][i]}%;top:${[40, 52, 63][i]}%;
              width:34px;height:34px;font-size:13px;font-weight:700">${i + 1}</div>`
          )
          .join('')}
        ${statusBar()}
        <div style="position:absolute;top:52px;left:20px;z-index:4">
          <button class="ico" data-go="back" aria-label="Back">${icon('back', 19)}</button></div>

        <div class="sheet" style="max-height:74%">
          <div class="grip"></div>
          <div class="card" style="padding:16px 0">
            <div class="stats">
              <div><b>${drops.length}</b><small>Stops</small></div>
              <div><b>${km(drops)}</b><small>Kilometres</small></div>
              <div><b>1</b><small>Rider</small></div>
            </div>
          </div>

          <div class="sec"><b>Route</b><span>In this order</span></div>
          <div class="card" style="padding:4px 16px">
            <div class="leg">
              <span class="leg__n" style="background:var(--acc);color:var(--on-acc)">${icon('pin', 12)}</span>
              <span class="leg__b"><b>${PICKUP}</b><small>Pickup · collect all ${drops.length}</small></span>
            </div>
            ${drops
              .map(
                (d, i) => `<div class="leg">
                  <span class="leg__n">${i + 1}</span>
                  <span class="leg__b"><b>${d.to}</b><small>${d.who} · ${d.pkg}</small></span>
                  <span class="leg__v">${d.km} km</span>
                </div>`
              )
              .join('')}
          </div>

          <div class="sec"><b>Price</b></div>
          <div class="card">
            <dl class="money" style="margin:0">
              ${drops.map((d, i) => `<div><dt>Stop ${i + 1} · ${d.to.split(',')[0]}</dt>
                <dd>${money(d.price)}</dd></div>`).join('')}
              ${taxRow(total(drops))}
            </dl>
            <hr class="hr"/>
            <dl class="money" style="margin:0">
              <div class="tot"><dt>Total</dt><dd>${money(total(drops) + taxOn(total(drops)))}</dd></div></dl>
            <div class="hint" style="margin-top:10px">Quoted by get-bulk-quote as one route.</div>
          </div>
          ${sp(16)}
          <button class="btn" ${go('payment')}>Review and pay</button>
        </div></div>`;
    },
  },

  'quote-batch': {
    section: 'Home & booking', title: 'Batch quote',
    render: () => {
      const paths = [
        'M95 190C130 210 150 250 190 290',
        'M150 330C190 350 220 390 260 430',
        'M80 420C120 440 170 470 230 500',
      ];
      return `<div class="scr">
        <div class="mapwrap">${mapArt({
          routes: paths.map((d, i) => ({ d, color: ORDER_COLORS[i] })),
        })}</div>
        ${batch
          .map(
            (_, i) => `<div class="pin" style="left:${[24, 38, 20][i]}%;top:${[26, 46, 59][i]}%;
              width:30px;height:30px;background:var(--${ORDER_COLORS[i]});border-width:3px"></div>`
          )
          .join('')}
        ${statusBar()}
        <div style="position:absolute;top:52px;left:20px;z-index:4">
          <button class="ico" data-go="back" aria-label="Back">${icon('back', 19)}</button></div>

        <div class="sheet" style="max-height:74%">
          <div class="grip"></div>
          <div class="card" style="padding:16px 0">
            <div class="stats">
              <div><b>${batch.length}</b><small>Deliveries</small></div>
              <div><b>${km(batch)}</b><small>Kilometres</small></div>
              <div><b>${batch.length}</b><small>Riders</small></div>
            </div>
          </div>

          <div class="sec"><b>Deliveries</b><span>Priced separately</span></div>
          ${batch
            .map(
              (b, i) => `<div class="batch" style="--oc:var(--${ORDER_COLORS[i % 5]})">
                <div class="batch__h">
                  <span class="batch__dot"></span><b>Delivery ${i + 1}</b>
                  <span style="font-size:13px;font-weight:700;font-variant-numeric:tabular-nums">
                    ${money(b.price)}</span>
                </div>
                <div style="font-size:13.5px;color:var(--txt2)">${b.from} → ${b.to}</div>
                <div style="font-size:12.5px;color:var(--txt3);margin-top:3px">
                  ${b.who} · ${b.pkg} · ${b.km} km</div>
              </div>`
            )
            .join('')}

          <div class="card" style="margin-top:4px">
            <dl class="money" style="margin:0">
              <div><dt>${batch.length} deliveries</dt><dd>${money(total(batch))}</dd></div>
              ${taxRow(total(batch))}
            </dl><hr class="hr"/>
            <dl class="money" style="margin:0">
              <div class="tot"><dt>Total</dt>
                <dd>${money(total(batch) + taxOn(total(batch)))}</dd></div></dl>
            <div class="hint" style="margin-top:10px">Each delivery is matched to its own rider and
              tracked separately. One of them failing does not affect the others.</div>
          </div>
          ${sp(16)}
          <button class="btn" ${go('payment')}>Review and pay</button>
        </div></div>`;
    },
  },
};
