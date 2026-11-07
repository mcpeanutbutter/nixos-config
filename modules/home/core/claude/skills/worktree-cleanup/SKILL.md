---
name: worktree-cleanup
description: Remove git worktrees (and their branches) whose work is already merged into origin's default branch. Run after the user has fetched.
disable-model-invocation: true
---

# Worktree cleanup

Remove merged worktrees of the current repo, with the user's confirmation. Everything here is local: never fetch, pull or push.

## 1. Fetch first (the user's job)

Merge detection reads `origin/<default>`, which is only as fresh as the user's last fetch. Unless the invocation says they just fetched, give them this block and stop:

```
git -C <primary worktree> fetch --prune
```

## 2. Gather

- Primary worktree: first entry of `git worktree list --porcelain`.
- Default branch: `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/`). If unset, ask.
- Per worktree: `git worktree list --porcelain` (branch, `detached`, `locked`, `prunable`) and `wt list --format=json` (`working_tree`, `main_state`).

## 3. Classify each non-primary worktree

- **Merged:** `git merge-base --is-ancestor <branch> origin/<default>`, or `git cherry origin/<default> <branch>` prints only `-` lines (squash/rebase merges). An upstream shown as `[gone]` in `git branch -vv` is a hint, not proof: closed, unmerged MRs delete branches too.
- **Dirty:** uncommitted or untracked changes, including submodules (`git -C <wt> status --porcelain`). Never removed; report what's there.
- **Detached / prunable / locked:** usually leftovers from scratch work. List separately with their HEAD and age.
- **This session's worktree:** skip.
- Everything else: **unmerged**, keep.

## 4. Confirm

Show one table (path, branch, class, last commit date) and ask which to remove (AskUserQuestion, multi-select). Offer merged + clean ones first.

## 5. Remove

- Merged: `wt remove --foreground <branch>`. If `wt` kept the branch (its merge check uses the local default branch, which may lag `origin/<default>`), re-run the step 3 check and then `git branch -D <branch>`.
- Detached / prunable: `git worktree remove <path>` (`git worktree unlock` first if locked and confirmed), then `git worktree prune`.
- Afterwards show `COLUMNS=120 wt list`.

## 6. Optionally: merged branches without a worktree

Same merged check over `git for-each-ref refs/heads`, excluding the default branch and branches checked out anywhere. List them, confirm, `git branch -D`.

## Never

Fetch or push; remove a dirty worktree or use `--force`; touch the primary worktree; move or reset the local default branch.
