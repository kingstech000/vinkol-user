# Prototype vs Backend — what is real

Audited against `lib/core/constants/api_routes.dart` (the complete endpoint list),
`delivery_model.dart`, `store_model.dart`, `user_model.dart` and `booking_service.dart`.
Anything in the second table was removed from the prototype on 3 Sep 2026.

## Supported — kept

| Feature | Evidence |
|---|---|
| Login, signup, email OTP, resend, forgot/reset password | `users/login`, `register`, `verify-email`, `resend-otp`, `forgot-password`, `reset-password` |
| Profile read + update (name, email, phone, state) | `users/profile`, `users/update-profile` |
| Single delivery, quote | `orders/create-new`, `orders/get-quote` |
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

## The market layer — the Canada expansion. Backend to build.

**This is the deliverable, not a feature to justify against today's backend.** Everything below
stays in the prototype and is specified for the server team.

| Decided by the market | Nigeria | Canada |
|---|---|---|
| Currency, symbol, decimals | `₦`, 0 dp | `CA$`, 2 dp |
| Whether tax is displayed | no separate line — matches the API today | required |
| Administrative region | State | Province |
| Address fields, in order | Street · Area · State | Street · City · Province · **Postal code** |
| Postal code | not used in practice | required, `A1A 1A1` |
| Languages | English | English · **Français** |
| Payment providers | Wallet · Paystack | Wallet · Card · **Interac** |
| Support and hours | +234 700 846 6556 · 8am–8pm daily | +1 647 946 0011 · 8am–8pm ET |

### The three that will break a naive implementation

**1. Tax is set by PROVINCE, not by country.** One rate per market is wrong in Canada:

| Province | Label | Rate | ₦10,000-equivalent delivery becomes |
|---|---|---|---|
| Ontario | HST | 13% | CA$11.00 → CA$12.43 |
| British Columbia | GST + PST | 12% | CA$12.32 |
| Alberta | GST | 5% | CA$11.55 |
| Quebec | GST + QST | 14.975% | CA$12.65 |
| Nova Scotia | HST | 15% | CA$12.65 |

The quote endpoint must return a tax amount and label resolved from the delivery's province,
and the label is not always one tax ("GST + QST").

**2. Address is not a fixed struct.** Nigeria has three fields and no postal code; Canada has
four and cannot deliver without one. Store addresses as an ordered, market-defined field set —
a `state` column will not survive the next market.

**3. French is a legal requirement, not a nicety.** Quebec's Charter of the French Language
applies to consumer-facing commercial content. Every user-facing string needs to be
translatable before Quebec launch — the app currently has **zero** localization
infrastructure and every string is a Dart literal.

### Also required

- A market and region field on the user, set at signup (`market-select` screen).
- Per-market pricing — the fixtures convert NGN for illustration; real markets price natively.
- Payment provider routing: Paystack has no Canadian presence, Interac has no Nigerian one.
- Market-scoped support contacts and legal copy.

22 of 44 screens change when market or region changes. Screens added: `market-select`
(country + region picker) and `address-form` (renders the market's fields in its order).

## Not supported — removed

*(product inventions, unrelated to the expansion — these stay out)*

| Removed | Why |
|---|---|
| **Live tracking screen** (rider moving on a map, live ETA, distance remaining) | No rider-location endpoint, no socket, no polling. The API exposes order `status` and a tracking ID only. **The single biggest gap.** |
| Message / chat the rider | No chat endpoint. `AgentModel.phone` supports calling only. |
| Package protection / insurance | No field on any order model, no endpoint, no premium line |
| VAT / tax line | `CreateOrderRequest` carries `deliveryFee` only; no tax is quoted or returned |
| Declared package value | No field in the create-order payload |
| Saved-address management | No addresses endpoint. `LocationTags` (Home/Office/Gym) is a hardcoded widget |
| Saved cards / payment-methods screen | No endpoint; Paystack collects card details in its own webview |
| Notifications inbox | `NotificationService` is FCM push only — there is no stored notification list |
| Two-factor auth, Face ID, device list | No endpoints |
| Country / market selection in-app | The market layer is Phase 4 and unbuilt |
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

## If you want them back

Ranked by product value:

1. **Live tracking** — needs a rider-location endpoint (or socket) plus an ETA service. Everything
   else on that screen already exists.
2. **Package protection** — a commercial decision before a technical one; needs a premium on the
   quote and a claims flow.
3. **Saved addresses** — a small CRUD endpoint; the UI pattern already exists as `LocationTags`.
4. **Rider chat** — the highest-effort, and calling already covers the urgent case.
