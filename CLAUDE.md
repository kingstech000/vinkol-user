# Vinkol User App

Flutter customer app for Vinkol, a logistics platform expanding from Nigeria to Canada and
beyond. Riverpod state, feature-first layout (`lib/features/<feature>/{data,model,view,view_model}`),
shared widgets in `lib/widgets/`, design primitives in `lib/core/utils/` (migrating to
`lib/core/design/`).

## Active work: the global design redesign

The app is mid-redesign from a Nigerian logistics app into one global product. The governing
documents live in `.claude/design/` and are binding:

| File | What it is |
|------|-----------|
| `00-mandate.md` | The objective, the five non-negotiables, the phase order |
| `01-design-dna-report.md` | What the current design measurably is |
| `02-do-not-lose.md` | Elements the redesign must preserve |
| `03-globalization-gaps.md` | Brand layer vs market layer |
| `04-tokens.md` | The token spec (Midnight) |
| `05-decisions.md` | **Every ratified decision. Read D-07 to D-10 first** |
| `06-screen-inventory.md` | Every screen and its redesign state |
| `07-redesign-groups.md` | The 65 view files grouped by shared design problem |
| `08-backend-gaps.md` | **The market layer's specification. The source of truth for Canada work** |
| `09-prototype.md` | ~~The prototype~~ — **stale, the prototype is abandoned** |
| `10-build-plan.md` | ~~14 work packages~~ — **stale, keyed to the abandoned prototype** |

## Where things stand (7 Sep 2026)

- **The prototype is abandoned.** `prototype/` is no longer a specification and should not be
  consulted — it predates the backend contract and contradicts it. The market-layer decisions
  taken from it (Interac, a Canadian wallet, a `market-select` screen, `CA$`, client-computed
  tax) are all void. `09-prototype.md` and `10-build-plan.md` are keyed to it and are stale.
- **`08-backend-gaps.md` is the source of truth for the market layer.** Where any other design
  doc disagrees with it, it wins.
- **The Canada expansion is live on staging** and largely implemented in Flutter:
  quote-then-order, `grandTotal` and the tax line, market-aware currency rendering,
  market-conditional payment sources, and the withdrawable-amount breakdown. The market layer
  is `lib/core/money/money.dart`, covered by `test/core/`.
- **`lib/core/design/` is stale** — built for a rejected direction, and nothing consumes it.
- The visual redesign is parked; the Canada migration is the active work.

**Load the `vinkol-design-system` skill before writing or editing any UI.** It carries the hard
rules; a PostToolUse hook flags violations in lines you add.

Other skills: `vinkol-design-audit` (measure a screen), `vinkol-screen-redesign` (the per-screen
workflow), `vinkol-design-critique` (the ship gate), `vinkol-globalize` (market layer).

Agents: `vinkol-design-auditor`, `vinkol-design-director`, `vinkol-flutter-ui-engineer`,
`vinkol-logistics-ux`, `vinkol-i18n-auditor`.

## Standing rules

- **Tokens, not literals.** No raw hex, no bare `Colors.*`, no literal radii, no hand-written
  `BoxShadow`, no `withOpacity` for color derivation, outside `lib/core/design/`.
- **No `.sp` on text** — it discards the user's OS text-size setting (decision D-04).
- **No hardcoded currency symbols** — money goes through the market layer.
- **`AppText`, `Gap`, `AppButton` and `AppColors` keep their public API** — 202 files depend on
  them (decision D-03). Change what they produce, not what they are called.
- **Status is never color alone** — label + shape + color (D-05), and only from the closed set
  of six: `pending` · `with rider` · `with shopper` · `delivered` · `cancelled` · `unattended`.
- **Only build what the backend supports** (D-10) — except the market layer, which is the
  deliverable (D-09).
- Verify UI changes with `flutter analyze` and report the real output.

## Commands

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib/
flutter run
python3 .claude/scripts/contrast.py '#0E74D8' '#FFFFFF'   # WCAG check before quoting a ratio

flutter test test/core/                                  # market layer: money, quotes, payments
```

## Notes

- Package name is `starter_codes` (from the template it was forked from); imports read
  `package:starter_codes/...`.
- `lib/core/theme/{light,dark}_theme.dart` are dead code — both declare `ColorScheme.dark` with
  a purple primary and neither is referenced. `main.dart` builds its theme inline. Wiring a real
  theme layer is Phase 2 work.
- Dead files pending deletion: `wallet_screen_backup.dart`,
  `features/delivery/view/screen/test.dart`, `utils/phone_number_validation_example.dart`,
  `widgets/bottom_nav_bar.dart` (superseded by the pod in `dashboard_screen.dart`),
  `widgets/text_action_modal.dart` (superseded by `widgets/modal/app_status_dialogs.dart`).
