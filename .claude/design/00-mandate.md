# Vinkol Global Redesign — Operative Mandate

Condensed from the two source briefs ("Senior Product Designer — Vinkol Global Mobile App
Redesign" and "0. Mandatory First Step — Study the Existing Vinkol Design Language") plus the
"Vinkol Global Design Context" note. This file is the binding version. Where the briefs and
this file disagree, the briefs win — but keep them in sync.

## The one-line goal

Evolve Vinkol from a Nigerian logistics app into one global logistics product that a user in
Lagos, Toronto, or London reads as a serious technology company — without losing the brand a
current Vinkol user already recognizes.

## Five non-negotiables

1. **Evolution, not replacement.** The existing identity is the anchor. Every departure from it
   must be justified in writing before it is implemented. See `02-do-not-lose.md`.
2. **The codebase is the source of truth.** Never describe the current product from memory or
   assumption. Read the Dart.
3. **One global brand, localized markets.** No "Vinkol Nigeria" and "Vinkol Canada". A global
   brand layer plus a configurable market layer. See `03-globalization-gaps.md`.
4. **No AI slop.** Restraint, hierarchy and craft — not gradients, glassmorphism, rounded
   everything, decorative icons, or a screen made of identical cards. Full list in the
   `vinkol-design-critique` skill.
5. **System before screens.** Tokens and components first; screens are assembled from them.
   Thirty independently beautiful screens is a failure condition.

## Order of work

```
Phase 0  Audit + DNA report                      → 01-design-dna-report.md      [done]
Phase 1  Lock the visual direction               → 05-decisions.md D-01, D-02   [done]
Phase 2  Tokens in code                          → lib/core/design/*            [layer built; not wired]
Phase 3  Component library on tokens             → lib/widgets/*                [not started]
Phase 4  Market layer (currency, locale, config) → lib/core/market/*            [not started]
Phase 5  Screen-by-screen redesign               → 06-screen-inventory.md       [not started]
Phase 6  Edge states, motion, accessibility pass                                [not started]
```

### Phase 2 status

Built and analyzer-clean: `lib/core/design/` — `vinkol_color.dart` (ramps, semantic light/dark
as a `ThemeExtension`, the ten status triples), `vinkol_type.dart` (Montserrat / Inter / IBM
Plex Mono, tabular numerics), `vinkol_space.dart` (4pt scale, radius, elevation),
`vinkol_motion.dart`, `vinkol_theme.dart` (real `ThemeData` for both brightnesses),
`design.dart` (barrel). Additive only — nothing existing renders differently yet.

Remaining, in order, each its own change:

1. Wire `VinkolTheme.light()` / `.dark()` into `MaterialApp` in `main.dart`, replacing the
   inline `ThemeData.light().copyWith(...)`. Delete the dead `lib/core/theme/` files.
2. Re-point `AppColors` at `VinkolPalette` and `AppText`/`textstyles.dart` at `VinkolType`,
   keeping every public name and signature (decision D-03). This is the change that makes 202
   files render differently — review it on its own.
3. `@Deprecated` the members that die: `primaryLight`, `purpleGrey`, `blue`, `formWhite`.
4. Collapse the `Gap` ladder onto `VinkolSpace`.

```
```

Do not start Phase N+1 while Phase N is unratified. The most common failure mode of this kind
of project is redesigning screens against tokens that are still moving.

## The quality bar (applies to every screen)

A screen ships only if it answers all five: Where am I? What is happening? What matters most?
What can I do? What happens next? — and passes the eight checks in the `vinkol-design-critique`
skill (product, UX, visual, brand, global, accessibility, system, distinctiveness).

## Deliverables the briefs ask for, and where they live here

| Brief deliverable        | Location                                            |
|--------------------------|-----------------------------------------------------|
| 01 Design philosophy     | `01-design-dna-report.md` + this file               |
| 02 Brand/visual language | `04-tokens.md`                                      |
| 03 Design tokens         | `04-tokens.md` → implemented in `lib/core/design/`  |
| 04 Component library     | `lib/widgets/` (Phase 3)                            |
| 05 UX architecture       | `06-screen-inventory.md`                            |
| 06 High-fidelity screens | the app itself (Phase 5)                            |
| 07 Edge states           | Phase 6; tracked per screen in the inventory        |
| 08 Motion direction      | `04-tokens.md` § Motion                             |
| 09 Accessibility         | `04-tokens.md` § Accessibility + critique skill     |
| 10 Internationalization  | `03-globalization-gaps.md`                          |
