---
name: vinkol-screen-redesign
description: The end-to-end workflow for redesigning one Vinkol screen or flow — audit, structure, states, implement, critique. Use when asked to redesign, rebuild or modernize a screen, flow or feature area of the Vinkol app. Enforces system-before-screens and stops screens being restyled against unratified tokens.
---

# Vinkol Screen Redesign

One screen at a time. The order matters more than the taste.

## Preconditions — check before starting

- `.claude/design/05-decisions.md`: is **D-01 (visual direction) RATIFIED**? If not, stop and
  say so. Redesigning screens against an unratified direction is the most expensive mistake
  available here — every screen gets redone when the direction lands.
- Are the tokens implemented in `lib/core/design/`? If not, this is Phase 2 work, not screen
  work. Say so and do the tokens first.
- Is the screen over ~400 lines? Decompose it into widgets **in a separate change** before
  redesigning. Never restructure and restyle in the same diff — nothing is reviewable.

## Steps

**1. Audit.** Run the `vinkol-design-audit` skill on the screen. Do not skip this because the
screen "looks simple".

**2. Structure before pixels.** Write down, in three lines: what the user came here to do;
what they must see to do it; what they can safely not see. Then decide the hierarchy — one
primary element, at most two secondary. If the current screen's structure is wrong, fix the
structure; styling a wrong structure produces a prettier wrong screen.

**3. Content.** Write the actual copy now, not "Lorem" and not later. Clear, human, confident,
concise. No exclamation marks, no "Oops!", no fake friendliness, no corporate jargon. Assume
+40% length under translation and decide the overflow behavior for every string.

**4. States.** Design all of them before implementing the happy path: loading (skeleton, not a
spinner, wherever the layout is known), empty (with an action), error (with a retry and a
reason), offline, permission-denied, and where money or delivery state is involved, pending and
failed. These are first-class screens, not fallbacks.

**5. Implement.** Load `vinkol-design-system` and follow it. Tokens only. Match the file's
existing structure and idiom — this is an evolution, not a rewrite. Keep the public widget API
stable unless the change includes the call-site updates.

**6. Verify.**
```bash
flutter analyze                       # must be clean for the files you touched
dart format --output=none --set-exit-if-changed <files>
```
Then re-read your own diff for the hard rules in `vinkol-design-system`.

**7. Critique.** Run the `vinkol-design-critique` skill. `ITERATE` means iterate — do not
report the screen as done with the critique's findings still open.

**8. Record.** Update the screen's row in `.claude/design/06-screen-inventory.md`.

## Per-screen guidance

**Map screens.** The map is the canvas, full-bleed. Controls are e0 hairline surfaces, never
floating cards. One bottom sheet, three snap points at most. The route Line renders on the map
*and* in the sheet, same geometry. Never let the sheet obscure the destination marker at its
mid snap point.

**Checkout.** Every line item visible before the total: item value, delivery fee, tax,
discount, protection. Total is `num.xl`. The currency comes from the market layer. Payment
method and delivery estimate are both visible at the moment of commitment — a user should never
have to scroll to find what they are agreeing to.

**Tracking.** The Line is the screen. Completed milestones are solid, current pulses, future is
hollow. Answer, in this order: where is it, who has it, when does it arrive, what happens next,
how do I get help.

**Lists (orders, deliveries, transactions).** Density is the feature. 6–8 rows on a standard
phone. Status as the triple. Money right-aligned, tabular, on a shared axis. Resist making each
row a card.

**Forms.** Label above field, 8pt gap. Errors below the field, in words, tied to the field.
One primary action, full width, bottom-anchored. Never disable the submit button silently —
say what is missing.
