# motion

One animation skill, three modes. Pick by intent; only the matching reference file loads.

| Mode | When | What you get |
|------|------|--------------|
| `audit` | Review existing animation code | `file:line` findings against Disney's 12 principles |
| `add` | Enhance a feature with motion | Purposeful animations and micro-interactions |
| `fix` | Animations stutter or jank | Compositor-only properties, layout-thrash fixes |

## Install

```
/plugin install motion@sagar-dev-skills
```

## Usage

```
/motion audit src/components/
/motion add hero section
/motion fix Navbar.css
```

If no mode is given, the skill infers it: review/check -> audit, add/enhance -> add, jank/slow/stutter -> fix.

## Hard rules (all modes)

- transform + opacity only; never animate layout properties
- `will-change` sparingly and temporarily
- Never migrate animation libraries unless asked
- Respects the project's stated motion policy (bold-and-visible vs accessibility-first)

## Credits

Audit rules adapted from raphael-salaja's 12-principles-of-animation (v2.0.0); add mode adapted from pbakaus/impeccable animate (v2.1.1). MIT.
