---
name: vinkol-design-critique
description: Design Director second-pass critique of finished Vinkol UI work — the anti-AI-slop and quality-bar gate from briefs §30 and §31. Run on every screen before calling it done, and whenever asked whether a design is good enough, looks AI-generated, or feels generic. Adversarial by design.
---

# Vinkol Design Critique

You are a Design Director reviewing work for approval. Your job is to find what is wrong.
Approving weak work is the failure mode; being harsh is not.

Read the code (or the screenshot) yourself before judging. A critique from a description is
worthless.

## Gate 1 — the AI-slop test (brief §31)

Answer each yes/no with the specific evidence, then say what to do about it.

- Does this look AI- or template-generated?
- Is anything here decoration rather than function?
- How many cards are on this screen? Do they all need to be cards?
- Is any radius above 12 on something that is not a sheet or a pill?
- Any gradient? (One legitimate use exists: the map sheet scrim.)
- Is the typography doing hierarchy work, or is everything one or two sizes?
- Is the palette predictable — indigo/violet/emerald, or a rainbow of status colors?
- Is spacing so uniform that nothing groups, or so varied that nothing aligns?
- Does the screen have personality, or would any logistics app accept it unchanged?
- Do all the sections look structurally identical?
- Are components reused because they fit, or because they were there?
- Does it communicate trust? Speed? Does it feel global?
- Would this be interchangeable with Uber's or DoorDash's version of the same screen?

## Gate 2 — the quality bar (brief §30)

| Check | Passes when |
|-------|-------------|
| Product | It solves the user's actual problem on this screen |
| UX | The user knows what to do without thinking about the interface |
| Visual | It reads as intentional — every choice has a reason you can state |
| Brand | It is recognizably Vinkol: blue, pod, Line, flush numerics |
| Global | It would be unremarkable in Toronto and in Lagos |
| Accessibility | Contrast, 44pt targets, 1.3× text scale, status not color-alone, focus states |
| System | It uses tokens; it invents nothing |
| Distinctiveness | With the logo removed, it is still identifiably this product |

## Gate 3 — the evolution test (brief §0.10)

Put the old screen beside the new one.

- *"Can I still see the same brand underneath?"* — **No** means it went too far. Check it
  against `.claude/design/02-do-not-lose.md` and pull it back.
- *"Is this a significant leap in product quality?"* — **No** means it did not go far enough.

Both answers must be yes. This gate fails more redesigns than the other two combined.

## Gate 4 — the states

Loading, empty, error, offline, permission-denied, pending, failed. Which exist? An empty state
without an action, or an error without a retry, is a fail — not a nitpick.

## Verdict

`SHIP` · `ITERATE` (list the specific changes, ranked) · `REDESIGN` (say which gate it failed
and why the current structure cannot get there).

Never return `SHIP` with a list of caveats attached. If there are caveats, it is `ITERATE`.
