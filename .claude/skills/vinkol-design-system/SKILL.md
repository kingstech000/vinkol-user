---
name: vinkol-design-system
description: The binding Vinkol design system — tokens, rules and banned patterns for any Flutter UI work in this repo. Load BEFORE writing or editing any widget, screen, theme, color, text style, spacing, radius, shadow or animation. Triggers on: build/redesign/restyle a screen or widget, "make it look better", touching lib/widgets/ or any lib/features/**/view/, adding a color or text style, dark mode, empty/error/loading states.
---

# Vinkol Design System

Read `.claude/design/04-tokens.md` for the full token tables before your first UI edit in a
session. This file is the enforcement summary — the token doc is the source of truth.

## Before you write UI

1. Read `.claude/design/04-tokens.md` (tokens) and `.claude/design/02-do-not-lose.md` (what is
   protected).
2. Check `.claude/design/05-decisions.md`. **If D-01 (visual direction) is still OPEN, do not
   invent one.** Say so and ask, or work only on structure that direction does not affect.
3. Read the screen you are changing, in full, before changing it.

## Hard rules — a PostToolUse hook flags violations of 1–5

1. **No raw hex** (`Color(0xFF...)`) outside `lib/core/design/`.
2. **No bare Material colors** (`Colors.grey`, `Colors.red`, …) outside `lib/core/design/`.
   `Colors.transparent` is the one exception.
3. **No `.sp` on text.** Unscaled sizes; let `MediaQuery.textScaler` work (decision D-04).
4. **No hardcoded currency symbols.** Money formats through the market layer (`vinkol-globalize`).
5. **No `withOpacity` to derive a color.** Take the ramp step. Opacity is for transitions.
6. **No `BorderRadius.circular(n)` with a literal.** Use the radius tokens: 4 / 8 / 12 / 20 / full.
7. **No hand-written `BoxShadow`.** Use e0–e3. Default to e0: a 1px `border.subtle` and no shadow.
8. **No `left`/`right`** — `EdgeInsetsDirectional`, `start`, `end`.
9. **No status communicated by color alone** (decision D-05): label + shape + color, always.
10. **No emoji in UI.**

## Token quick reference

- **Brand** `#0E74D8` is `brand.500` and never changes. Brand-colored *text* on white or on the
  canvas uses `brand.600` `#0B5EB4` — `500` is only 4.30:1 on the canvas.
- **Spacing** 4pt scale: 2 4 8 12 16 20 24 32 40 48 64. Page margin 20. Card padding 16.
  Section gap 28 or 32 — pick one per screen.
- **Radius** xs 4 · sm 8 (inputs, rows, chips) · md 12 (cards) · lg 20 (sheets, top corners
  only) · full (pills, avatars, the pod). A child never has a larger radius than its parent.
- **Type** display/h1–h4 / body.l/body/body.s / label/label.s / caption / button / num.xl/num.l/num / mono.
  All money, ETAs, distances and counts use `num.*` with `FontFeature.tabularFigures()`.
- **Motion** 80 / 140 / 200 / 320 / 480ms, `easeOutCubic` and `Cubic(0.2,0,0,1)`.
  No bounce, no elastic, nothing over 480ms. Honour `MediaQuery.disableAnimations`.
- **Elevation** e0 is the default and should cover most of the app.

## The five signatures — use them, they are the brand

1. **The Line** — the vertical route line (pickup → path → destination) at four scales: order
   row glyph, booking form connector, tracking timeline, receipt. Same geometry every time.
2. **The Pod** — the black pill is nav at rest and the live-delivery status pod when a delivery
   is active. One object, morphing. Never two competing bottom bars.
3. **Status as typography** — small-caps label, then shape, then color.
4. **Flush numerics** — money/ETA/distance right-aligned on a shared axis, tabular, currency
   symbol at reduced weight so the number is the hero.
5. **Hairline chrome on a full-bleed map** — map controls are e0 with hairline borders, never
   floating shadowed cards.

## Banned aesthetics (brief §3)

Gradients (one exception: the map sheet scrim) · glassmorphism · everything-is-a-rounded-card ·
20–32pt radii on ordinary surfaces · drop shadows as decoration · decorative illustrations,
3D objects or sparkles · emoji as UI · pills for everything · giant headline + gradient text ·
whitespace that destroys density · generic empty states · identical repeated cards ·
decorative charts.

Premium is restraint, hierarchy and craft — not more effects.

## Migration discipline (decision D-03)

`AppColors`, `AppText`, `Gap` and `AppButton` keep their names and signatures; they are
re-pointed at the new tokens underneath. 202 files depend on them. Add constructors; do not
rename or remove without a codemod in the same change. Dying members get `@Deprecated` naming
their replacement.

## Before you call a screen done

Run the `vinkol-design-critique` skill on it. A screen that has not been critiqued is not done.
