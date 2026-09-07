# Do Not Lose

Brief §0.5. These elements must survive the redesign. Changing one requires a written
justification in `05-decisions.md`, approved before any code moves.

| # | Element | Why it stays | Permitted evolution |
|---|---------|--------------|---------------------|
| 1 | **Vinkol Blue `#0E74D8`** | The only truly owned brand asset. Recognized by existing users; distinct from Uber-black, DoorDash-red, Bolt-green. | Keep the 500 step at exactly `#0E74D8`. Build a 50–950 ramp around it. Use 600 (`#0B5EB4`, 6.41:1) for text on white where 500's 4.66:1 is too tight. |
| 2 | **The black floating pod** | The one distinctive spatial idea in the product. A black pill over content is unusual in this category and instantly identifies a Vinkol screen. | Refine geometry, spacing and states. Extend it into a live-delivery status pod. Never replace it with a standard edge-to-edge tab bar. |
| 3 | ~~**Montserrat as the brand voice**~~ **RELEASED by D-02a (7 Sep 2026)** | Was: present on every screen since launch, the geometric character reads confident and modern. | **Superseded.** The type layer is Geist alone (Geist Mono for identifiers). Under D-07 the brand voice is the saturated blue object, the Line, flush numerics and status typography — not a display face. Montserrat's specific liabilities (no tabular figures, wide and loose at 13–15pt, costly under +40% translation growth) are what ended it. Preserve the *confident, modern* read; do not preserve the face. |
| 4 | **The `AppText` / `Gap` / `AppButton` API surface** | 202 Dart files call these. Preserving the call signatures lets the visual system change underneath without a 200-file rewrite. This is a migration constraint as much as a design one. | Change what the constructors *produce*, not what they are *named*. Add constructors; do not remove or rename existing ones without a codemod in the same change. |
| 5 | **Full-width primary action anchored at the bottom** | Consistent across auth, booking and checkout. Thumb-reachable, unambiguous, and correct for one-handed use in a delivery flow. | Height, radius and states change; the pattern does not. |
| 6 | **Map-first booking** | The product's core interaction and its clearest strength over form-based competitors. | The map gets *more* prominent, not less. See mandate §Map. |
| 7 | **Light canvas, white content blocks** | The existing spatial reading: content floats on a recessed ground. | Replace `Colors.grey.shade100` with a token'd canvas and give the blocks hairline borders instead of shadows. The figure/ground relationship stays. |

## Explicitly NOT protected

The purple family (`primaryLight #8068FF`, `purpleGrey #CECAE5`, the theme files' `#684DFA`)
is not brand DNA. It is inconsistent with the blue, appears in no brand asset, and reads as
palette drift. Remove it without ceremony.

The Tailwind-default indigo/emerald/violet literals (`#6366F1`, `#10B981`, `#8B5CF6`) are not
Vinkol. Remove them.
