# Hook demo

The terminal animation at the top of the [README](../../README.md#tested-guardrail-hooks) is generated, not recorded by hand.

| File | What it is |
| --- | --- |
| [`hooks-demo.json`](hooks-demo.json) | Transcript from [`scripts/demo.sh --json`](../../scripts/demo.sh): four commands, what the hooks printed, the exit code they returned |
| `hooks-demo-dark.svg`, `hooks-demo-light.svg` | That transcript rendered by svg-forge's `typing` kind, one per GitHub theme |

`scripts/demo.sh` builds a throwaway git repo, stages a fake Anthropic key on a feature branch, and pipes each command into the real `dev-rules` and `git-advanced` hooks the way Claude Code does. CI runs it on every pull request and fails if the output no longer matches `hooks-demo.json`, so the README cannot drift from what the hooks actually do.

## Regenerate

After changing a hook's messages, refresh the transcript and the two SVGs. Rendering needs a checkout of [svg-forge](https://github.com/Sagargupta16/svg-forge) and Python 3.12+.

```bash
bash scripts/demo.sh --json >docs/demo/hooks-demo.json
python ../svg-forge/skills/animated-svg/scripts/forge.py --kind typing --theme both --width 720 \
  --data docs/demo/hooks-demo.json --out docs/demo/hooks-demo.svg
python ../svg-forge/skills/animated-svg/scripts/validate_svg.py docs/demo/hooks-demo-*.svg --strict-contrast
```

`--theme both` writes the `-dark` and `-light` pair. `--width 720` fits the longest hook message, which the default 640 px canvas truncates; the README shows it at 100% width, so it scales down on a phone.
