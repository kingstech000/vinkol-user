#!/usr/bin/env python3
"""WCAG contrast checker for Vinkol design tokens.

  python3 .claude/scripts/contrast.py '#0E74D8' '#FFFFFF'    check one pair
  python3 .claude/scripts/contrast.py --pairs pairs.txt      check a file of "fg bg label" lines

Thresholds: >= 4.5 body text, >= 3.0 large text (>=19pt, or >=15pt bold) and UI components.
Every ratio quoted in .claude/design/04-tokens.md came from this script. If you change a token
value, re-check it here before writing a new number into the doc.
"""
import sys


def luminance(hex_color):
    h = hex_color.lstrip("#")
    if len(h) != 6:
        raise ValueError(f"not a 6-digit hex color: {hex_color}")
    ch = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    ch = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in ch]
    return 0.2126 * ch[0] + 0.7152 * ch[1] + 0.0722 * ch[2]


def ratio(fg, bg):
    hi, lo = sorted((luminance(fg), luminance(bg)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)


def verdict(r):
    if r >= 4.5:
        return "AA body"
    if r >= 3.0:
        return "AA large/UI only"
    return "FAIL"


def main(args):
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        return 0
    if args[0] == "--pairs":
        failures = 0
        with open(args[1]) as fh:
            for line in fh:
                parts = line.split()
                if len(parts) < 2 or line.lstrip().startswith("#!"):
                    continue
                fg, bg = parts[0], parts[1]
                label = " ".join(parts[2:])
                r = ratio(fg, bg)
                v = verdict(r)
                failures += v == "FAIL"
                print(f"{r:6.2f}:1  {v:<18} {label or f'{fg} on {bg}'}")
        return 1 if failures else 0
    if len(args) != 2:
        print("give exactly two hex colors, or --pairs <file>", file=sys.stderr)
        return 2
    r = ratio(args[0], args[1])
    print(f"{r:.2f}:1  {verdict(r)}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
