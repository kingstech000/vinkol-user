# The market layer — what is real

The specification for the Canada expansion, and the record of what the backend does and does not
support.

Audited against `lib/core/constants/api_routes.dart` (the complete endpoint list),
`delivery_model.dart`, `store_model.dart`, `user_model.dart` and `booking_service.dart`, against
the backend's frontend migration guide, and against live staging responses captured on
7 Sep 2026. The last table lists product inventions that stay out.

> **Revised 7 Sep 2026. This document is now the source of truth for the market layer.**
>
> The prototype, and the market-layer decisions taken from it, are **abandoned**. Where this
> document and any other design doc disagree, this one wins; where it and the prototype
> disagree, the prototype is simply out of date and should not be consulted.
>
> Three things this document itself asserted are now wrong and are corrected below: **tax is
> real** (it was listed as an invention), **Canada is Stripe-only** (not Wallet · Card ·
> Interac), and **the client cannot choose its market** (so `market-select` is not a screen we
> can build).
>
> Settled by this revision: Canadian dollars are written **`C$`**, matching the backend and the
> emailed receipt. The prototype's `CA$` is void.

## Supported — kept

| Feature | Evidence |
|---|---|
| Login, signup, email OTP, resend, forgot/reset password | `users/login`, `register`, `verify-email`, `resend-otp`, `forgot-password`, `reset-password` |
| Profile read + update (name, email, phone, state) | `users/profile`, `users/update-profile` |
| Single delivery, quote | `orders/create-new`, `orders/get-quote` |
| **Quote-then-order** — a server-issued `quoteId` prices the order | All six creation endpoints accept `quoteId` in place of `deliveryFee`. Single-use, 15 min, `expiresAt` on the response |
| **Itemised bill** — fare, processing fee, tax, `grandTotal` | Returned by `get-quote`, `get-bulk-quote`, `multi-order-quote`, `shopping-delivery-fee` |
| **Market on every record** — `country` and `currency` | On order, payment, wallet, withdrawal, store and product records |
| Withdrawable amount, net of disputed **and pending** | `users/{id}/withdrawable-amount` |
| **Multi-drop** (1 pickup → N drop-offs, one route) | `orders/get-bulk-quote`, `orders/create-bulk-order` |
| **Batch** (N independent deliveries) | `orders/multi-order-quote`, `orders/create-multi-order` |
| Partner courier pricing | `orders/get-cd-quote` (Chowdeck), `deliveryProvider`, `externalDeliveryFeeId` |
| Store browse: categories, stores, products | `stores/tags`, `stores`, `products` |
| Store order + its delivery fee | `orders/store-order-new`, `orders/shopping-delivery-fee` |
| Store open/closed | `StoreModel.isClosed`, `OpeningHours.isOpenToday()` |
| Order history, order detail, tracking ID | `orders/user-orders`, `orders/{id}` |
| Rider name, phone, photo on an order | `AgentModel` from `json['rider']` |
| Rider average rating, submit rating | `ratings/rider-average`, `ratings/rider` |
| Wallet balance, payments, fund, withdraw, history | `users/wallet-balance`, `users/payments`, `payments/fund-wallet`, `users/withdraw`, `users/withdrawal-history` |
| Bank account management | `banks/list`, `banks/validate`, `banks/create-user-bank`, `banks/user-bank` |
| Reward progress + unlocked coupon | `UserModel.hasCoupon`, `UserModel.ordersSincePromo` |
| Report download | `orders/report/download` |
| Guest mode | `guest_mode_utils.dart` |

**Order statuses are a fixed set** — `delivery_item.dart` switches on exactly:
`pending` · `with rider` · `with shopper` · `delivered` · `cancelled` · `unattended`.
The prototype now uses only these.

## The market layer — the Canada expansion

**This is the deliverable.** Most of it now exists server-side; the rows marked *to build* do not.

**The server decides the market**, by reverse-geocoding the pickup coordinates. Tax jurisdiction
follows where the service is performed, so a client cannot select its own country or currency —
it reads them off the quote. This is the single most important correction to the original plan.

| Decided by the market | Nigeria | Canada | State |
|---|---|---|---|
| Currency, symbol, decimals | `₦`, 0 dp | `CA$`, 2 dp — **see the symbol conflict below** | shipped |
| Whether tax is displayed | no separate line — both are `0` | required, itemised | shipped |
| Payment providers | Wallet · Paystack | **Stripe only** | shipped |
| Customer wallet | yes | **none at all** | shipped |
| Refund destination | wallet, immediate | card via Stripe, 5–10 business days | shipped |
| Administrative region | State | Province | to build |
| Address fields, in order | Street · Area · State | Street · City · Province · **Postal code** | to build |
| Postal code | not used in practice | required, `A1A 1A1` | to build |
| Languages | English | English · **Français** | to build |
| Support and hours | +234 700 846 6556 · 8am–8pm daily | +1 647 946 0011 · 8am–8pm ET | to build |

### The symbol conflict — needs a decision

The prototype renders Canadian dollars as `CA$` (`prototype/public/js/market.js`). The backend's
migration guide writes them as `C$21.26`, which is what the Flutter market layer currently uses.
Both are valid; they must not disagree, or the app and the emailed receipt will differ. **`CA$`
if the prototype wins as usual; `C$` if matching the receipt matters more.**

### The three that will break a naive implementation

**1. Tax is set by PROVINCE, not by country — and the server now resolves it.** One rate per
market is wrong in Canada. The quote returns `taxAmount`, `taxRate` and `taxLabel` already
resolved from the delivery's province, so the client renders the label it is given and never
computes a rate. The table below is reference only:

| Province | Label | Rate | ₦10,000-equivalent delivery becomes |
|---|---|---|---|
| Ontario | HST | 13% | CA$11.00 → CA$12.43 |
| British Columbia | GST + PST | 12% | CA$12.32 |
| Alberta | GST | 5% | CA$11.55 |
| Quebec | GST + QST | 14.975% | CA$12.65 |
| Nova Scotia | HST | 15% | CA$12.65 |

The label is not always one tax ("GST + QST"), which is why it is a string from the server and
not something the client derives from the country. In Nigeria `taxRate` is `0` and `taxLabel` is
an empty string — render no tax row at all rather than a blank one.

**2. Address is not a fixed struct.** Nigeria has three fields and no postal code; Canada has
four and cannot deliver without one. Store addresses as an ordered, market-defined field set —
a `state` column will not survive the next market.

**3. French is a legal requirement, not a nicety.** Quebec's Charter of the French Language
applies to consumer-facing commercial content. Every user-facing string needs to be
translatable before Quebec launch — the app currently has **zero** localization
infrastructure and every string is a Dart literal.

### Also required

- **A region (province) on the address**, for the market's field set. The *country* is not ours
  to set — the server derives it from the pickup coordinates.
- Per-market pricing — the fixtures convert NGN for illustration; real markets price natively.
- Market-scoped support contacts and legal copy.

22 of 44 screens change when market or region changes. One screen is added: `address-form`
(renders the market's fields in its order).

**`market-select` is cancelled.** A country + region picker cannot exist: the server decides the
country from where the pickup is, and a client that disagreed would simply be overruled. Market
is an *output* of the quote, not an input to it. Anywhere the prototype offers a market choice is
showing something the API will not honour.

## Not supported — removed

*(product inventions, unrelated to the expansion — these stay out)*

> Two rows left this table on 7 Sep 2026. **VAT / tax line** was never an invention — it had
> simply not shipped when this was written, and the quote now itemises it. **Country / market
> selection** stays out, but for a stronger reason than "unbuilt": see below.

| Removed | Why |
|---|---|
| **Live tracking screen** (rider moving on a map, live ETA, distance remaining) | No rider-location endpoint, no socket, no polling. The API exposes order `status` and a tracking ID only. **The single biggest gap.** |
| Message / chat the rider | No chat endpoint. `AgentModel.phone` supports calling only. |
| Package protection / insurance | No field on any order model, no endpoint, no premium line |
| Declared package value | No field in the create-order payload |
| Saved-address management | No addresses endpoint. `LocationTags` (Home/Office/Gym) is a hardcoded widget |
| Saved cards / payment-methods screen | No endpoint; Paystack collects card details in its own webview |
| Notifications inbox | `NotificationService` is FCM push only — there is no stored notification list |
| Two-factor auth, Face ID, device list | No endpoints |
| Country / market selection in-app | **Not deferred — impossible.** The server derives the market from the pickup coordinates; a client picker would be overruled |
| Dark-mode toggle in Settings | No theme layer; the row is commented out in `settings_screen.dart` |
| Store ratings and star scores | `StoreModel` has no rating field. Only **rider** ratings exist |
| Store distance and prep-time estimates | No distance or ETA field on `StoreModel` |
| Rider "verified" badge, lifetime trip count | Neither field exists on `AgentModel` |
| Product stock status | No stock field on `Product` |
| Profile stats (deliveries, your rating, streak) | No aggregate endpoint; users have no rating |
| Wallet "this month" summary | No aggregate endpoint — only the raw payments list |
| Reward history and lifetime savings | Only `hasCoupon` and `ordersSincePromo` exist |
| Multi-drop savings claim | Invented pricing; no bulk discount rule is known |
| Live-chat support | No chat backend. Phone and email only |

## The prototype is abandoned

`prototype/` and the market-layer decisions taken from it are no longer authoritative and should
not be used as a specification. It was built before the backend contract existed and contradicts
it in seven places — Interac as a Canadian option, a Canadian wallet, a market picker, no quote
expiry, wallet-only refund copy, `CA$`, and tax computed on the client from a hardcoded rate
table rather than read from the quote.

That last one is the reason not to keep it around as a reference: a client that computes its own
tax drifts from what is actually charged the first time a province changes a rate, and the drift
is invisible until a customer disputes a receipt.

**Where the market layer is concerned, this document is the specification.** The implemented
behaviour lives in `lib/core/money/money.dart` and is covered by `test/core/`.

## If you want them back

Ranked by product value:

1. **Live tracking** — needs a rider-location endpoint (or socket) plus an ETA service. Everything
   else on that screen already exists.
2. **Package protection** — a commercial decision before a technical one; needs a premium on the
   quote and a claims flow.
3. **Saved addresses** — a small CRUD endpoint; the UI pattern already exists as `LocationTags`.
4. **Rider chat** — the highest-effort, and calling already covers the urgent case.
