---
name: flutter-ui-preview
description: Redesign or build a Flutter screen and verify it by actually rendering it on a simulator. Use whenever asked to redesign, restyle, improve or build a screen, dialog, sheet or component, or when a UI change needs visual confirmation. Covers the throwaway preview harness, log-synced screenshot capture, and what to check once you can see it.
---

# Designing and verifying Flutter UI

`flutter analyze` says nothing about layout. Every screen redesign done this way
has had at least one defect that compiled cleanly and only appeared on screen:
truncated titles, a chevron implying navigation that went to the wrong flow, a
black-on-red button that looked enabled while inert, character counters nobody
wanted, orphaned label text, an empty state promising a pull-to-refresh it
could not perform.

**So: do not report a UI change as done until you have looked at a screenshot of
it.** The loop below makes that cheap enough to do every time.

## 1. Read before you design

Read the target screen *and* what it depends on: the shared widget kit, the
models, the view model and providers, the routes it navigates to. Two things
come out of this:

- What the design system already provides, so the new screen looks like the app
  instead of like a new app.
- What data actually exists. A design that shows a field the model does not
  carry is a design that ships as `N/A`.

Check whether a sibling screen already solves the same problem. If two screens
need the same component, extract it to a shared widget rather than writing it
twice — the second caller is what proves the abstraction.

## 2. Follow the project's design rules

Check `.claude/` memory or `CLAUDE.md` for standing UI rules before writing
widgets. In this project they are:

- **Flat surfaces.** No `BoxShadow`, no non-zero `elevation`, no glow. Separate
  surfaces with hairline borders on white over an off-white canvas.
- **No icon backgrounds.** Icons render bare — never on a tinted tile, filled
  circle or coloured chip.
- **No gradients.** Cards, banners and headers take a single solid colour.

Grep for violations after writing, since these are easy to reintroduce:

```bash
grep -rn "BoxShadow\|gradient:" lib/features/<area>
grep -rn "elevation:" lib/features/<area> | grep -v "elevation: 0"
```

## 3. Write it, then analyze the touched paths

```bash
flutter analyze lib/features/<area> lib/widgets/<touched>
```

Fix every `error`. Pre-existing `info`/`warning` in files you did not touch are
not yours to fix, but warnings *in* the file you rewrote usually are — rewriting
is a good moment to clear them.

## 4. Build a throwaway preview harness

The screen is normally behind auth, network and navigation. A harness at
`lib/dev_preview_<thing>.dart` gives it mock data and its own `main()`.

Start from `templates/preview_harness.dart.template`. Three things make it work:

**Provider overrides for mock data.** Override the providers the screen watches
so it renders without a backend.

**A "pin" widget.** Screens fetch on mount and overwrite the mock a second
later. A `Timer.periodic` that re-asserts the mock state every 300–400ms keeps
previews deterministic. Without this you screenshot real (or empty) data.

**A scenario cycler.** Cycle states every ~8s and `debugPrint` a marker:

```dart
debugPrint('PREVIEW_SCREEN: $name');
```

The marker is what lets capture stay in sync — see step 6.

Cover the states that actually differ: populated, empty, error, loading, plus
the branches your design takes (bulk vs single, verified vs pending, NG vs CA).
Bugs hide in the branches, not the happy path.

## 5. Run it on the simulator

```bash
xcrun simctl list devices booted          # get the device id
flutter run -t lib/dev_preview_<thing>.dart -d <device-id> > /tmp/preview.log 2>&1 &
```

Run it in the background and wait on the log rather than sleeping blindly:

```bash
until grep -qE "Flutter run key commands|error:|Could not build" /tmp/preview.log; do sleep 3; done
```

An incremental rebuild is ~25s. To apply a fix, kill and re-run — there is no
interactive stdin to send `r` to when the process is backgrounded:

```bash
kill $(pgrep -f "dev_preview_<thing>")
```

## 6. Capture screenshots synced to the marker

Do not guess timings — drift makes you screenshot the wrong scenario. Poll for
the marker, then capture. `templates/capture.sh` has this; the shape is:

```bash
grab() {
  local want="$1" out="$2"
  while true; do
    local last=$(grep "PREVIEW_SCREEN" /tmp/preview.log | tail -1 | sed 's/.*PREVIEW_SCREEN: //')
    [ "$last" = "$want" ] && { sleep 2; xcrun simctl io booted screenshot "$out"; return; }
    sleep 1
  done
}
```

Two gotchas that have both bitten:

- **Compare with `=`, not a glob.** `[[ $last == *"Wallet"* ]]` also matches
  `Wallet empty`, and you silently capture the wrong screen.
- **Modal routes outlive the home swap.** A `showModalBottomSheet` pushed in one
  scenario is still on top when the cycler moves to the next, dimming it. Give
  modals their own harness run, or pop to first route before switching.

Then **read each PNG**. That is the step that finds the bugs.

## 7. What to look for once you can see it

- **Truncation.** Long titles, addresses, emails. Check the *longest* realistic
  value, not the mock you chose.
- **Affordances that lie.** A chevron on a row that opens a preview; a filled
  button that is actually disabled; a "pull down to refresh" on a non-scrollable
  `Center`.
- **Contrast.** Default `AppButton` text colour on a custom background is a
  recurring one — dark text on a red destructive button.
- **Orphaned content.** A value rendered with no label, reading as a stray
  string.
- **Cross-state consistency.** Compare the states side by side; a banner that
  stays brand-blue while the rows below it are red is telling two stories.

## 8. Test pure logic with a real test, not a screenshot

Formatting, validation and market/branch selection are cheaper and far more
exhaustively covered by `flutter test` than by looking at them. Screenshot the
layout; unit-test the rules.

```bash
flutter test test/<thing>_test.dart
```

Keep that test — it is worth more than the harness.

## 9. Clean up and prove it

```bash
kill $(pgrep -f "dev_preview_")
rm -f lib/dev_preview_*.dart
ls lib/dev_preview_*.dart          # must find nothing
flutter analyze lib/ | grep -c "error •"   # must be 0
```

If you temporarily changed app code to preview something (forcing a tab index,
seeding a field), revert it and **grep to confirm the revert**, in the same
command. It is easy to forget and it ships.

## Reporting

Say what you changed, what rendering caught that the analyzer did not, and what
you could not verify (states reachable only against a live failing backend, for
example). Do not describe a state you never rendered.
