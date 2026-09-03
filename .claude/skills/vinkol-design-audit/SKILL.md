---
name: vinkol-design-audit
description: Run the Phase 0 design audit on a Vinkol screen, flow or component — measure what is actually there before changing anything. Use when asked to audit, review, or assess a screen's design; before starting any redesign; or when someone asks "what's wrong with this screen". Produces evidence, not opinions.
---

# Vinkol Design Audit

Brief §0. The purpose is to know what exists before touching it. **Measure, never estimate.**
An audit that says "inconsistent spacing" without counts is worthless; one that says "seven
different vertical gaps between 6 and 30pt in one column" is actionable.

## Procedure

### 1. Read the target completely
The screen file, its view model, its widgets, and the widgets it borrows from `lib/widgets/`.
No skimming — an audit built on a skim produces findings that are already false.

### 2. Measure

```bash
F=lib/features/.../the_screen.dart
grep -oE "0x[fF][fF][0-9a-fA-F]{6}" $F | sort | uniq -c | sort -rn     # raw hex
grep -oE "Colors\.[a-zA-Z]+" $F | sort | uniq -c | sort -rn            # bare Material colors
grep -oE "BorderRadius.circular\([0-9.]+" $F | grep -oE "[0-9.]+" | sort -n | uniq -c
grep -oE "AppText\.[a-z0-9]+" $F | sort | uniq -c | sort -rn           # type styles in play
grep -oE "Gap\.[a-z0-9]+" $F | sort | uniq -c | sort -rn               # spacing values in play
grep -c "BoxShadow\|withOpacity\|\.sp\b\|₦" $F
wc -l $F
```

### 3. Classify every recurring pattern

**KEEP** (contributes to Vinkol identity) · **EVOLVE** (right idea, wrong execution) ·
**REMOVE** (generic, noisy, inaccessible or AI-looking) · **INTRODUCE** (missing and needed).

Check each candidate against `.claude/design/02-do-not-lose.md` before proposing REMOVE.

### 4. Answer the twenty-one questions (brief §5), briefly

Navigation · user journey · information architecture · UX inconsistency · visual inconsistency ·
typography · color · component consistency · interaction · accessibility · density · content
hierarchy · empty states · error states · loading states · trust · localization · where it
feels Nigeria-only · where it feels generic · where it feels AI-generated · what distinctive
Vinkol pattern this screen could carry.

Skip a heading with one line if it genuinely does not apply. Do not pad.

### 5. Answer the five hierarchy questions

Where am I? What is happening? What matters most? What can I do? What happens next?
A screen that cannot answer all five has an information-architecture problem, not a styling one.

### 6. Check the states that are missing
Loading, empty, error, offline, permission-denied, and — where money or delivery state is
involved — pending and failed. Most Vinkol screens have none of these. Name each missing one.

## Output

```markdown
## Audit: <screen> (<n> lines)

**Measured**
- <count> raw hex literals: <the values>
- <count> bare Colors.*: <the values>
- radii in use: <values>
- type styles in use: <values>   spacing values in use: <values>
- <count> BoxShadow · <count> withOpacity · <count> .sp · <count> ₦

**Hierarchy** — the five questions, answered or marked unanswerable.

**KEEP / EVOLVE / REMOVE / INTRODUCE** — one line each, with a file:line reference.

**Missing states** — the ones that do not exist.

**Verdict** — restyle in place, restructure, or decompose first (over ~400 lines: decompose).
```

Do not propose a visual direction here. Auditing and designing are separate steps, and mixing
them is how the measurement gets bent to fit the idea.
