#!/bin/bash
# Capture one screenshot per preview scenario, synced to the harness's
# "PREVIEW_SCREEN: <name>" markers so timing drift can't make you screenshot
# the wrong state.
#
#   ./capture.sh /tmp/preview.log ./shots "Populated" "Empty" "Error"
#
# Then read each PNG. That is the step that finds the bugs.

set -uo pipefail

LOG="${1:?usage: capture.sh <log> <outdir> <scenario>...}"
OUT="${2:?usage: capture.sh <log> <outdir> <scenario>...}"
shift 2

mkdir -p "$OUT"

# Wait for the app to actually be up before watching for markers.
until grep -qE "Flutter run key commands|error:|Could not build" "$LOG" 2>/dev/null; do
  sleep 3
done

if ! grep -q "Flutter run key commands" "$LOG"; then
  echo "Build failed:" >&2
  grep -E "error:|Could not build" "$LOG" | tail -5 >&2
  exit 1
fi

grab() {
  local want="$1"
  local out="$OUT/$(echo "$want" | tr ' /' '__').png"
  local waited=0

  while [ "$waited" -lt 120 ]; do
    # Exact match. A glob like *"Wallet"* also matches "Wallet empty" and you
    # end up capturing the wrong screen.
    local last
    last=$(grep "PREVIEW_SCREEN" "$LOG" | tail -1 | sed 's/.*PREVIEW_SCREEN: //')
    if [ "$last" = "$want" ]; then
      sleep 2   # let the frame settle (images, animations)
      xcrun simctl io booted screenshot "$out" >/dev/null 2>&1
      echo "captured $out"
      return 0
    fi
    sleep 1
    waited=$((waited + 1))
  done

  echo "timed out waiting for scenario: $want" >&2
  return 1
}

for scenario in "$@"; do
  grab "$scenario" || exit 1
done
