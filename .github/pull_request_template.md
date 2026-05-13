<!--
Thanks for contributing to the sagar-dev-skills marketplace.
Please fill in the sections below. Delete any that do not apply.
-->

## Summary

<!-- 1-3 sentences: what this PR changes and why. -->

## Change type

- [ ] New plugin
- [ ] New skill / command / agent / hook in existing plugin
- [ ] Enhancement to existing content
- [ ] Bug fix (stale doc, broken example, validator failure)
- [ ] Docs only (README, CHANGELOG, CONTRIBUTING, reference.yaml)
- [ ] CI / tooling

## Checklist

- [ ] One plugin per PR (per [CONTRIBUTING.md](../CONTRIBUTING.md))
- [ ] Ran `bash scripts/validate-plugins.sh` locally and it passes
- [ ] `marketplace.json` updated if a plugin was added or version-bumped
- [ ] `README.md` plugin table updated if adding/removing a plugin
- [ ] `reference.yaml` stats and index updated if component counts changed
- [ ] `CHANGELOG.md` entry added under the target version
- [ ] Conventional commit message (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`)
- [ ] No hardcoded usernames, absolute paths, or internal URLs in skill content
- [ ] No secrets or tokens anywhere in the diff

## Version bump

<!-- If this PR changes behavior or adds a plugin, note the intended version bump. -->
<!-- Remove if docs-only. -->

- [ ] Patch (`x.y.Z`) -- doc fixes, typos, validator updates
- [ ] Minor (`x.Y.0`) -- new plugin, new capability, enhancement
- [ ] Major (`X.0.0`) -- breaking change (plugin removal, renamed field, incompatible CLI change)

## Test plan

<!-- How did you verify this works? Screenshots, validator output, manual install+invoke steps. -->

- [ ] `bash scripts/validate-plugins.sh`
- [ ] Installed locally via `/plugin marketplace add .` and confirmed new skill/command/agent/hook triggers
- [ ] <additional verification if applicable>

## Related

<!-- Closes #nn or relates to #nn. Delete if none. -->
