#!/usr/bin/env bash
# Vinkol design-token guard.
#
# PostToolUse hook on Edit|Write. Reads the hook JSON on stdin, and checks the lines this
# change ADDED (via git diff) against the hard rules in .claude/skills/vinkol-design-system.
# Exits 2 with the findings on stderr so they are fed back to the model; the edit itself has
# already been applied, so this is feedback, not a block.
#
# Only added lines are checked, so the pre-existing token debt in a file does not fire on
# every edit. Caveat: uncommitted changes made before this session count as "added".
set -uo pipefail

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_response.filePath // .tool_input.file_path // empty' 2>/dev/null)

[ -n "$file" ] || exit 0
case "$file" in
  *.dart) ;;
  *) exit 0 ;;
esac
case "$file" in
  */lib/core/design/*) exit 0 ;;   # the tokens themselves are allowed to hold literals
  */lib/core/money/*) exit 0 ;;    # likewise the market layer, which defines the symbols
  */lib/*) ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

# The lines this change added. Fall back to the whole file when git can't tell us.
added=$(git diff -U0 HEAD -- "$file" 2>/dev/null | grep '^+' | grep -v '^+++' | sed 's/^+//')
[ -n "$added" ] || added=$(cat "$file")

findings=""
check() { # check <regex> <message>
  local hits
  hits=$(printf '%s\n' "$added" | grep -cE "$1" 2>/dev/null || true)
  [ "${hits:-0}" -gt 0 ] && findings="${findings}  - ${hits}× ${2}"$'\n'
  return 0
}

check '0x[fF][fF][0-9a-fA-F]{6}'                   'raw hex color — use a token from lib/core/design/vinkol_color.dart'
# grep -E has no lookahead, so the Colors.* check is done by hand
# The leading boundary keeps AppColors.* — the sanctioned accessor — from matching.
colors=$(printf '%s\n' "$added" | grep -oE '(^|[^A-Za-z_])Colors\.[a-zA-Z]+' | grep -v 'Colors.transparent' | wc -l | tr -d ' ')
[ "${colors:-0}" -gt 0 ] && findings="${findings}  - ${colors}× bare Colors.* — use a design token (Colors.transparent is fine)"$'\n'
check '\.sp\b'                                      'text sized with .sp — banned by decision D-04, use unscaled sizes'
check '₦'                                           'hardcoded currency symbol — route through the market layer'
check 'withOpacity\('                               'withOpacity for color derivation — take the ramp step instead'
check 'BoxShadow'                                   'hand-written BoxShadow — use elevation e0-e3 (default e0: a hairline border)'
check 'EdgeInsets\.only\((left|right):'             'left/right padding — use EdgeInsetsDirectional with start/end'

# Radius literals outside the scale 4 / 8 / 12 / 20 / 999
bad_radii=$(printf '%s\n' "$added" | grep -oE 'BorderRadius\.circular\(([0-9]+)' \
  | grep -oE '[0-9]+$' | grep -vxE '4|8|12|20|999' | sort -n | uniq | paste -sd', ' - || true)
[ -n "$bad_radii" ] && findings="${findings}  - off-scale radius: ${bad_radii} — the scale is 4 / 8 / 12 / 20 / full"$'\n'

[ -n "$findings" ] || exit 0

{
  echo "Design token violations in the lines you added to ${file##*/}:"
  printf '%s' "$findings"
  echo "Rules: .claude/skills/vinkol-design-system/SKILL.md · Tokens: .claude/design/04-tokens.md"
  echo "Fix these in the code you just wrote. Pre-existing debt elsewhere in the file is not your scope unless asked."
} >&2
exit 2
