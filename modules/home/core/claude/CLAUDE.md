# Global CLAUDE.md

`~/.claude/CLAUDE.md` is an out-of-store symlink (home-manager `mkOutOfStoreSymlink`) to `~/nixos-config/modules/home/core/claude/CLAUDE.md`. It is writable: edit it directly, changes apply immediately without a rebuild, and they show up in that repo's git status. That repo is public: keep this file (and the skills next to it) free of employer, host, repo and internal-tool names.

## Git remotes are mine

- Never fetch, pull, push or otherwise contact a git remote. SSH has no agent on purpose: the passphrase prompt is what keeps you off the remotes. That includes `wt` features that reach out (`wt switch pr:N`/`mr:N`, `wt list --full`, `wt config show --full`).
- Hand remote steps to me as one fenced block of commands with absolute paths (`git -C <path> push -u origin <branch>`) and no `#` comments (zsh `interactive_comments` is off).
- Remote-tracking refs are as fresh as my last fetch; say so when it matters.
- A project's CLAUDE.md may relax this for its repo.

## Worktrees (`wt`, worktrunk)

- **When:** any task that will commit on a new branch gets its own worktree, created without asking; tell me the branch and path. Not for read-only work, repos that commit straight to the default branch, or continuing on the branch I already have checked out.
- **Look first:** `wt list --format=json` (local only; plain `wt list` needs a TTY, else `COLUMNS=120 wt list`). If a worktree or branch for the same issue/topic exists, reuse it.
- **Create:** `wt switch --create <branch> --base origin/<default> --no-cd`, branch named by the repo's convention (e.g. `<issue>-<slug>`). The worktree lands at `../<repo>.<branch>`. If `wt` wants to ask the remote for the default branch, set it locally instead: `wt config state default-branch set <name>`.
- **Enter:** `EnterWorktree` with the worktree's absolute path, so every tool works there and the main checkout stays untouched. `wt switch` can't change your shell's directory.
- **Submodules** are initialised from the main checkout's local clones by a `wt` pre-start hook, without network. If it fails it prints a command (the worktree still exists): hand that to me. Never `git -C` into an uninitialised submodule directory; it resolves to the superproject, and config writes there land in the `.git/config` shared by every worktree.
- **Setup:** a fresh worktree has no gitignored files (`.env`, dependencies, build output) and no direnv trust. Follow the repo's CLAUDE.md; ask if it doesn't say.
- **Shared state:** ports, compose stacks and databases are shared between worktrees. Don't start a second stack without asking.
- **Parallel subagents:** one `wt switch --create … --no-cd` per agent, absolute path in its prompt. Don't use `isolation: "worktree"`.
- **Never:** check out, stash or reset in the main checkout; move the local default branch; `wt merge` (merges happen on the forge); `wt remove --force`/`-D`; `--yes` past a hook approval prompt.
- **Finish:** commit in the worktree, give me the push block, keep the worktree through review. Merged worktrees are removed with `/worktree-cleanup` after I've fetched.
