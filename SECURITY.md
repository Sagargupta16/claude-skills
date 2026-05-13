# Security Policy

## What this marketplace is

`sagar-dev-skills` is a content-only Claude Code plugin marketplace. It ships Markdown skill definitions, shell hook scripts, and JSON manifests. There is no runtime code, no server, and no network surface.

The realistic security concerns are:

1. **Hook scripts** run on your machine with your shell. A malicious hook could delete files, leak data, or execute arbitrary commands.
2. **Skill and command content** can instruct Claude to run shell commands. Prompt injection or a bad skill body could nudge Claude toward harmful actions.
3. **Plugin manifests** (`plugin.json`, `marketplace.json`) could declare unexpected components if the repo is compromised.

## Reporting a vulnerability

If you find a security issue, **do not open a public Issue or PR**. Instead:

- Email: **sg85207@gmail.com** with subject `[claude-skills security]`
- Include: what you found, how to reproduce, impact, and any suggested mitigation.

You should get a first response within 7 days. I'll work with you on a fix and coordinate a disclosure timeline.

## What counts as a vulnerability

In scope:

- A hook or skill that can be used to exfiltrate data, escalate privileges, or execute untrusted code.
- A prompt-injection pattern embedded in a skill body that reliably causes Claude to bypass user safety checks.
- A bug in `scripts/validate-plugins.sh` that can be exploited to hide a malicious plugin from validation.
- Secrets accidentally committed to the repo (API keys, tokens, private keys) -- please report privately so they can be rotated before a public PR.

Out of scope:

- A plugin you disagree with stylistically (use a PR or Discussion).
- A hook that is *powerful* but clearly documented (e.g., `secret-guard` uses regex that can be tuned).
- Vulnerabilities in Claude Code itself -- report those to Anthropic.

## What I will do

- Acknowledge within 7 days.
- If valid: fix the issue, publish a patch release, and credit you in the `CHANGELOG.md` (unless you prefer anonymity).
- If invalid: explain why and, where useful, point at the existing mitigation.

## Your responsibilities as a user

- Review hook scripts before enabling any plugin. Hooks run with your shell privileges.
- Pin the marketplace version in your `settings.json` if you need a stable install. Marketplace versions follow semver -- see [CONTRIBUTING.md](CONTRIBUTING.md#versioning).
- Keep your local `~/.claude/settings.json` permissions tight. Skills inside plugins cannot grant themselves tool access beyond what you allow.

## Coordinated disclosure

I prefer coordinated disclosure. Typical timeline once a valid report is received:

- Day 0: acknowledged.
- Day 0-14: fix developed.
- Day 14: patch released, advisory published.
- Day 14+: public Issue / PR references the CVE (if one was assigned).

If the issue is actively exploited in the wild, I'll accelerate that timeline.
