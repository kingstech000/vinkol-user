# Vinkol Design Tokens

The source of truth for Phase 2. Every contrast ratio below was computed, not estimated
(`.claude/scripts/contrast.py` reproduces them). Target implementation: `lib/core/design/`
(`colors.dart`, `typography.dart`, `spacing.dart`, `radius.dart`, `elevation.dart`,
`motion.dart`), surfaced through a `ThemeExtension` so light and dark resolve from context.

**Direction: A · Midnight (D-07).** Dark-first operations. Exactly **one saturated blue
object per screen** — always the live thing (the open order, the wallet balance, the earned
reward). Everything else is quiet near-black surface with hairline borders. Light mode is a
full peer, not a tint.

**Typeface (D-02a):** Geist, everywhere. Geist Mono for tracking codes and reference IDs.
One family; hierarchy comes from size, weight and tracking, never from a second face.

> **Live values live in `prototype/public/app/css/app.css`.** That file is the token source of
> truth until `lib/core/design/` is reworked to match (WP1 in `10-build-plan.md`) — the Dart
> layer was written for D-01 and its radius scale and light-first defaults are **stale**.
> After WP1 the two must change together, in the same commit.

The earlier "operational / hero register" split from D-01 is gone. One register; the saturated
object carries the weight.

---

## 1. Color

### Brand ramp — anchored on the existing `#0E74D8`

| Token | Hex | On white | Use |
|-------|-----|----------|-----|
| `brand.50`  | `#EDF5FE` | — | selected row tint, info banner ground |
| `brand.100` | `#D3E7FD` | — | pressed tint on light surfaces |
| `brand.200` | `#A8CEFA` | — | borders on tinted grounds, disabled brand fill |
| `brand.300` | `#74B0F5` | — | **dark-mode text/icon** — 8.47:1 on dark canvas |
| `brand.400` | `#3B90EC` | — | dark-mode fills — 5.83:1 on dark canvas |
| `brand.500` | `#0E74D8` | 4.66:1 | **the brand.** Primary fills with white text. Never change this value |
| `brand.600` | `#0B5EB4` | 6.41:1 | brand-colored *text* and links on white; pressed state of 500 |
| `brand.700` | `#0A4C92` | 8.53:1 | high-contrast brand text, focus rings |
| `brand.800` | `#0B3D73` | — | dark-mode brand surfaces |
| `brand.900` | `#0C2F56` | — | |
| `brand.950` | `#081E38` | — | |

`brand.500` on the light canvas (`#F4F6F8`) is 4.30:1 — **below AA for body text**. Rule:
brand-colored text on a non-white surface uses `brand.600` or darker.

### Neutral ramp — cool, to sit with the blue

`#FFFFFF` · `50 #F4F6F8` · `100 #E9ECF0` · `200 #DCE0E6` · `300 #C3C9D2` · `400 #99A1AE` ·
`500 #6E7784` · `600 #545C68` · `700 #3D444E` · `800 #272C34` · `900 #171A20` ·
`950 #0D0F13` · `#000000`

On white: `500` 4.53:1 (smallest usable for secondary text) · `600` 6.76:1 · `700` 9.83:1 ·
`900` 17.43:1. On the dark canvas (`950`): `300` 11.51:1 · `400` 7.37:1.

Replaces every `Colors.grey*` in the codebase. The legacy `lightgrey #D9D9D9` (1.41:1) must
never carry text.

### Semantic surfaces

| Token | Light | Dark |
|-------|-------|------|
| `canvas` | `neutral.50` | `neutral.950` |
| `surface` | `#FFFFFF` | `neutral.900` |
| `surface.raised` | `#FFFFFF` | `neutral.800` |
| `surface.sunken` | `neutral.100` | `#000000` |
| `surface.inverse` | `neutral.900` | `#FFFFFF` |
| `border.subtle` | `neutral.200` | `neutral.800` |
| `border.default` | `neutral.300` | `neutral.700` |
| `border.strong` | `neutral.400` | `neutral.600` |
| `text.primary` | `neutral.900` | `neutral.100` |
| `text.secondary` | `neutral.600` | `neutral.400` |
| `text.tertiary` | `neutral.500` | `neutral.500` |
| `text.disabled` | `neutral.400` | `neutral.600` |
| `text.inverse` | `#FFFFFF` | `neutral.900` |

### State colors

Each role has three values: `text` (on white *or* on its own tinted ground), `fill` (with
white text on it), and `ground` (the tinted banner/chip background).

| Role | `text` | on white | on own ground | `fill` | white on fill | `ground` | dark-mode text |
|------|--------|----------|---------------|--------|---------------|----------|----------------|
| success | `#0A6B4A` | 6.53:1 | 5.86:1 | `#0E8A5F` | 4.36:1 | `#E7F6F0` | `#3DBA8C` (7.86:1) |
| warning | `#8A5200` | 6.39:1 | 5.85:1 | `#F0A202` | 2.13:1 ✗ | `#FEF4E0` | `#FFB020` (10.49:1) |
| danger  | `#C4362B` | 5.37:1 | 4.70:1 | `#D93B2E` | 4.55:1 | `#FDECEA` | `#FF8A80` (8.40:1) |
| info    | `brand.600` | 6.41:1 | 5.83:1 | `brand.500` | 4.66:1 | `brand.50` | `brand.300` (8.47:1) |

Two traps this table exists to prevent:

- **`#F0A202` cannot carry white text** (2.13:1). Warning fills take `neutral.900` text, or use
  the ground+text pair instead of a solid fill.
- **The `fill` value is not the `text` value.** `#0E8A5F` is fine as a fill but only 3.91:1 on
  its own tinted ground, so success *text* uses `#0A6B4A`.

The legacy `red #E54335` is 4.05:1 on white and fails AA for body text; it survives as a fill
only, and `#C4362B` carries error text.

### Logistics status tokens **[the important part]**

Status must be legible in grayscale and to a colorblind user. Every status is a **triple**:
label text + shape + color. Color is the third signal, never the only one.

| Status | Color | Shape | Label |
|--------|-------|-------|-------|
| draft / quote | `neutral.500` | hollow circle | Draft |
| awaiting payment | warning | half-filled circle | Awaiting payment |
| finding a rider | `brand.500` | pulsing ring | Finding a rider |
| rider assigned | `brand.600` | filled circle | Rider assigned |
| at pickup | `brand.600` | filled circle + tick | At pickup |
| in transit | `brand.500` | filled circle, route line active | In transit |
| delivered | success | filled circle + tick | Delivered |
| cancelled | `neutral.400` | hollow circle + slash | Cancelled |
| failed / returned | danger | filled circle + exclamation | Failed |
| refunded | `neutral.600` | hollow circle + arrow | Refunded |

Cancelled is **not** red. Cancellation is an outcome, not an error; colouring it red trains
users to ignore red.

### Color rules

1. No raw hex and no bare `Colors.*` outside `lib/core/design/`. The design guard hook enforces this.
2. No `withOpacity` for color derivation — take the ramp step. Opacity is for *transitions* only.
3. Every color has a functional reason. Decoration is not a reason.
4. Gradients: one permitted use, the map's bottom-sheet scrim. Nowhere else.

---

## 2. Typography

One superfamily, two cuts (D-02a):

- **Geist** — everything: `display.*`, `h1`–`h4`, all body, labels, captions, buttons, all
  `num.*`. Drawn for UI at small sizes, ships `tnum`, Latin + Latin Extended-A including
  French, weights w100–w900. **No italic cut exists.**
- **Geist Mono** — tracking codes and order/reference IDs only. Disambiguated 0/O and 1/l/I is
  a correctness feature for strings people transcribe and read aloud.

The brand register is no longer a face. It is tighter tracking at display sizes, plus the
saturated object, the Line and flush numerics. Latin Extended Additional (Yoruba/Igbo dot-below
ẹ ọ ṣ) is outside Geist's coverage — see D-02a.

Scale (pt, unscaled; `.sp` is banned for text — see rules):

| Token | Size / leading | Weight | Tracking | Use |
|-------|---------------|--------|----------|-----|
| `display.l` | 34 / 40 | 700 | -0.03em | one per screen, max |
| `display.s` | 28 / 34 | 700 | -0.03em | screen titles in hero contexts |
| `h1` | 24 / 30 | 700 | -0.025em | screen title |
| `h2` | 20 / 26 | 600 | -0.015em | section |
| `h3` | 17 / 24 | 600 | -0.01em | card title, sheet title |
| `h4` | 15 / 22 | 600 | -0.005em | list row title |
| `body.l` | 17 / 26 | 400 | 0 | reading copy |
| `body` | 15 / 22 | 400 | 0 | default |
| `body.s` | 13 / 20 | 400 | 0 | supporting |
| `label` | 13 / 16 | 600 | +0.005em | field labels, chips |
| `label.s` | 11 / 14 | 600 | +0.04em | uppercase eyebrow, status |
| `caption` | 12 / 16 | 400 | 0 | timestamps, helper |
| `button` | 15 / 20 | 600 | +0.01em | |
| `num.xl` | 32 / 36 | 700 | -0.02em, tabular | wallet balance, order total |
| `num.l` | 22 / 26 | 600 | -0.015em, tabular | price, ETA |
| `num` | 15 / 20 | 500 | tabular | inline money, distances |
| `mono` | 13 / 18 | 500 | +0.02em | tracking codes, reference IDs |

### Typography rules

1. **Never `.sp` for text.** `.sp` scales with device width and discards the user's OS text
   setting. Use unscaled sizes and let `MediaQuery.textScaler` do its job. Layouts must survive
   a 1.3× text scale; test at 2.0×.
2. **All money, ETAs, distances and counts use a `num.*` style** with
   `FontFeature.tabularFigures()`. Non-negotiable — it is what stops numbers jittering as
   values update, and it is the cheapest premium signal in the product.
3. Maximum three type styles visible in one component.
4. Line length caps at ~64 characters for `body.l`.
5. `h5`/`h6` do not exist in the new scale. Their call sites map to `h3`/`h4`.

---

## 3. Spacing — 4pt base

`0` · `1 = 2` · `2 = 4` · `3 = 8` · `4 = 12` · `5 = 16` · `6 = 20` · `7 = 24` · `8 = 32` ·
`9 = 40` · `10 = 48` · `11 = 64`

- Page horizontal margin: **20**. Never varies between screens.
- Between sections: **28** (`7`+`1`) or **32**. Pick one per screen and hold it.
- Inside a card: **16**. Between rows in a list: **12**. Label→field: **8**. Icon→label: **8**.
- Above a bottom-anchored primary action: **24**, plus safe-area inset.
- The existing `Gap` API stays; its scale collapses to these values.

Density is a design decision, not an accident. A logistics list should show 6–8 orders on a
standard phone. Whitespace that reduces that count is failing the user.

---

## 4. Radius

| Token | Value | Applies to |
|-------|-------|-----------|
| `sm` | 12 | inputs, chips, small tiles, inner blocks |
| `md` | 18 | list-row cards, record cards, quick-action tiles |
| `lg` | 24 | cards, the saturated hero, sheets (top corners only) |
| `full` | 999 | avatars, status pills, the pod, primary buttons |

Rules: one radius level per nesting depth; a child never gets a larger radius than its parent;
anything flush to a screen edge is 0. Primary buttons are `full`, not `sm` — the pill is part
of the Midnight look.

*(D-01 used 4 / 8 / 12 / 20. Superseded.)*

## 5. Elevation

**Dark mode carries no shadows at all.** Depth is surface lightness: `bg #0b0b0d` → `surf
#16181c` → `surf2 #1f2127` → `surf3 #262930`, separated by a `line #282b32` hairline. A shadow
on a near-black ground is invisible and only costs paint time.

**Light mode** uses two soft shadows: `--sh` `0 1px 3px rgba(16,24,40,.06)` on cards and rows,
`--sh2` `0 14px 34px -14px rgba(16,24,40,.3)` on the pod, sheets and the address overlay.

The rule in both: **prefer a border to a shadow**, and never more than one lifted surface on
screen at a time.

## 6. Motion

Durations: `instant 80ms` · `fast 140ms` · `base 200ms` · `slow 320ms` · `deliberate 480ms`.

Curves: standard `Curves.easeOutCubic` · enter `easeOutCubic` · exit `easeInCubic` ·
emphasized `Cubic(0.2, 0, 0, 1)`.

| Transition | Duration | Curve |
|-----------|----------|-------|
| press feedback | instant | standard |
| toggle, checkbox, chip | fast | standard |
| page push/pop | base | emphasized |
| bottom sheet | base | emphasized |
| map camera | slow | emphasized |
| status change on a live delivery | slow | standard |
| skeleton shimmer | 1200ms loop | linear |

Rules: **no bounce, no elastic, no overshoot anywhere.** No animation longer than 480ms.
Nothing animates purely decoratively. Honour `MediaQuery.disableAnimations` — reduced motion
means cross-fade or no transition, never a shortened bounce.

---

## 7. Iconography

One family, outlined, 1.5pt stroke, 24pt default (20pt dense, 28pt primary actions).
Filled variants only to mark a selected state. No emoji in UI. No 3D or illustrated icons.
Icons are optically centred, not box-centred. Icon-only controls need a semantic label.
An icon never carries meaning alone — it accompanies a label or has an accessible name.

---

## 8. Accessibility (binding)

- Body text ≥ 4.5:1; large text (≥19pt or ≥15pt bold) and UI components ≥ 3:1.
- Touch targets ≥ 44×44pt, including inside dense list rows.
- Layout survives 1.3× text scale; verify at 2.0×.
- Status never communicated by color alone — the triple in §1 is mandatory.
- Every interactive element has a focus state (a 2pt `brand.700` ring at 2pt offset).
- Errors are announced, tied to their field, and stated in words — never a red border alone.
- Decorative images are excluded from the semantics tree; meaningful ones are labelled.
- Respect reduced motion.

---

## 9. Vinkol design signatures

Brief §24 asks for 3–5 marks that make a Vinkol screen recognizable with the logo removed.
These are derived from what already exists, not imported.

1. **The Line.** One continuous vertical route line — pickup node, dotted path, diamond
   destination — is the product's organizing device. It also runs **horizontally** as the
   progress track on order detail and as the reward route on home. Rendered at four scales: a 2-node glyph in an order row,
   the connector in the booking form (evolving the existing dotted connector in
   [HorizontalDottedLine.dart](lib/widgets/app_bar/HorizontalDottedLine.dart)), the full
   tracking timeline, and the receipt. Same geometry every time. **A user should be able to
   identify a Vinkol screen from the line alone.**
2. **The Pod.** Five tabs in a floating pill (Home · Shop · Records · Wallet · Profile). The
   active tab **expands into a pill inside the pill** and reveals its label, so the selected
   state carries shape as well as colour. Stays dark in light mode — the one constant object
   across both themes (D-08).
3. **Status as typography.** Small-caps label + shape + color, in that priority order. Survives
   grayscale, colorblindness and a screen reader. See the status triple in §1.
4. **Flush numerics.** All money, ETAs and distances right-aligned on a shared optical axis in
   tabular figures, currency symbol at reduced weight so the number is the hero. This is what
   makes multi-currency feel native rather than retrofitted.
5. **Hairline chrome on a full-bleed map.** The map is the canvas; controls are e0 surfaces
   with hairline borders, never floating shadowed cards. This is the operational register
   applied to the map, and it is the clearest expression of Direction A in the product.
