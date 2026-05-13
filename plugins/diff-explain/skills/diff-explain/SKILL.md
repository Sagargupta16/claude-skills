---
name: diff-explain
description: Use when you want a one-paragraph plain-English summary of what a diff does. Activates on "summarize this diff", "what does this PR do", "explain this branch", or when pointed at a PR URL or local branch.
allowed-tools: Bash(git diff:*) Bash(gh pr diff:*) Bash(gh pr view:*) Bash(git log:*)
---

# diff-explain

## Live context (when diffing a local branch)

- Current branch diff stat: !`git diff $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo HEAD)...HEAD --stat 2>/dev/null || echo "no local diff vs main"`

## When to activate

- User pastes a diff and asks "what does this do?" / "summarize" / "explain".
- User shares a PR link or branch name and wants a quick read before reviewing.
- Reviewing unfamiliar changes before merge.

Do NOT activate when the user is asking for a detailed line-by-line review -- that's a different task.

## Steps

1. **Get the diff.**
   - PR link: `gh pr diff <url-or-number>`
   - Local branch: `git diff <base>...HEAD` (default base: `main` or `master`)
   - Pasted: use what the user pasted.
2. **Read it fully.** Don't skim the first 50 lines and guess.
3. **Group by concern.** Even if the diff touches many files, most diffs have 1-3 concerns (a bug fix, a rename, a new feature). Name each concern in plain language.
4. **Write ONE paragraph.** 3-5 sentences covering:
   - What changed (the concern, not the files).
   - Why it likely changed (if the commit message / PR title / linked issue says).
   - What risk it introduces (behavior change, API change, DB migration, dependency bump).
5. **Optional risk line.** If one specific thing deserves attention before merge, append one line starting with `Watch out for:`.

## Rules

- No file-by-file walk. Group by concern, not by path.
- No bullet lists. Prose only.
- If the diff is large (>500 lines), say so in the first sentence and narrow to the top 2-3 concerns instead of trying to cover everything.
- Don't speculate about business motivation beyond what commits, PR title, or linked issue state.
- **Flag real problems.** Suspected bugs, security issues, missing tests, or breaking API changes go in the summary or in the "Watch out for" line. Don't paper over them.

## Output

One paragraph. Optional single-line `Watch out for: ...` trailer.

No preamble ("Here's a summary of..."). Lead with the answer.
