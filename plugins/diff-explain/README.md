# diff-explain

One-paragraph plain-English summary of what a diff does. Use when you want a fast read of a PR, a branch, or a pasted diff before you dig in.

## What it does

- Takes a diff (PR URL, branch, or pasted text) and returns a single paragraph describing **what changed, why, and what risk it introduces**.
- Groups changes by concern -- not by file path.
- Flags suspected bugs, security issues, missing tests, or breaking API changes.
- For diffs over 500 lines, it narrows to the top 2-3 concerns instead of trying to cover everything.

## When it activates

- "Summarize this PR"
- "What does this branch do?"
- "Explain this diff"
- User pastes a diff or shares a PR link.

## What it deliberately avoids

- No file-by-file walks.
- No bullet lists.
- No speculation about business motivation beyond what commits or PR titles say.
