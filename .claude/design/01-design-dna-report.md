# Vinkol Existing Design DNA

Phase 0 output. Every number here was measured from `lib/` at commit `4447728`, not estimated.
Re-run the measurement commands at the bottom before trusting these figures after major work.

## Brand DNA — what makes Vinkol recognizable today

Vinkol is a **blue-and-black** product. A single saturated blue (`#0E74D8`) carries every
primary action, and a **black floating pill** anchors the bottom of every authenticated screen.
Content sits on a light grey canvas in white blocks. Type is Montserrat throughout, heavy at
the top of the hierarchy. Flows end in a full-width 60pt button pinned near the bottom.

That is the whole of the recognizable identity. It is thin, but it is real, and two parts of it
(the blue, the black pod) are genuinely distinctive against Uber/DoorDash-style competitors.

## Color DNA

Declared palette — [lib/core/utils/colors.dart](lib/core/utils/colors.dart):

| Token          | Value      | Reality                                                     |
|----------------|------------|-------------------------------------------------------------|
| `primary`      | `#0E74D8`  | The brand. 4.66:1 on white — passes AA for body text, barely |
| `primaryLight` | `#8068FF`  | Purple. Unrelated to the blue. Palette contamination         |
| `purpleGrey`   | `#CECAE5`  | Purple again                                                 |
| `blue`         | `#0E6CF8`  | A second, near-identical blue. Should not exist              |
| `black`        | `#000000`  | Pure black — used as a surface, not just as text             |
| `white`        | `#FFFFFF`  |                                                              |
| `darkgrey`     | `#6D6969`  | Warm grey, 5.42:1                                            |
| `greyLight`    | `#303030`  | Misnamed — this is a dark grey                               |
| `lightgrey`    | `#D9D9D9`  | 1.41:1 — unusable for text, used as a button fill            |
| `green`        | `#37981E`  |                                                              |
| `red`          | `#E54335`  | 4.05:1 — fails AA for body text                              |
| `formFillColor`/`formWhite` | `#EEEEEE` | Two names, one value                                |

**The actual palette in use is far larger and mostly undeclared.** Measured across `lib/`:

- `Colors.grey` × 370, `Colors.white` × 285, `Colors.black` × 217, `Colors.red` × 109,
  `Colors.green` × 55, `Colors.blue` × 55, `Colors.orange` × 33 — raw Material colors, not tokens.
- ~40 distinct raw hex literals, led by `#6366F1` × 11, `#10B981` × 4, `#8B5CF6` × 2,
  `#6C63FF` × 3. These are **Tailwind/Material-default indigo, emerald and violet** — a
  different product's palette living inside Vinkol's. This is the single strongest
  "AI-generated" signal in the codebase and the first thing to remove.
- `withOpacity` × 250 — tints invented at the call site instead of drawn from a ramp.

**Dark mode does not exist.** [dark_theme.dart](lib/core/theme/dark_theme.dart) and
[light_theme.dart](lib/core/theme/light_theme.dart) both declare `ColorScheme.dark`, both
declare a *purple* primary (`#684DFA`) that contradicts `AppColors.primary`, and **neither is
referenced anywhere** — [main.dart](lib/main.dart#L57) builds `ThemeData.light().copyWith(...)`
inline instead. `Theme.of(context)` appears 5 times in 202 files.

## Typography DNA

Montserrat via `google_fonts`, one family, weights 300–800.
[textstyles.dart](lib/core/utils/textstyles.dart) defines nine styles; the `AppText.*` wrapper
in [text.dart](lib/core/utils/text.dart) exposes them as semantic constructors — `AppText.h1`,
`.h3`, `.body`, `.caption`, `.button`. **The semantic API is good and worth keeping.** The
scale behind it is not:

- `h5` and `h6` are identical (16 / w500). One of them is dead.
- Sizes run 24, 22, 20, 18, 16, 16, 16, 16, 14 — four styles collide at 16pt, so there is no
  usable mid-hierarchy step.
- The doc comments lie: `.caption` is documented as 10pt/w300 and is actually 14pt/w300;
  `.h1` is documented 24/800 and is 24/800 (correct), `.h2` documented 24 but is 22.
- **No line height and no letter spacing are set anywhere.** Every style inherits Flutter's
  default leading. Montserrat is a wide geometric face and needs explicit leading control.
- **No numeric style and no tabular figures.** Money, ETAs, distances and tracking codes all
  render in proportional Montserrat, so columns of numbers do not align and digits jitter as
  values update. For a logistics product this is the most expensive typographic gap.
- `.sp` (ScreenUtil scaled points) appears 346 times, so text scales with *device width* and
  ignores the user's OS text-size setting entirely. Accessibility failure.

## Shape DNA

`BorderRadius.circular` values in use: **12 (88×), 16 (74×), 10 (31×), 8 (30×), 20 (30×)**,
plus 2, 4, 5, 6, 18, 25, 50. There is no radius language — the value is chosen per call site.
`AppButton` hardcodes 16. The bottom nav pod uses 25. The orphaned nav bar uses 30.

`BoxShadow` appears in 29 files with hand-written offsets and opacities. No elevation scale.

Spacing comes from [gap.dart](lib/widgets/gap.dart): a static ladder from `s2` to `s32` in 2pt
steps. A 2pt grid is not a grid — it permits every value, so nothing is enforced.

## Component DNA

- **[AppButton](lib/widgets/app_button.dart)** — named constructors (`.primary`, `.black`,
  `.white`, `.grey`, `.outline`), fixed 60pt height, radius 16, loading and disabled states
  built in. The best component in the codebase. Note the bug: `onPressed` is set to an empty
  closure rather than `null` when disabled, so the button stays focusable and gives no
  platform disabled affordance.
- **[AppText](lib/core/utils/text.dart)** — semantic constructors, good API, weak scale.
- **[Gap](lib/widgets/gap.dart)** — terse spacing API, too permissive a scale.
- **The black pod** — [dashboard_screen.dart](lib/features/dashboard/view/screen/dashboard_screen.dart#L57-L83),
  a 5-tab black pill floating over the content. Distinctive. Keep and evolve.
- **[EmptyContent](lib/widgets/empty_content.dart)** — one generic empty state: a 120pt circle
  of 10%-tint primary wrapping an 80pt Material icon, with a blue caption. Every empty screen
  in the app looks identical and none of them offer an action. Textbook generic empty state.
- **Duplicate/dead components**: [widgets/bottom_nav_bar.dart](lib/widgets/bottom_nav_bar.dart)
  is a second nav bar with entirely different tabs (Documents/History/Wallet/Chat/Profile),
  unused. Also dead: `wallet_screen_backup.dart`, `delivery/view/screen/test.dart`,
  `phone_number_validation_example.dart`, and a split `auth/view/screen` vs `auth/view/screens`.

## Interaction DNA

Riverpod + a `NavigationService` with named routes. `flutter_animate` is a dependency; motion
is sparse and undefined. Bottom sheets via `sliding_sheet2`. Feedback via `another_flushbar`
([app_flushbar.dart](lib/widgets/app_flushbar.dart)). Maps are `google_maps_flutter` with
overlay cards — [map_with_quote_screen.dart](lib/features/booking/view/screen/map_with_quote_screen.dart)
is **1145 lines**, a god screen mixing map, quoting, pricing and checkout.

Status is communicated by color alone. `_getStatusColor()` in
[withdrawal_item.dart](lib/features/wallet/view/widget/withdrawal_item.dart#L16) is local to
that widget; [delivery_item.dart](lib/features/delivery/model/delivery_item.dart#L31) has its
own copy. No shared status vocabulary.

Iconography mixes Material `Icons.*`, `CupertinoIcons.*` (in the orphaned nav bar), and SVG
assets. `Icons.fire_truck` represents Delivery in the tab bar — a fire engine.

## Personality, derived

> Practical · direct · high-contrast · blue-forward · improvised · locally rooted

"Improvised" is the honest word and the one the redesign has to answer. Nothing here is
tasteless; almost nothing is *decided*. The product reads as built quickly by capable engineers
without a design system, which is exactly what it is.

## Classification

**KEEP** — brand blue `#0E74D8`; the black floating pod; Montserrat as the brand voice; the
`AppText`/`Gap`/`AppButton` semantic API surface (202 files depend on it); full-width bottom
primary action; map-first booking.

**EVOLVE** — the type scale (add leading, tracking, numerics, resolve the 16pt pile-up);
spacing (2pt ladder → 4pt scale); radius (13 ad-hoc values → 4 named steps); elevation (29
hand-rolled shadows → 4 levels, mostly borders); the empty state (one generic → per-context
with an action); the pod (nav only → nav + live-delivery status).

**REMOVE** — every raw hex literal and bare `Colors.*` in feature code; the purple family
(`primaryLight`, `purpleGrey`, the theme files' `#684DFA`); the duplicate blue; the two
identical form-fill tokens; the orphaned second nav bar; the dead screens; `.sp` for text.

**INTRODUCE** — a real theme layer wired into `MaterialApp` with dark mode; semantic status
tokens; tabular numerics; a market/locale layer; skeleton loaders; error, offline and
permission states; a motion scale; focus states; a tracking timeline component.

## Reproducing these measurements

```bash
grep -rhoE "0x[fF][fF][0-9a-fA-F]{6}" lib | sort | uniq -c | sort -rn      # raw hex literals
grep -rhoE "Colors\.[a-zA-Z]+" lib | sort | uniq -c | sort -rn             # bare Material colors
grep -rhoE "BorderRadius.circular\([0-9.]+" lib | grep -oE "[0-9.]+" | sort -n | uniq -c
grep -rho "withOpacity" lib | wc -l
grep -rho "\.sp\b" lib | wc -l
grep -rho "₦" lib | wc -l
```
