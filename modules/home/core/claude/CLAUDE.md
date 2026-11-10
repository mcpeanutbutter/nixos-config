# Global CLAUDE.md

`~/.claude/CLAUDE.md` is an out-of-store symlink (home-manager `mkOutOfStoreSymlink`) to `~/nixos-config/modules/home/core/claude/CLAUDE.md`. It is writable: edit it directly, changes apply immediately without a rebuild, and they show up in that repo's git status. That repo is public: keep this file (and the skills next to it) free of employer, host, repo and internal-tool names.

## Shell

- **Commands for me to paste:** my terminal splits long pasted lines mid-token. Break every long command into short lines with generous `\` continuations. No helper variables, no `#` comments (zsh `interactive_comments` is off): explanations go in prose outside the code block.
- **Logic goes into a script file, not into the command line:** loops, variables, `$(…)`, and heredocs or `-c` code for an interpreter go into a file in the scratchpad, run as `bash <file>` or `python3 <file>`. Edit files with Edit/Write, not with an inline script. This keeps commands short and readable, and Claude Code's worktree check refuses complex commands. When such a script changes something (an API write, a file edit), say in a sentence what it does.
- **Forge CLIs** (`glab`, `gh`) take the host from the repo's remote: inside a repo, don't pass `--hostname`.
- **Your own Bash tool runs zsh, not bash:**
  - zsh does not word-split unquoted variables: with `files=$(git ls-files)`, `for f in $files` runs once with the whole multi-line string. Loop over lines with `while IFS= read -r f; do …; done < <(cmd)`, or use `${(f)files}`; for anything bigger, write a script file (`bash script.sh` or `python3`).
  - The same goes for a variable holding several arguments: in `for a in "x light" "y dark"; do cmd $a; done`, `cmd` gets the single argument `x light` and every later argument shifts. Split with `${=a}`, or use an array (`args=(x light); cmd "${args[@]}"`).
  - Quote globs in arguments (`--include='*.nix'`), otherwise "no matches found". A glob that may match nothing (`rm -f dir/*` on an empty dir) fails the same way and aborts an `&&` chain. Glob qualifiers like `(N)` are off (`nobareglobqual`): use `find dir -mindepth 1 -delete`, or `(setopt nullglob; rm -f dir/*)`.
  - Don't start a word with `=` (`echo ===` fails; use `echo ---`).
- **Missing tool?** Any nixpkgs package is one command away: `nix shell nixpkgs#<pkg> --command <cmd> …` (e.g. `nix shell nixpkgs#unzip --command unzip …`). Don't work around a missing tool or ask me to install it.

## Git remotes are mine

- Unless a project's CLAUDE.md or a memory grants an exception, never fetch, pull, push or otherwise contact a git remote. SSH has no agent on purpose: the passphrase prompt is what keeps you off the remotes. That includes `wt` features that reach out (`wt switch pr:N`/`mr:N`, `wt list --full`, `wt config show --full`).
- Hand remote steps to me as commands with absolute paths (`git -C <path> push -u origin <branch>`), formatted as under **Shell**.
- Remote-tracking refs are as fresh as my last fetch; say so when it matters.
- **They also move under you:** `origin/<default>` may have advanced since you rebased, so it is not necessarily the branch's base. Squash onto `git merge-base HEAD origin/<default>`, never `reset --soft origin/<default>` (that keeps the old tree and silently reverts the default branch's newer commits). After any squash or history rewrite, `git diff --stat origin/<default> HEAD` must list only the branch's own files.

## Worktrees (`wt`, worktrunk)

- **Model:** the main checkout stays on the default branch. Everything else happens in worktrees: new feature work, continuing a feature, and looking something up on another branch. Read-only work on the default branch and repos that commit straight to the default branch use the main checkout. If the main checkout isn't clean on the default branch, tell me; don't fix it.
- **Look first:** `wt list --format=json` (local only; plain `wt list` needs a TTY, else `COLUMNS=120 wt list`). Reuse an existing worktree for the same branch, issue or topic.
- **Create:** new branch: `wt switch --create <branch> --base origin/<default> --no-cd`. Existing branch: `wt switch <branch> --no-cd`. Create without asking; tell me the branch and path. The worktree lands at `../<repo>.<branch>`. If `wt` wants to ask the remote for the default branch, set it locally instead: `wt config state default-branch set <name>`.
- **Branch names:** follow the repo's convention (e.g. `<issue>-<slug>`). If the issue doesn't exist yet, start with `<slug>`. Once it does, rename the branch (`git branch -m`) or push to the issue-numbered name (`<slug>:<issue>-<slug>`); don't create another worktree for it.
- **Enter:** `EnterWorktree` with the worktree's absolute path, so every tool works there and the main checkout stays untouched. `wt switch` can't change your shell's directory. Once inside, `git -C <main checkout>` is refused; use the shared refs (`git log/diff/show <default>…`), absolute-path reads, and `wt list --format=json` for the main checkout's state.
- **Submodules** are initialised from the main checkout's local clones by a `wt` pre-start hook, without network. If it fails it prints a command (the worktree still exists): hand that to me. Never `git -C` into an uninitialised submodule directory; it resolves to the superproject, and config writes there land in the `.git/config` shared by every worktree.
- **Setup:** a fresh worktree has no gitignored files (`.env`, dependencies, build output). Run tooling through the repo's flake dev shell (`nix develop --command …`), not direnv. Follow the repo's CLAUDE.md for anything else; ask if it doesn't say.
- **Lookups in other repos** are read-only and written as literal commands: `git -C /abs/path …`, one per call, no `$(…)`, variables or relative `-C`, which the isolation guard refuses. On the repo's current branch, read files directly. On another branch, use `git -C <repo> show <ref>:<path>`, `log` and `diff` for a few files. For anything broader, add a detached worktree in your own temp/scratchpad directory, never under my projects dir (`git -C <repo> worktree add --detach <scratch>/<repo>-<branch> <ref>`), and `git -C <repo> worktree remove <path>` when done. Never switch branches in my checkouts for a lookup.
- **Shared state:** ports, compose stacks and databases are shared between worktrees. Don't start a second stack without asking.
- **Parallel subagents:** one `wt switch --create … --no-cd` per agent, absolute path in its prompt. Don't use `isolation: "worktree"`.
- **Never:** check out, stash or reset in the main checkout; move the local default branch; `wt merge` (merges happen on the forge); `wt remove --force`/`-D`; `--yes` past a hook approval prompt.
- **Finish:** commit in the worktree, give me the push commands, keep the worktree through review. Merged worktrees are removed with `/worktree-cleanup` after I've fetched.
