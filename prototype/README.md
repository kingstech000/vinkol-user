# Vinkol Prototype — Wave 1

The 10-screen spine of the global redesign, as a running website. Not production code and not
a component library — a surface for judging the design system before it costs Flutter time.

```bash
cd prototype
npm install
npm start          # http://localhost:3000
PORT=4000 npm start
```

## What it is

Plain HTML, CSS and ES modules served by Express. No build step, no framework, no bundler.

`public/css/tokens.css` is a direct transcription of `lib/core/design/` — the same hex values,
the same 4pt scale, the same radius steps, the same durations. **When a token changes in Dart,
change it here in the same commit.** The prototype is only useful while it cannot drift.

## What it proves

Both registers (operational and hero), all five signatures (the Line, the Pod, status as
typography, flush numerics, hairline chrome on a full-bleed map), light and dark, and the
loading, empty and error states that the Flutter app mostly does not have yet.

## What it is not

Not responsive beyond the phone frame, not accessible-audited, not connected to an API. Every
number in it is fixture data in `js/fixtures.js`.
