# Global CLAUDE.md

`~/.claude/CLAUDE.md` is an out-of-store symlink (home-manager `mkOutOfStoreSymlink`) to `~/nixos-config/modules/home/core/claude/CLAUDE.md`. It is writable: edit it directly, changes apply immediately without a rebuild, and they show up in that repo's git status. That repo is public: keep this file (and the skills next to it) free of employer, host, repo and internal-tool names.

## Shell

- **Commands for me to paste:** my terminal splits long pasted lines mid-token. Break every long command into short lines with generous `\` continuations. No helper variables, no `#` comments (zsh `interactive_comments` is off): explanations go in prose outside the code block.
- **Your own Bash tool runs zsh, not bash:**
  - zsh does not word-split unquoted variables: with `files=$(git ls-files)`, `for f in $files` runs once with the whole multi-line string. Loop over lines with `while IFS= read -r f; do …; done < <(cmd)`, or use `${(f)files}`; for anything bigger, write a script file (`bash script.sh` or `python3`).
  - Quote globs in arguments (`--include='*.nix'`), otherwise "no matches found".
  - Don't start a word with `=` (`echo ===` fails; use `echo ---`).
- **Missing tool?** Any nixpkgs package is one command away: `nix shell nixpkgs#<pkg> --command <cmd> …` (e.g. `nix shell nixpkgs#unzip --command unzip …`). Don't work around a missing tool or ask me to install it.

## Git remotes are mine

- Unless a project's CLAUDE.md or a memory grants an exception, never fetch, pull, push or otherwise contact a git remote. SSH has no agent on purpose: the passphrase prompt is what keeps you off the remotes. That includes `wt` features that reach out (`wt switch pr:N`/`mr:N`, `wt list --full`, `wt config show --full`).
- Hand remote steps to me as commands with absolute paths (`git -C <path> push -u origin <branch>`), formatted as under **Shell**.
- Remote-tracking refs are as fresh as my last fetch; say so when it matters.

## Worktrees (`wt`, worktrunk)

- **Model:** the main checkout stays on the default branch. Everything else happens in worktrees: new feature work, continuing a feature, and looking something up on another branch. Read-only work on the default branch and repos that commit straight to the default branch use the main checkout. If the main checkout isn't clean on the default branch, tell me; don't fix it.
- **Look first:** `wt list --format=json` (local only; plain `wt list` needs a TTY, else `COLUMNS=120 wt list`). Reuse an existing worktree for the same branch, issue or topic.
- **Create:** new branch: `wt switch --create <branch> --base origin/<default> --no-cd`. Existing branch: `wt switch <branch> --no-cd`. Create without asking; tell me the branch and path. The worktree lands at `../<repo>.<branch>`. If `wt` wants to ask the remote for the default branch, set it locally instead: `wt config state default-branch set <name>`.
- **Branch names:** follow the repo's convention (e.g. `<issue>-<slug>`). If the issue doesn't exist yet, start with `<slug>`. Once it does, rename the branch (`git branch -m`) or push to the issue-numbered name (`<slug>:<issue>-<slug>`); don't create another worktree for it.
- **Enter:** `EnterWorktree` with the worktree's absolute path, so every tool works there and the main checkout stays untouched. `wt switch` can't change your shell's directory.
- **Submodules** are initialised from the main checkout's local clones by a `wt` pre-start hook, without network. If it fails it prints a command (the worktree still exists): hand that to me. Never `git -C` into an uninitialised submodule directory; it resolves to the superproject, and config writes there land in the `.git/config` shared by every worktree.
- **Setup:** a fresh worktree has no gitignored files (`.env`, dependencies, build output). Run tooling through the repo's flake dev shell (`nix develop --command …`), not direnv. Follow the repo's CLAUDE.md for anything else; ask if it doesn't say.
- **Shared state:** ports, compose stacks and databases are shared between worktrees. Don't start a second stack without asking.
- **Parallel subagents:** one `wt switch --create … --no-cd` per agent, absolute path in its prompt. Don't use `isolation: "worktree"`.
- **Never:** check out, stash or reset in the main checkout; move the local default branch; `wt merge` (merges happen on the forge); `wt remove --force`/`-D`; `--yes` past a hook approval prompt.
- **Finish:** commit in the worktree, give me the push commands, keep the worktree through review. Merged worktrees are removed with `/worktree-cleanup` after I've fetched.
