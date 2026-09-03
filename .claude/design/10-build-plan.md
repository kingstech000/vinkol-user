# Build Plan — Flutter implementation

Fourteen work packages, ordered by dependency. Each is one session's work. The prompt for each
is at the bottom of this file — paste it verbatim to start that session.

**Nothing after WP1 makes sense before WP1**, because every screen reads tokens.

## Order

```
WP1   Design tokens          rework lib/core/design to Midnight, wire the theme   [blocks all]
WP2   Market layer           lib/core/market — currency, region tax, addresses    [blocks money]
WP3   Localization           flutter_localizations + ARB + French                 [Quebec gate]
WP4   Core components        pod, hero, status, rows, the Line, track, forms      [blocks screens]
WP5   Shell & states         dashboard pod, app bars, loading/empty/error         [blocks screens]
── screens below here can run in parallel once WP1–WP5 land ──
WP6   Onboarding + auth      splash, 3 panels, country select, login/signup/OTP
WP7   Home + booking         map home, stops, package info, quote, pay      [decompose first]
WP8   Multi-drop + batch     Bulk and Multi order types                     [consolidate first]
WP9   Shop                   categories, stores, products, cart             [decompose first]
WP10  Records + detail       both tabs, order detail, store-order detail    [decompose first]
WP11  Wallet                 balance, fund, withdraw, transaction
WP12  Profile & settings     profile, personal info, security, settings, support
WP13  Rewards                progress + unlocked states
WP14  Cleanup                delete dead files, decompose god screens
```

`[decompose first]` means the target file is 550–1300 lines and must be split into widgets in a
**separate commit** before it is restyled. Never restructure and restyle in one diff.

## Standing rules for every session

- Load the `vinkol-design-system` skill before writing UI. A PostToolUse hook flags violations.
- `AppText`, `Gap`, `AppButton`, `AppColors` keep their public API (D-03) — 202 files depend on them.
- No `.sp` on text (D-04). No raw hex or bare `Colors.*` outside `lib/core/design/`.
- Status is label + shape + colour (D-05), from the closed set of six (D-10).
- No money literal outside the market layer (D-09).
- Build loading, empty and error states, not just the happy path.
- `flutter analyze` clean for touched files, and report the real output.
- Match the prototype at `/app/<screen-id>`; when docs and prototype disagree, the prototype wins.

---

# The prompts

Paste one of these to start a session. Each is self-contained.

---

## WP1 — Design tokens

```
Rework lib/core/design/ to match the ratified Midnight direction, then wire it into the app.

Read first: .claude/design/05-decisions.md (D-07, D-08), .claude/design/04-tokens.md,
.claude/design/09-prototype.md, and prototype/public/app/css/app.css — that CSS is the
current token source of truth.

The existing lib/core/design/ was built for the rejected D-01 direction and is stale:
light-first defaults and a 4/8/12/20 radius scale. Midnight is dark-first with 12/18/24/full.

Do:
1. Re-point VinkolPalette and VinkolColors at the Midnight values in app.css — both the dark
   and light semantic sets. Dark carries NO shadows (depth is surface lightness); light has
   two soft shadows.
2. Fix VinkolRadius to 12 / 18 / 24 / full.
3. Keep VinkolType, VinkolSpace and VinkolMotion as they are — those survived the direction
   change unchanged.
4. Wire VinkolTheme.light()/.dark() into MaterialApp in lib/main.dart, replacing the inline
   ThemeData.light().copyWith(...). Delete lib/core/theme/{light,dark}_theme.dart — both are
   dead code declaring a purple primary that contradicts the brand.
5. Re-point AppColors at VinkolPalette, keeping every public name (decision D-03). @Deprecated
   the members that die: primaryLight, purpleGrey, blue, formWhite.

Verify with flutter analyze and report the real output. Do not touch feature screens.
```

---

## WP2 — Market layer

```
Build lib/core/market/ — the configurable market layer for the Canada expansion.

Read first: .claude/design/03-globalization-gaps.md, .claude/design/08-backend-gaps.md
(the Canada spec), .claude/design/05-decisions.md D-09, and prototype/public/js/market.js —
that file is the working reference implementation.

A Market decides: currency symbol, position and decimals; whether tax is displayed and its
label; the administrative region label; address fields and their order; postal code presence
and format; dial code and phone format; payment providers; support contact and hours;
available languages.

Three things that will break a naive implementation:
1. TAX IS A PROVINCE PROPERTY, NOT A COUNTRY ONE. Ontario HST 13%, Alberta GST 5%, Quebec
   GST+QST 14.975%. The label is not always a single tax.
2. ADDRESS IS NOT A FIXED STRUCT. Nigeria has 3 fields and no postal code; Canada has 4 and
   cannot deliver without one. Store an ordered, market-defined field set.
3. Nigeria must render EXACTLY what the API returns today: delivery fee, no tax line.

Do:
1. Market and Region models, a MARKETS map for NG and CA, exposed through a Riverpod provider
   resolved once at startup.
2. Rewrite AmountTextFormatter and CurrencyFormatter in lib/core/extensions/ to be market-aware.
   They hardcode ₦ and en_US today and nearly all money in the app flows through them — this is
   the highest-leverage change.
3. Route the 25 remaining ₦ literals through the formatter.
4. Move the Nigerian state lists out of state_boundaries.dart and data_utils.dart into market
   config as "administrative regions".

No screen may branch on country. If a screen needs to know where it is, the market is missing a
field — add the field. Verify with flutter analyze and report the real output.
```

---

## WP3 — Localization

```
Add localization infrastructure to the Vinkol app and prepare for French.

Read first: .claude/design/03-globalization-gaps.md and .claude/design/08-backend-gaps.md.

Context: Quebec's Charter of the French Language makes French a legal requirement for
consumer-facing commercial content, not a nicety. The app has ZERO localization infrastructure
today — every user-facing string is a Dart literal.

Do:
1. Add flutter_localizations and set up ARB files (en, fr).
2. Extract user-facing strings to ARB, starting with the flows a Canadian user hits first:
   onboarding, auth, home, booking, checkout.
3. Wire locale selection to the market layer from WP2.
4. Audit for layout that breaks under longer text: French runs roughly 40% longer than English.
   Fixed-width money columns, single-line labels with no overflow decision, and buttons that
   cannot wrap to two lines are all failures.
5. Replace EdgeInsets.only(left:/right:) with EdgeInsetsDirectional start/end throughout.

Report how many strings were extracted and how many remain. Verify with flutter analyze.
```

---

## WP4 — Core components

```
Build the Vinkol component library against the design tokens.

Read first: load the vinkol-design-system skill, then .claude/design/04-tokens.md and
.claude/design/09-prototype.md. Run the prototype (cd prototype && npm start) and study
http://localhost:3000/app — the CSS in prototype/public/app/css/app.css is the spec.

Build, as widgets in lib/widgets/:
1. The Pod — floating 5-tab pill nav (Home, Shop, Records, Wallet, Profile). The active tab
   expands into a pill inside the pill and reveals its label. Stays dark in light mode.
2. The saturated hero card — one per screen, always the live thing. Gradient accent, optional
   badge, route row, foot row with rider and call action.
3. Status chip — label + shape + colour, from the closed set of six: pending, with rider,
   with shopper, delivered, cancelled, unattended. Each has a distinct SHAPE, so it survives
   greyscale.
4. The Line — vertical stops rail (circle → dotted path → diamond terminus) and its horizontal
   sibling, the progress track.
5. Row and record card, with money right-aligned on a shared tabular axis.
6. Form field with label above, error in words tied to the field, and the segmented control.
7. Two-column data grid, event timeline row, quick-action tile, chip row.

Every component needs default, pressed, disabled and dark/light. Keep the AppButton, AppText
and Gap public APIs intact (D-03). Verify with flutter analyze and report the real output.
```

---

## WP5 — Shell and edge states

```
Rebuild the app shell and the states that are missing today.

Read first: load the vinkol-design-system skill, then .claude/design/09-prototype.md.
Compare against http://localhost:3000/app (cd prototype && npm start).

Do:
1. Rebuild dashboard_screen.dart around the Pod from WP4 — five tabs, matching the prototype.
   Delete lib/widgets/bottom_nav_bar.dart, an orphaned second nav bar with different tabs.
2. Rework the app bars in lib/widgets/app_bar/ to the prototype's back-plus-centred-title and
   large-title forms.
3. Replace lib/widgets/empty_content.dart. Today it is one generic 120px tinted circle used
   everywhere with no action. Every empty state needs its own copy AND an action.
4. Build skeleton loaders for list screens — a skeleton beats a spinner wherever the layout is
   known.
5. Build error state with a stated cause and a retry, and an offline state.
6. Rework the dialogs in lib/widgets/modal/ to the token system.

Verify with flutter analyze and report the real output.
```

---

## WP6 — Onboarding and auth

```
Rebuild onboarding and authentication to the approved prototype.

Read first: load the vinkol-design-system skill, then .claude/design/09-prototype.md.
Run the prototype and walk /app/splash → ob-send → ob-track → ob-trust → market-select →
auth-choice → signup → enter-otp, plus /app/login and the reset flow.

Screens: splash, three onboarding panels, market-select (NEW — country and region picker,
needs WP2), auth-choice, login, signup, enter-otp, reset-request, set-password, reset-done.

Notes:
- The onboarding art is drawn SVG using the route Line. No stock illustration, no 3D objects.
- market-select is new. It sets currency, tax treatment, region label, address fields, phone
  format and support contact. Reachable again from Settings → Country.
- The form archetype is one solution for all of these: label above field, error stated in
  words and tied to the field, one bottom-anchored primary action.
- Endpoints that exist: users/login, register, verify-email, resend-otp, forgot-password,
  reset-password. Nothing else — no social login, no biometric signup.
- Guest mode already exists in utils/guest_mode_utils.dart; keep "Continue as guest".

Verify with flutter analyze and report the real output.
```

---

## WP7 — Home and the single booking flow

```
Rebuild the home screen and the single-delivery booking flow.

Read first: load the vinkol-design-system skill, then .claude/design/09-prototype.md.
Walk /app/home → location-search → map-pick / address-form → package-info → quote → payment
→ booked.

The home structure is the app's OWN, evolved rather than replaced:
map with current location → address strip overlaid on the map → "set your stops" → saved-place
tags (Home/Office/Gym) → delivery-type selector → open order → rewards.
Keep maps_display.dart's behaviour: fetch location, reverse-geocode, show the address in a card
over the map.

Order of work:
1. FIRST, in its own commit: decompose map_with_quote_screen.dart (1145 lines) into widgets.
   Do not restyle in the same diff.
2. Then rebuild the screens against the tokens.

Notes:
- The delivery-type selector offers One drop-off / Multi-drop / Batch. Multi-drop and Batch are
  WP8; wire the entry points now.
- address-form is NEW and renders the market's address fields in the market's order (WP2).
- No tax line for Nigeria. No package protection, no declared value — neither exists in
  CreateOrderRequest.
- After payment the order is `pending`, not "finding a rider". There is no live matching feed.

IMPORTANT: the prototype's map is drawn SVG, not Google Maps. Verify early that the hairline
chrome and the address overlay still read against real map tiles with real label density —
this is the biggest untested risk in the redesign.

Verify with flutter analyze and report the real output.
```

---

## WP8 — Multi-drop and batch

```
Rebuild the two multi-stop booking flows.

Read first: load the vinkol-design-system skill, then .claude/design/09-prototype.md.
Walk /app/stops-multidrop → quote-multidrop and /app/stops-batch → quote-batch.

The API supports three products; its names describe the payload, not the job, which is why the
flow has never been discoverable:

  One drop-off   orderType "Delivery"   1 pickup → 1 drop-off
  Multi-drop     orderType "Bulk"       1 pickup → N drop-offs, chained into ONE route
                                        (route[] legs, stops, totalDistance), ONE rider
  Batch          orderType "Multi"      N independent deliveries, each its own pickup and
                                        drop-off, own colour, own rider

The distinction that matters to a user: multi-drop is one trip where the ORDER of stops changes
the price; batch is several trips booked together. So multi-drop gets a numbered, reorderable
list and batch gets colour-coded cards per delivery, using the existing _orderColors hues.

The type is also DERIVED: adding a second drop-off means multi-drop, adding a second pickup
means batch. Each editor offers to switch to the other.

Order of work:
1. FIRST, in its own commit: the three *_map_with_quote screens are 2,401 lines of largely
   duplicated logic. Consolidate them. This is the single largest cleanup in the app.
2. Then rebuild against the tokens.

Endpoints: orders/get-bulk-quote, orders/create-bulk-order, orders/multi-order-quote,
orders/create-multi-order. BulkDropoffItem and MultiOrderRequestItem each carry their own
packageName, recipientName and recipientPhone — the UI must collect those per stop.

Verify with flutter analyze and report the real output.
```

---

## WP9 — Shop

```
Rebuild the store/shopping section.

Read first: load the vinkol-design-system skill, then .claude/design/09-prototype.md.
Walk /app/shop → stores → store → product → cart.

Browse order follows the app: TagsScreen (categories) → StoresScreen → ProductListScreen →
ProductDetailScreen → CartScreen. orderType is "Shopping", not "Delivery".

What makes shopping different from booking, and must stay visible:
- The delivery fee is QUOTED (orders/shopping-delivery-fee), not calculated, and there are two
  options: Vinkol rider (internal) or partner courier (Chowdeck, via externalDeliveryFeeId).
- Pickup is the store's address, not one the user chooses.
- One store per cart. State it up front — it is the rule users hit hardest.
- Payment providers come from the market layer (WP2): Paystack in Nigeria, card and Interac in
  Canada. Paystack has no Canadian presence.

Do NOT add: store ratings or star scores, distance, or prep-time estimates — StoreModel has
none of those fields. Only isClosed / isOpenToday() exists, so Open/Closed is real. No product
stock status. Product and store imagery is a placeholder block; there is no asset library.

Order of work: decompose product_list_screen.dart (1211) and cart_screen.dart (1119) first, in
their own commit. Then restyle.

Verify with flutter analyze and report the real output.
```

---

## WP10 — Records and order detail

```
Rebuild delivery records and the two order-detail screens.

Read first: load the vinkol-design-system skill, then .claude/design/09-prototype.md.
Walk /app/records, /app/records-store, /app/detail, /app/store-order.

delivery_screen.dart is a 2-tab TabController — fetchPackageDeliveries() and
fetchStoreDeliveries(). Both tabs matter; store orders are a second order type with their own
lifecycle.

STATUSES ARE A CLOSED SET, from the switch in delivery_item.dart:
pending · with rider · with shopper · delivered · cancelled · unattended
There is no "finding a rider", "preparing", "at pickup" or "refunded". Render each as label +
shape + colour so it survives greyscale (D-05).

Notes:
- Density is the feature: 6–8 rows on a standard phone. Money right-aligned, tabular, on a
  shared axis. Resist making each row a card.
- The live order is promoted to the saturated hero card at the top of the list.
- Order detail shows the two-column data grid, the horizontal progress track, the rider (name,
  vehicle, rating, CALL only — there is no chat endpoint), status history, and payment.
- No tax line for Nigeria. No package protection, no declared value, no verified badge, no
  lifetime trip count — none of those fields exist.
- Tracking ID is real and copyable. Live rider tracking is NOT — no location endpoint exists.

Order of work: decompose booking_order_screen.dart (1278) and store_order_screen.dart (1106)
first, in their own commit. Then restyle.

Verify with flutter analyze and report the real output.
```

---

## WP11 — Wallet

```
Rebuild the wallet section.

Read first: load the vinkol-design-system skill, then .claude/design/09-prototype.md.
Walk /app/wallet → fund → withdraw → transaction.

Keep the app's existing structure: balance, then a Payments / Withdrawals tab split.

Notes:
- The balance is the one large number on the screen (num.xl, tabular). Every amount lands on a
  shared right-hand optical axis — switch market in the prototype and the column stays aligned.
- Top-up providers come from the market layer (WP2), not a hardcoded list.
- Bank account management is real: banks/list, banks/validate, banks/create-user-bank,
  banks/user-bank.
- Do NOT add saved cards or a payment-methods screen. Paystack collects card details in its own
  webview; there is no stored-card endpoint.
- Do NOT add a "this month" spend summary. There is no aggregate endpoint, only the raw
  payments list.
- Payment statuses that are real: success, successful, paid, completed.

Order of work: decompose wallet_screen.dart (645) first. Delete wallet_screen_backup.dart (668
lines of dead code). Verify with flutter analyze and report the real output.
```

---

## WP12 — Profile and settings

```
Rebuild profile and settings.

Read first: load the vinkol-design-system skill, then .claude/design/09-prototype.md.
Walk /app/profile → personal-info / security / settings / notifications / support.

The menu structure is the app's own: Personal Info · Security · Settings · Support & Help ·
Log Out, with Settings holding Notification · Language · Delete Account.

Add, because the market layer needs them (WP2):
- Settings → Country, opening the market-select screen.
- Personal info uses the market's region label (State vs Province), dial code and phone format.
- Support shows the market's number and hours.
- Language reflects the market's available languages — English only in Nigeria, English and
  Français in Canada.

Do NOT add: saved-address CRUD, payment methods, two-factor auth, Face ID, device lists, a
notifications inbox, profile stats or a user rating. None has an endpoint. Notifications are
FCM push only and are not stored, so there is one honest toggle and a line saying so.
Transaction PIN stays — transaction_pin_modal.dart exists today, though confirm with the
backend whether a PIN endpoint exists.

Verify with flutter analyze and report the real output.
```

---

## WP13 — Rewards

```
Build the rewards screen and rework the home reward card.

Read first: load the vinkol-design-system skill, then .claude/design/09-prototype.md.
Compare /app/home (the card) and /app/rewards (both states).

Today this is promotion_banner.dart, with two states driven by UserModel.hasCoupon and
UserModel.ordersSincePromo: progress toward 3 bookings, and 20% off unlocked.

The redesign keeps the mechanic and drops the execution. The existing unlocked banner is
🎉 + "Congratulations!" + "Use it now! 🚀" on Tailwind emerald #10B981 — emoji as UI,
exclamation-heavy copy, and a colour that is not in the Vinkol palette.

The new treatment draws the reward AS A ROUTE: each booking is a stop, the reward is the
destination rendered as the Line's diamond terminus. Discrete stops beat a percentage bar
because the goal is a COUNT — three bookings you can see yourself completing.

Home keeps the progress state as a bordered card: home already has one saturated object and it
belongs to the open order. On the rewards screen the earned reward DOES take the saturated
treatment, because there it is the subject.

Only hasCoupon and ordersSincePromo exist — no reward history, no lifetime savings total.
Store orders count toward the three.

Verify with flutter analyze and report the real output.
```

---

## WP14 — Cleanup

```
Delete dead code and decompose the remaining god screens in the Vinkol app.

Delete outright (1,293+ lines of dead code):
- lib/features/wallet/view/screen/wallet_screen_backup.dart (668)
- lib/features/delivery/view/screen/test.dart (625)
- lib/utils/phone_number_validation_example.dart
- lib/widgets/bottom_nav_bar.dart (orphaned second nav bar, superseded by the Pod)
- lib/core/theme/light_theme.dart and dark_theme.dart (unreferenced; both declare
  ColorScheme.dark with a purple primary contradicting the brand)

Also fix:
- lib/features/auth/view/screen/ and view/screens/ are two directories for one thing.
- payment_veification_screen.dart is misspelled.
- SupportAndHelpScreen.dart does not follow the snake_case convention.

Then verify no remaining file in lib/features exceeds ~400 lines; decompose any that do, in
their own commits, without restyling.

Verify with flutter analyze and report the real output before and after.
```
