/* Section 3 — Home and the booking flow.
 *
 * The home screen keeps the structure the Flutter app already has:
 *   map with current location  →  address strip over it  →  "set your stops"  →
 *   saved-place tags  →  promotion progress
 * What changes is the execution, not the information architecture. The address overlay is
 * the existing Card-over-GoogleMap pattern; the tags are the existing LocationTags
 * (Add / Home / Office / Gym); the promo is the existing 3-bookings-to-20%-off banner.
 *
 * Flow: home → location-search → package-info → quote → payment → searching → booked.
 * That mirrors booking → packageInfoScreen → mapWithQuoteScreen → deliveryPaymentScreen.
 */

import { icon, statusBar, bar, nav, mapArt, money, taxOn, taxRow, st, sp, go, row } from '../ui.js';
import { rider, activeOrder, savedPlaces } from '../../../js/fixtures.js';

const ADDRESS = '14 Adeola Odeku Street, Victoria Island';

export default {
  home: {
    section: 'Home & booking', title: 'Home (map)',
    render: () => `<div class="scr">${statusBar()}
      <div class="top">
        <div class="av">EO</div>
        <div class="top__t"><small>Thursday, 3 September</small><b>Hello, Emeka</b></div>
      </div>

      <div class="body body--pod pad">
        <!-- Map + current location, as the app shows today -->
        <div class="mapcard">
          ${mapArt()}
          <div class="medot"><i></i></div>
          <div class="mapctl">
            <button class="ico ico--sq" style="width:38px;height:38px" aria-label="My location">
              ${icon('locate', 17)}</button>
            <button class="ico ico--sq" style="width:38px;height:38px" aria-label="Map layers">
              ${icon('layers', 17)}</button>
          </div>
          <div class="addr">
            <span class="addr__i">${icon('pin', 20)}</span>
            <span class="addr__b"><small>Current location</small><b>${ADDRESS}</b></span>
            <button class="addr__go" ${go('location-search')}>Change</button>
          </div>
        </div>

        <!-- What kind of delivery. Three real products the API already supports; the
             names come from what the user is doing, not from orderType. -->
        <div class="sec"><b>What are you sending?</b></div>
        <div class="types">
          <button class="type" aria-pressed="true"><i>${icon('package', 20)}</i>
            <b>One drop-off</b><small>A single address</small></button>
          <button class="type" ${go('stops-multidrop')}><i>${icon('truck', 20)}</i>
            <b>Multi-drop</b><small>One pickup, several stops</small></button>
          <button class="type" ${go('stops-batch')}><i>${icon('store', 20)}</i>
            <b>Batch</b><small>Separate deliveries</small></button>
        </div>

        <!-- Set your stops -->
        <div class="sec"><b>Set your stops</b></div>
        <div class="card" style="padding:0 16px">
          <div class="stops">
            <div class="stops__rail">
              <span class="stops__n"></span><span class="stops__p"></span><span class="stops__n stops__n--end"></span>
            </div>
            <div>
              <button class="stop" style="width:100%;text-align:left;background:none;border:0;color:inherit;font:inherit;cursor:pointer"
                ${go('location-search')}><small>Pickup</small><b>${ADDRESS}</b></button>
              <button class="stop" style="width:100%;text-align:left;background:none;border:0;color:inherit;font:inherit;cursor:pointer"
                ${go('location-search')}><small>Drop off</small><b class="ph">Where is it going?</b></button>
            </div>
          </div>
          <div style="border-top:1px solid var(--line);margin:0 -16px;padding:12px 16px 14px">
            <button style="background:none;border:0;color:var(--acc);font:inherit;font-size:13.5px;
              font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:7px"
              ${go('stops-multidrop')}>${icon('plus', 16)} Add another drop-off</button>
          </div>
        </div>

        <div style="margin-top:14px" class="tags">
          <button class="tag" ${go('location-search')}>${icon('home', 15)} Home</button>
          <button class="tag" ${go('location-search')}>${icon('store', 15)} Office</button>
          <button class="tag" ${go('location-search')}>${icon('star', 15)} Gym</button>
        </div>

        <!-- Live delivery -->
        <div class="sec"><b>Open order</b><button ${go('records')}>See all</button></div>
        <button class="hero" style="display:block;width:100%;text-align:left;border:0;cursor:pointer;font:inherit"
          ${go('detail')}>
          <div class="hero__top">
            <div><span class="hero__lab"><i></i>With rider</span>
              <div class="hero__id">8F2K-9130</div></div>
            <span class="hero__badge">Tracking ID</span>
          </div>
          <div class="hero__route">
            <div><small>Picked up 10:24</small><b>Victoria Island</b></div>
            <span class="hero__arrow"></span>
            <div style="text-align:right"><small>Drop off</small><b>Ikeja Mall</b></div>
          </div>
          <div class="hero__foot">
            <div style="flex:1;min-width:0"><b>${rider.name}</b><small>${rider.vehicle}</small></div>
            <span class="hero__call">${icon('phone', 18)}</span>
          </div>
        </button>

        <div class="sec"><b>Order from a store</b><button ${go('shop')}>Browse</button></div>
        <div class="rows">
          ${row({ icon: 'store', title: 'The Place · VI', meta: 'Restaurants · 1.4 km · 20–30 min',
                  to: 'store', accent: true })}
          ${row({ icon: 'package', title: 'Mega Foods', meta: 'Groceries · 2.1 km · 25–35 min', to: 'store' })}
        </div>

        <!-- Promotion progress, as the app has today — but drawn as a route, because the
             goal is a count of bookings and a count you can see yourself completing beats a
             bar sitting at 66%. The destination is the Line's diamond terminus. -->
        <div class="sec"><b>Rewards</b><button ${go('rewards')}>Details</button></div>
        <button class="rw" style="display:block;width:100%;text-align:left;cursor:pointer;font:inherit"
          ${go('rewards')}>
          <div class="rw__top">
            <span class="rw__eyebrow">September reward</span>
            <span class="rw__chip">20% OFF</span>
          </div>
          <div class="rw__route">
            <span class="rw__stop"><span class="rw__n rw__n--done">${icon('check', 12)}</span>
              <span class="rw__lab">Done</span></span>
            <span class="rw__seg rw__seg--on"></span>
            <span class="rw__stop"><span class="rw__n rw__n--done">${icon('check', 12)}</span>
              <span class="rw__lab">Done</span></span>
            <span class="rw__seg rw__seg--on"></span>
            <span class="rw__stop"><span class="rw__n rw__n--now">3</span>
              <span class="rw__lab rw__lab--on">Next</span></span>
            <span class="rw__seg rw__seg--dash"></span>
            <span class="rw__stop"><span class="rw__n rw__n--goal"><span>${icon('star', 11)}</span></span>
              <span class="rw__lab">Reward</span></span>
          </div>
          <div class="rw__body">
            <b>One more delivery unlocks it</b>
            <small>20% off your next booking. Resets 30 September.</small>
          </div>
        </button>
        ${sp(22)}
      </div>
      ${nav('home')}</div>`,
  },

  'location-search': {
    section: 'Home & booking', title: 'Search a place',
    render: () => `<div class="scr">${statusBar()}${bar('Where to?')}
      <div class="body pad">
        <div class="inp" style="border-radius:999px">${icon('search', 18)}
          <input placeholder="Search for a place or landmark" value="Ikeja City" /></div>

        <div class="rows" style="margin-top:12px">
          <button class="row" ${go('map-pick')}>
            <span class="row__i row__i--acc">${icon('pin', 19)}</span>
            <span class="row__b"><b>Pick on map</b><small>Drop a pin anywhere</small></span>
            <span class="row__c">${icon('chevron', 16)}</span></button>
          <button class="row" ${go('address-form')}>
            <span class="row__i">${icon('receipt', 19)}</span>
            <span class="row__b"><b>Enter an address</b><small>Type it out in full</small></span>
            <span class="row__c">${icon('chevron', 16)}</span></button>
        </div>

        <div class="sec"><b>Results</b></div>
        <div class="rows">
          ${row({ icon: 'pin', title: 'Ikeja City Mall', meta: 'Obafemi Awolowo Way, Alausa · 18.4 km', to: 'package-info' })}
          ${row({ icon: 'pin', title: 'Ikeja GRA', meta: 'Oduduwa Way, Ikeja · 16.2 km', to: 'package-info' })}
          ${row({ icon: 'pin', title: 'Ikeja Computer Village', meta: 'Otigba St, Ikeja · 17.1 km', to: 'package-info' })}
        </div>

        <div class="sec"><b>Saved places</b></div>
        <div class="rows">
          ${savedPlaces.map((p) => row({ icon: p.icon, title: p.title, meta: p.meta, to: 'package-info' })).join('')}
        </div>
        ${sp(22)}
      </div></div>`,
  },

  'map-pick': {
    section: 'Home & booking', title: 'Pick on map',
    render: () => `<div class="scr">
      <div class="mapwrap">${mapArt()}</div>
      <div class="pin" style="left:50%;top:44%">${icon('pin', 22)}</div>
      ${statusBar()}
      <div style="position:absolute;top:52px;left:20px;z-index:4">
        <button class="ico" data-go="back" aria-label="Back">${icon('back', 19)}</button></div>
      <div class="sheet">
        <div class="grip"></div>
        <div style="display:flex;gap:12px;align-items:center">
          <span class="addr__i">${icon('pin', 22)}</span>
          <span style="flex:1;min-width:0">
            <small style="display:block;font-size:10.5px;letter-spacing:.5px;text-transform:uppercase;
              color:var(--txt3);font-weight:700">Drop off</small>
            <b style="display:block;font-size:16px;font-weight:600;margin-top:3px">Ikeja City Mall</b>
            <small style="display:block;font-size:12.5px;color:var(--txt3);margin-top:2px">
              Obafemi Awolowo Way, Alausa</small></span>
        </div>
        ${sp(18)}
        <button class="btn" ${go('package-info')}>Confirm drop off</button>
      </div></div>`,
  },

  'package-info': {
    section: 'Home & booking', title: 'Package details',
    render: () => `<div class="scr">${statusBar()}${bar('Tell us about your package')}
      <div class="body pad">
        <div class="f"><label>What are you sending?</label>
          <div class="inp"><input placeholder="Enter package name" value="Documents" /></div></div>

        <div class="f"><label>Vehicle</label>
          <div class="seg">
            <button aria-pressed="true">Bike</button><button>Car</button>
            <button>Bicycle</button><button>Truck</button></div></div>

        <div class="f"><label>Priority</label>
          <div class="seg"><button aria-pressed="true">Express</button><button>Regular</button></div></div>

        <div style="display:flex;gap:12px">
          <div class="f" style="flex:1"><label>Pickup date</label>
            <div class="inp">${icon('clock', 17)}<input value="Today, 3 Sep" /></div></div>
          <div class="f" style="flex:1"><label>Pickup time</label>
            <div class="inp">${icon('clock', 17)}<input value="Now" /></div></div>
        </div>

        <div class="sec"><b>Receiver</b></div>
        <div class="f" style="margin-top:0"><label>Name</label>
          <div class="inp"><input placeholder="Name" value="Julia Roberts" /></div></div>
        <div class="f"><label>Phone</label>
          <div class="inp"><span style="font-size:14px;color:var(--txt3);font-weight:600">+234</span>
            <input placeholder="Phone" value="802 445 1190" /></div></div>
        <div class="f"><label>Notes for the rider</label>
          <div class="inp" style="min-height:88px;align-items:flex-start;padding-top:15px">
            <input placeholder="Add any special instructions or notes..." /></div></div>
        ${sp(20)}
      </div>
      <div class="dock"><button class="btn" ${go('quote')}>Get a quote</button></div></div>`,
  },

  quote: {
    section: 'Home & booking', title: 'Quote',
    render: () => {
      const opts = [
        ['Bike', 'Up to 10 kg · fastest', '25–35 min', 3200, true],
        ['Car', 'Up to 60 kg · fragile-safe', '30–45 min', 5800, false],
        ['Van', 'Up to 500 kg · bulk', '45–70 min', 14500, false],
      ];
      return `<div class="scr">
        <div class="mapwrap">${mapArt({ route: true, dim: true })}</div>
        <div class="pin" style="left:27%;top:26%">${icon('pin', 20)}</div>
        <div class="pin pin--dest" style="left:77%;top:60%">${icon('home', 19)}</div>
        ${statusBar()}
        <div style="position:absolute;top:52px;left:20px;z-index:4">
          <button class="ico" data-go="back" aria-label="Back">${icon('back', 19)}</button></div>

        <div class="sheet" style="max-height:74%">
          <div class="grip"></div>
          <div class="card" style="padding:0 16px;border:0;background:var(--surf2);border-radius:var(--r-md)">
            <div class="stops">
              <div class="stops__rail"><span class="stops__n"></span><span class="stops__p"></span>
                <span class="stops__n stops__n--end"></span></div>
              <div>
                <div class="stop"><small>Pickup</small><b>${ADDRESS}</b></div>
                <div class="stop"><small>Drop off</small><b>Ikeja City Mall · 18.4 km</b></div></div>
            </div>
          </div>

          <div class="sec"><b>Choose a vehicle</b></div>
          <div class="rows">${opts
            .map(
              ([l, m, eta, p, on]) => `<button class="row" ${on ? 'style="background:var(--acc-dim)"' : ''}>
                <span class="row__i ${on ? 'row__i--acc' : ''}">${icon('truck', 19)}</span>
                <span class="row__b"><b>${l}</b><small>${m}</small></span>
                <span class="row__v"><b>${money(p)}</b><small>${eta}</small></span></button>`
            )
            .join('')}</div>
          ${sp(16)}
          <button class="btn" ${go('payment')}>Review and pay</button>
        </div></div>`;
    },
  },

  payment: {
    section: 'Home & booking', title: 'Review & pay',
    render: () => {
      const total = activeOrder.fee + taxOn(activeOrder.fee);
      return `<div class="scr">${statusBar()}${bar('Review and pay')}
        <div class="body pad">
          <div class="card" style="padding:0 16px">
            <div class="stops">
              <div class="stops__rail"><span class="stops__n"></span><span class="stops__p"></span>
                <span class="stops__n stops__n--end"></span></div>
              <div>
                <div class="stop"><small>Pickup</small><b>${ADDRESS}</b></div>
                <div class="stop"><small>Drop off</small><b>Ikeja City Mall</b></div></div>
            </div>
          </div>

          <div class="sec"><b>Package</b></div>
          <div class="rows">${row({
            icon: 'package', title: 'Documents · Bike · Express',
            meta: 'Julia Roberts · +234 802 445 1190', chevron: true, to: 'package-info',
          })}</div>

          <div class="sec"><b>Payment</b></div>
          <div class="card">
            <dl class="money" style="margin:0">
              <div><dt>Delivery fee</dt><dd>${money(activeOrder.fee)}</dd></div>
              ${taxRow(activeOrder.fee)}
            </dl>
            <hr class="hr"/>
            <dl class="money" style="margin:0"><div class="tot"><dt>Total</dt><dd>${money(total)}</dd></div></dl>
          </div>
          <div style="margin-top:12px">${row({
            icon: 'wallet', title: 'Vinkol wallet', meta: `Balance ${money(128400, { plain: true })}`,
            to: 'wallet', accent: true,
          })}</div>

          ${sp(20)}
        </div>
        <div class="dock">
          <div class="dock__s"><span>Total</span><b>${money(total)}</b></div>
          <button class="btn" ${go('booked')}>Pay and book</button>
        </div></div>`;
    },
  },

  booked: {
    section: 'Home & booking', title: 'Order placed',
    render: () => `<div class="scr">${statusBar()}
      <div class="mid">
        <div style="width:78px;height:78px;border-radius:999px;background:var(--ok-dim);color:var(--ok);
          display:grid;place-items:center;margin:0 auto 24px">${icon('check', 36)}</div>
        <h1 class="disp" style="font-size:26px">Order placed</h1>
        <p class="lead">We'll notify you when a rider picks it up.</p>
        <div class="card" style="margin-top:26px;text-align:left">
          <small style="display:block;font-size:10.5px;letter-spacing:.5px;text-transform:uppercase;
            color:var(--txt3);font-weight:700">Tracking ID</small>
          <div style="display:flex;align-items:center;gap:10px;margin-top:6px">
            <b style="flex:1;font-size:18px;font-weight:700;letter-spacing:.3px;
              font-variant-numeric:tabular-nums">${activeOrder.ref}</b>
            <button class="ico" aria-label="Copy tracking ID">${icon('receipt', 17)}</button></div>
          <div style="margin-top:14px;display:inline-flex">${st('pending')}</div>
        </div>
      </div>
      <div class="pad" style="padding-bottom:26px">
        <button class="btn" ${go('detail')}>View order</button>
        ${sp(10)}
        <button class="btn btn--q" ${go('home')}>Back to home</button></div></div>`,
  },
};
