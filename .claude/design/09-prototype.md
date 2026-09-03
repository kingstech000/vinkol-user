# The Prototype — reference implementation

The built, clickable reference for the redesign. **When the docs and the prototype disagree,
the prototype wins** — it is the thing that was reviewed and approved.

## Running it

```bash
cd prototype && npm install && npm start      # http://localhost:3000/app
PORT=4000 npm start                           # if 3000 is busy
```

The server does not survive a session. Nothing is lost — it is all on disk.

| URL | What |
|---|---|
| `/app` | **The approved prototype.** Direction A (Midnight), 44 screens, fully clickable |
| `/app/<screen-id>` | Deep link to any screen, e.g. `/app/market-select` |
| `/v2` | The three direction studies. Historical — A was chosen |
| `/` | The first attempt (D-01, Quiet Infrastructure). Historical — rejected as "generic" |

Controls: click anything inside the phone · `b` back · `t` theme · `m` market · left rail jumps.

## How it is built

No framework, no build step. Express serves static ES modules.

```
prototype/
  server.js                     Express; /app and /app/:id both serve the harness
  public/app/
    index.html                  harness: rail, device frame, theme + market toggles
    css/app.css                 ALL tokens and components. Light + dark under [data-theme]
    js/main.js                  router. data-go="<id>" navigates, data-go="back" pops
    js/ui.js                    shared chrome: statusBar, bar, nav (pod), st, track, ev, row, mapArt
    js/screens/*.js             one module per section, each exporting { id: {section,title,render} }
  public/js/
    market.js                   THE MARKET LAYER — currency, region tax, address fields, providers
    fixtures.js                 all demo data, NGN base
    icons.js                    the icon set
```

**Every clickable element carries `data-go`.** That one convention is what makes the whole
thing navigable with no per-screen wiring.

## Screens, and where each lands in Flutter

| Prototype | Flutter target |
|---|---|
| `splash` | `features/splash/view/screen/splash_screen.dart` |
| `ob-send` `ob-track` `ob-trust` | `features/onboarding/.../onboarding_screen.dart` |
| **`market-select`** | **new** — `features/market/` (country + region picker) |
| `auth-choice` | `features/auth/view/screens/auth_choice_screen.dart` |
| `login` `signup` `enter-otp` `reset-request` `set-password` `reset-done` | `features/auth/view/screen/*` |
| `home` | `features/booking/view/screen/booking_screen.dart` + `widget/maps_display.dart` |
| `location-search` | `features/booking/view/screen/location_search_screen.dart` |
| `map-pick` | `features/booking/view/screen/map_picker_screen.dart` |
| **`address-form`** | **new** — market-shaped address entry |
| `package-info` | `features/booking/view/screen/package_info_screen.dart` |
| `quote` `payment` `booked` | `features/booking/view/screen/map_with_quote_screen.dart` (**1145 lines — decompose first**) |
| `stops-multidrop` `quote-multidrop` | `bulk_map_with_quote_screen.dart` (`orderType: Bulk`) |
| `stops-batch` `quote-batch` | `multi_map_with_quote_screen.dart` (`orderType: Multi`) |
| `shop` | `features/store/view/screen/tags_screen.dart` |
| `stores` | `features/store/view/screen/store_screen.dart` |
| `store` | `features/store/view/screen/product_list_screen.dart` |
| `product` | `features/store/view/screen/product_detail_screen.dart` |
| `cart` | `features/store/view/screen/cart_screen.dart` (**1119 lines**) |
| `records` `records-store` | `features/delivery/view/screen/delivery_screen.dart` (2-tab controller) |
| `detail` | `features/delivery/view/screen/booking_order_screen.dart` (**1278 lines**) |
| `store-order` | `features/delivery/view/screen/store_order_screen.dart` (**1106 lines**) |
| `wallet` `fund` `withdraw` `transaction` | `features/wallet/view/screen/*` |
| `rewards` | **new** — `features/booking/view/widget/promotion_banner.dart` grows into a screen |
| `profile` `personal-info` `security` `settings` `notifications` `support` | `features/profile/view/screen/*` |

**Deliberately absent** — removed under D-10: live tracking, rider chat, insurance, saved
cards, saved-address CRUD, notifications inbox, 2FA/FaceID/devices, store ratings.

## What is placeholder, and must not be copied

- **Product and store imagery** is a neutral grey block with an icon. There is no asset
  library; a fake photo would flatter the design unfairly.
- **The map is drawn SVG**, not Google Maps. It shows the intended chrome treatment — it does
  not prove the design survives real tiles with real label density. **This is the biggest
  untested risk** and should be checked early in WP7.
- **Fixture money is NGN converted at a fixed rate** for illustration. Real markets price
  natively; Canadian fees are not Nigerian fees converted.
- **Fixture rider, orders and products** are invented but use only real model fields.

## Keeping it honest

`prototype/public/app/css/app.css` is the token source of truth until `lib/core/design/` is
reworked (WP1). After that they must change together, in the same commit.

The audit that has been run after every change — reuse it:

```bash
cd prototype && node --input-type=module -e "
import { setMarket, setRegion } from './public/app/js/ui.js';
const names=['onboarding','market','auth','booking','multistop','shop','rewards','records','wallet','profile'];
const mods = await Promise.all(names.map(n => import('./public/app/js/screens/'+n+'.js')));
const S = Object.assign({}, ...mods.map(m => m.default));
const ids = new Set(Object.keys(S)); let bad=0, links=0;
for (const [id,s] of Object.entries(S)) {
  for (const [c,r] of [['NG','LA'],['CA','ON'],['CA','QC']]) { setMarket(c); setRegion(r);
    const h = s.render();
    if (h.includes('undefined')) { console.log('undefined in '+id); bad++; }
    if (/#[0-9a-fA-F]{6}/.test(h)) { console.log('hardcoded colour in '+id); bad++; }
    if (c==='CA' && /₦/.test(h)) { console.log('NGN leaked into CA in '+id); bad++; } }
  setMarket('NG'); setRegion('LA');
  for (const m of s.render().matchAll(/data-go=\"([^\"]+)\"/g)) { links++;
    if (m[1]!=='back' && !ids.has(m[1])) { console.log('dead link '+id+' -> '+m[1]); bad++; } } }
console.log(Object.keys(S).length+' screens · '+links+' targets · '+(bad?bad+' PROBLEMS':'0 problems'));"
```
