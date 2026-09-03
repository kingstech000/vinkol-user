# Design Decisions Log

One entry per decision that shapes the system. Open decisions block the phase that depends on
them. Never change a ratified decision silently — supersede it with a new entry.

Status: `OPEN` (needs the user) · `RATIFIED` · `SUPERSEDED BY D-nn`

---

## D-01 — Visual direction (first attempt) · **SUPERSEDED BY D-07**

> **Reopened 3 Sep 2026.** Built and shown, the client's verdict was "generic" — the restraint
> read as flat rather than confident. Three replacement directions were built from client-supplied
> references and are live at `/v2`. See D-07. The register split below survives the review; the
> palette and surface treatment do not.

**Direction A (Quiet Infrastructure), with Direction C's editorial treatment reserved for hero
moments.**

Two registers, one system. The tokens are shared; what differs is which end of the type scale
and which spacing rhythm a screen is allowed to use.

### Operational register — the default, ~95% of screens

Hairline borders and e0 surfaces; shadows are the exception, not the tool. Dense information —
6–8 rows visible on a standard phone. Radii sm (8) and md (12) dominate; lg only on sheets.
Color is restrained: the blue is reserved for action and live state, never decoration. Tabular
numerics everywhere. Type tops out at `h1`.

Applies to: all lists, forms, settings, checkout, cart, wallet history, profile, auth, search,
delivery and store browsing.

### Hero register — a closed list of moments

Adds `display.l`/`display.s` in Montserrat with tight tracking, section rhythm at 32 rather
than 28, and the Line rendered at large scale as a graphic element rather than an indicator.

Applies **only** to: splash, onboarding, live tracking, order-complete and proof of delivery,
receipt, the wallet balance header, and empty states. Nothing else. **The hero register is a
closed list — adding a screen to it is a decision, logged here.**

*Why this split:* Direction A carries the screens where the product actually lives and where
density is a feature; C's editorial register earns its keep on the handful of moments that
form a user's impression. Direction B was rejected: its strengths (map prominence, the pod,
purposeful motion) are already protected by `02-do-not-lose.md` and the signatures, so adopting
B wholesale would buy nothing and risk the "Uber with a different logo" outcome brief §24
explicitly forbids.

*Consequences:* elevation defaults to e0 and a hand-written `BoxShadow` is now a rule
violation, not a preference. Density targets are binding. A screen not on the hero list may not
use `display.*`.

---

## D-02 — Text/UI typeface · **RATIFIED 2026-09-02** · unblocks Phase 2

**Three faces, split by job.**

| Role | Face | Where |
|------|------|-------|
| Display / brand | **Montserrat** (retained) | `display.l`, `display.s`, `h1` — hero register and screen titles |
| Text / UI / numeric | **Inter** | `h2` and below, all body, labels, captions, buttons, and all `num.*` styles |
| Code / identifiers | **IBM Plex Mono** | tracking codes, reference and order IDs only |

All three are confirmed present in `google_fonts` **6.3.3**, the version resolved in
`pubspec.lock` (`GoogleFonts.montserrat`, `GoogleFonts.inter`, `GoogleFonts.ibmPlexMono`).

*Why Montserrat stays where it does:* it is the face users already associate with Vinkol, and
brand identity is perceived at display sizes. It keeps every screen title and every hero moment.

*Why a companion below `h1`:* Montserrat has no tabular figures — money, ETAs and distances
jitter as values update and columns will not align — and it widens and loosens at 13–15pt,
which is where most of a logistics UI lives. It also costs horizontal space the product cannot
spare under +40% translation growth.

*Why Inter specifically:* it is drawn for UI at small sizes, ships verified `tnum` (tabular
figures) plus broad Latin coverage including French, and is variable-weight. Its ubiquity is
the point rather than a problem — the text face's job is to disappear. Distinctiveness comes
from the signatures (the Line, the pod, flush numerics, status typography), not from a novelty
body font; a distinctive body face would fight Montserrat's geometry and hurt legibility at
the sizes that matter.

*Why a mono at all:* tracking codes and order IDs get read aloud, transcribed and compared.
Disambiguated glyphs (0/O, 1/l/I) are a correctness feature, not a style choice. IBM Plex Mono
is warmer and more legible at 13pt than the harder-edged alternatives, and its Plex heritage
sits comfortably beside Inter.

**Verify before shipping:** `FontFeature.tabularFigures()` must be confirmed rendering on
device for Inter through `google_fonts` — the package fetches static instances at runtime and
feature retention is worth proving once rather than assuming. If it does not hold, the fallback
is bundling the Inter variable font as an asset.

---

## D-03 — Migration strategy for `AppText` / `AppColors` · **RATIFIED**

New tokens land in `lib/core/design/`. The existing `AppColors`, `AppText`, `Gap` and
`AppButton` **keep their public names and constructor signatures** and are re-pointed at the
new tokens underneath. Legacy members that must die (`primaryLight`, `purpleGrey`, `blue`,
`formWhite`) are marked `@Deprecated` with a message naming the replacement, and removed in a
single sweep once call sites reach zero.

*Why:* 202 Dart files depend on these APIs. A rename-first migration means one enormous,
unreviewable diff and a frozen product for its duration. Changing what the constructors
*produce* lets the whole app move on the first commit and the cleanup proceed incrementally.

---

## D-04 — `.sp` is banned for text · **RATIFIED**

`.sp` scales type with device *width* and discards the user's OS text-size setting; it appears
346 times. New and touched code uses unscaled sizes and lets `MediaQuery.textScaler` apply.
`.h`/`.w`/`.r` remain acceptable for non-text dimensions where a design-width ratio is genuinely
wanted, but fixed spacing tokens are preferred.

*Why:* an accessibility defect, not a style preference — a user who has enlarged system text
today sees no change in Vinkol.

---

## D-05 — Status is never color alone · **RATIFIED**

Every delivery, payment and verification status renders as a triple: label text + shape +
color, in that priority order (`04-tokens.md` §1). Cancelled is neutral, not red.

*Why:* colorblind users, grayscale screenshots, screen readers, and the fact that a status
system built on ten shades is unreadable to everyone. Also the basis of signature #3.


---

## D-07 — Visual direction · **RATIFIED 2026-09-03** · Direction A, Midnight

Chosen from three studies built at `/v2` after D-01 was rejected as "generic".

**A · Midnight** — dark-first operations. Exactly one saturated blue object per screen, always
the live thing (the open order, the balance, the earned reward). Everything else is quiet
near-black surface with hairline borders. Radii 12 / 18 / 24. Light mode is a full peer, not a
tint. Rejected: B (Daylight — too soft for the operational screens), C (Kinetic — its amber
second accent is a permanent tax, see D-06).

**Why it worked where D-01 failed:** D-01's restraint read as absent rather than confident.
Midnight keeps the restraint everywhere *except* one object per screen, which carries the
weight. The client's references all shared that: a big saturated card carrying the live thing.

**Consequences that override earlier decisions:**
- Dark is the primary register; the earlier "operational / hero register" split from D-01 is
  gone. One register, one saturated object per screen.
- Radius scale is **12 / 18 / 24 / full**, not 4 / 8 / 12 / 20.
- `lib/core/design/` was built for D-01 and is **stale** — see WP1 in `10-build-plan.md`.

---

## D-06 — A second accent · **REJECTED 2026-09-03**

Direction C's amber-for-motion / blue-for-brand split was not chosen. A second accent is a
permanent tax on every future component and weakens the brand blue. Vinkol blue carries live
state on its own.

---

## D-08 — Navigation is a floating pod · **RATIFIED 2026-09-03**

Five tabs (Home · Shop · Records · Wallet · Profile) in a floating pill, matching the app's
existing `dashboard_screen.dart` bar. The active tab **expands into a pill inside the pill**
and reveals its label, so the selected state carries shape as well as colour and survives
greyscale. The pod stays dark in light mode — it is the one constant object across both
themes and the strongest piece of Vinkol's existing identity (`02-do-not-lose.md` #2).

---

## D-09 — The market layer is the deliverable · **RATIFIED 2026-09-03**

The Canada expansion is the reason the project exists, so market-layer work is **specified and
kept even though the backend does not support it yet**. This overrides the removal rule in
D-10: that rule targets invented product features, never the expansion itself.

Three findings the backend must act on (full spec in `08-backend-gaps.md`):

1. **Tax is a PROVINCE property, not a country one.** Ontario HST 13%, Alberta GST 5%, Quebec
   GST+QST 14.975%. One rate per market is wrong, and the label is not always a single tax.
2. **Address is not a fixed struct.** NG has 3 fields and no postal code; CA has 4 and cannot
   deliver without one. Store an ordered, market-defined field set.
3. **French is a legal requirement** under Quebec's Charter of the French Language, and the app
   has zero localization infrastructure today.

---

## D-10 — Only ship what the backend supports · **RATIFIED 2026-09-03**

Invented product features were removed from the prototype: live rider tracking, rider chat,
package insurance, saved cards, saved-address CRUD, notifications inbox, 2FA / Face ID /
device lists, store ratings and distances, rider verified badges and trip counts, profile and
wallet aggregate stats, product stock status.

**Order statuses are a closed set** from `delivery_item.dart`: `pending` · `with rider` ·
`with shopper` · `delivered` · `cancelled` · `unattended`. Nothing else exists.

Does **not** apply to the market layer (see D-09). Full inventory and a ranked
what-to-build-back list in `08-backend-gaps.md`.
