---
name: motion
description: Use when reviewing motion quality, adding animation, transitions, hover effects, making the UI feel more alive, or when animations stutter and transitions jank. Covers three modes -- audit motion code against Disney's 12 principles (file:line findings), add purposeful animations and micro-interactions to a feature, or fix animation performance (layout thrashing, compositor properties, scroll-linked motion, blur).
version: 2.1.1
user-invocable: true
argument-hint: "[audit|add|fix] [target]"
license: MIT
metadata:
  authors: raphael-salaja (audit rules, 12-principles-of-animation v2.0.0), pbakaus/impeccable (add mode, animate v2.1.1)
---

# Motion

One skill, three modes. Pick by intent; load only the matching reference file.

| Mode | When | Reference |
|------|------|-----------|
| `audit` | Review existing animation code for quality -- outputs `file:line` findings against the 12 principles | [references/audit-12-principles.md](references/audit-12-principles.md) |
| `add` | Enhance a feature with new animations, micro-interactions, motion design | [references/add-motion.md](references/add-motion.md) |
| `fix` | Animations stutter, transitions jank, perf review of CSS/JS motion | [references/fix-performance.md](references/fix-performance.md) |

Invocation: `/motion audit <files>`, `/motion add [target]`, `/motion fix [file]`. Bare `/motion fix` applies the performance constraints to all UI animation work in this conversation. If no mode is given, infer from the ask (review/check -> audit; add/enhance -> add; jank/slow/stutter -> fix).

## Mode boundaries (the numbers differ by design)

Each mode's numeric rules apply only within that mode -- they intentionally disagree:

- **Stagger**: audit enforces <=50ms per item on existing code; add recommends 100-150ms delays for page-load choreography. When adding motion that must later pass an audit, prefer the audit cap.
- **Feedback duration**: audit fails user-initiated animations over 300ms; add allows 300-500ms for layout changes. Audit numbers win for interaction feedback.
- **Springs vs easing**: audit prescribes springs for overshoot-and-settle; add bans bounce/elastic easing curves. Both are right: springs yes, bounce/elastic cubic-beziers no.

## Hard rules (all modes)

- transform + opacity only for motion; never animate layout properties (width, height, top, left)
- `will-change` sparingly and temporarily, never permanent
- Never migrate or rewrite animation libraries unless explicitly requested
- Respect the project's stated motion policy: if the user or project rules say animations should stay bold and visible, do not add `prefers-reduced-motion` guards or tone motion down; if they require accessibility-first motion, do the opposite. Ask if no policy is stated and the change is significant.
