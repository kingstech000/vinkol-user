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
| `08-backend-gaps.md` | **The Canada spec for the backend, and what was removed as invented** |
| `09-prototype.md` | **The approved prototype: how to run it, and every screen's Flutter target** |
| `10-build-plan.md` | **14 work packages with a paste-ready prompt for each** |

## Where things stand (3 Sep 2026)

- **Direction ratified: A · Midnight** (D-07). Dark-first, one saturated blue object per
  screen. Two earlier attempts are kept for reference only.
- **The prototype is the source of truth.** 44 clickable screens, Direction A, light + dark,
  NG + CA markets. `cd prototype && npm start` → `http://localhost:3000/app`. When the docs and
  the prototype disagree, the prototype wins.
- **`lib/core/design/` is stale** — built for the rejected direction. WP1 reworks it. Nothing
  else should start first.
- **The Canada expansion is the point of the project** (D-09). Market-layer work stays even
  though the backend does not support it yet.
- Nothing has been implemented in Flutter beyond the stale token layer.

To start any piece of work, open `10-build-plan.md` and paste the prompt for that package.

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

cd prototype && npm start                                # the approved prototype, :3000/app
```

## Notes

- Package name is `starter_codes` (from the template it was forked from); imports read
  `package:starter_codes/...`.
- `lib/core/theme/{light,dark}_theme.dart` are dead code — both declare `ColorScheme.dark` with
  a purple primary and neither is referenced. `main.dart` builds its theme inline. Wiring a real
  theme layer is Phase 2 work.
- Dead files pending deletion: `wallet_screen_backup.dart`,
  `features/delivery/view/screen/test.dart`, `utils/phone_number_validation_example.dart`,
  `widgets/bottom_nav_bar.dart` (superseded by the pod in `dashboard_screen.dart`).
