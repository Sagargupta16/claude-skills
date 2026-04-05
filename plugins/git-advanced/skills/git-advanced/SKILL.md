---
name: git-advanced
description: Use when performing complex git operations -- rebasing, cherry-picking, resolving merge conflicts, bisecting bugs, managing stashes, cleaning history, or working with monorepos. Goes beyond basic commit/push/pull.
---

# Advanced Git Patterns

## Quick Reference

| Task | Command |
|------|---------|
| Rebase onto main | `git rebase main` |
| Interactive rebase (squash) | `git rebase -i HEAD~N` |
| Cherry-pick a commit | `git cherry-pick <sha>` |
| Find bug introduction | `git bisect start` |
| Stash with name | `git stash push -m "description"` |
| Undo last commit (keep changes) | `git reset --soft HEAD~1` |
| See what changed in a file | `git log -p -- path/to/file` |
| Find who changed a line | `git blame path/to/file` |

## Rebase Workflows

### Rebase feature branch onto main

```bash
git checkout feature-branch
git fetch origin
git rebase origin/main
# Fix conflicts if any, then:
git push --force-with-lease  # safer than --force
```

Use `--force-with-lease` instead of `--force` -- it refuses to push if someone else has pushed to the branch since your last fetch.

### Interactive Rebase (clean up commits)

```bash
git rebase -i HEAD~5  # last 5 commits
```

In the editor:
```
pick abc1234 feat: add user model
squash def5678 fix typo in user model
squash ghi9012 more fixes
pick jkl3456 feat: add user routes
fixup mno7890 cleanup
```

| Command | Effect |
|---------|--------|
| `pick` | Keep commit as-is |
| `squash` | Merge into previous, combine messages |
| `fixup` | Merge into previous, discard message |
| `reword` | Keep commit, edit message |
| `drop` | Remove commit entirely |

### When to Rebase vs Merge

| Rebase | Merge |
|--------|-------|
| Your feature branch behind main | Integrating shared branches |
| Cleaning up local commits before PR | Preserving branch history matters |
| Linear history preferred | Multiple people on same branch |
| Your own branches only | Never on shared/public branches |

## Conflict Resolution

### Workflow

```bash
# During rebase or merge, conflicts show as:
<<<<<<< HEAD
current changes
=======
incoming changes
>>>>>>> branch-name

# After resolving each file:
git add resolved-file.py
git rebase --continue   # or git merge --continue
```

### Strategy

1. **Read both sides** -- understand what each change is trying to do
2. **Check the base** -- `git diff HEAD...branch` to see the original intent
3. **Keep both** when changes are in different logical sections
4. **Choose one** when changes are mutually exclusive
5. **Rewrite** when neither side is correct after the merge
6. **Run tests** after resolving before continuing

### Abort if stuck

```bash
git rebase --abort    # undo the entire rebase
git merge --abort     # undo the entire merge
```

## Cherry-Pick

Copy a specific commit to current branch:

```bash
git cherry-pick abc1234

# Cherry-pick without committing (stage changes only)
git cherry-pick --no-commit abc1234

# Cherry-pick a range
git cherry-pick abc1234..def5678
```

Use cases: hotfix from main to release branch, backport a fix.

## Git Bisect (find bug introduction)

```bash
git bisect start
git bisect bad                 # current commit is broken
git bisect good v1.0.0         # this tag/commit was working

# Git checks out a middle commit. Test it, then:
git bisect good                # this commit is fine
# or
git bisect bad                 # this commit has the bug

# Repeat until git identifies the first bad commit
git bisect reset               # return to original branch
```

Automate with a test script:
```bash
git bisect start HEAD v1.0.0
git bisect run pytest tests/test_broken.py
```

## Stash Management

```bash
# Stash with descriptive name
git stash push -m "WIP: auth refactor"

# List stashes
git stash list

# Apply most recent (keep in stash)
git stash apply

# Apply and remove from stash
git stash pop

# Apply specific stash
git stash apply stash@{2}

# Stash specific files only
git stash push -m "partial" -- file1.py file2.py

# Create branch from stash
git stash branch new-branch stash@{0}
```

## Undo Operations

| Want to Undo | Command | Destructive? |
|-------------|---------|-------------|
| Last commit (keep changes staged) | `git reset --soft HEAD~1` | No |
| Last commit (keep changes unstaged) | `git reset HEAD~1` | No |
| Last commit (discard changes) | `git reset --hard HEAD~1` | YES |
| Staged file | `git restore --staged file` | No |
| Unstaged changes to a file | `git restore file` | YES |
| A pushed commit | `git revert <sha>` | No (creates new commit) |
| A bad rebase | `git reflog` then `git reset --hard <sha>` | Recoverable |

**Always prefer `git revert` over `git reset` for pushed commits.** Revert creates a new commit that undoes the change, preserving history.

## Reflog (emergency recovery)

```bash
# See recent HEAD movements
git reflog

# Output:
# abc1234 HEAD@{0}: rebase: finish
# def5678 HEAD@{1}: rebase: start
# ghi9012 HEAD@{2}: commit: my important work

# Recover lost commit
git reset --hard ghi9012
```

The reflog keeps ~90 days of history. If you lost something, it's probably here.

## History Exploration

```bash
# Commits that changed a specific file
git log --oneline -- path/to/file

# Search commit messages
git log --grep="fix login"

# Search code changes (pickaxe)
git log -S "functionName" --oneline

# Who last changed each line
git blame path/to/file

# Show blame ignoring whitespace and moves
git blame -w -M path/to/file

# Diff between branches
git diff main...feature-branch
```

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| `git push --force` on shared branches | `git push --force-with-lease` on your own branches only |
| Rebase public/shared branches | Only rebase your own feature branches |
| Resolve conflicts by accepting "ours" blindly | Read both sides and merge intentionally |
| Stash and forget | Name stashes, clean up regularly with `git stash drop` |
| `git reset --hard` without checking reflog | Use `--soft` first, escalate to `--hard` only when sure |
| Giant squash of entire branch | Squash related commits, keep logical units separate |
