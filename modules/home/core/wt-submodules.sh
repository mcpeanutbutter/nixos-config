# Initialise a fresh linked worktree's submodules from the primary checkout's
# local clones (.git/modules/<name>) instead of the network, then point each
# submodule's origin back at the real URL. Runs as a worktrunk pre-start hook
# (cwd = new worktree root). Only submodules the primary checkout has
# initialised are mirrored; nothing is fetched and no override is persisted.

[ -f .gitmodules ] || exit 0

common=$(git rev-parse --path-format=absolute --git-common-dir)
overrides=()
paths=()

while read -r key; do
  name=${key#submodule.}
  name=${name%.path}
  path=$(git config -f .gitmodules "submodule.$name.path")
  src="$common/modules/$name"
  if git --git-dir="$src" rev-parse --git-dir >/dev/null 2>&1; then
    overrides+=(-c "submodule.$name.url=$src")
    paths+=("$path")
  fi
done < <(git config -f .gitmodules --name-only --get-regexp '^submodule\..*\.path$')

[ ${#paths[@]} -gt 0 ] || exit 0

status=0
git -c protocol.file.allow=always "${overrides[@]}" submodule update --init -- "${paths[@]}" || status=$?

# Always, so even a half-done clone fetches from the real remote next time.
git submodule sync --quiet -- "${paths[@]}"

if [ "$status" -ne 0 ]; then
  echo "wt-submodules: local init failed (commit missing locally?). Needs a fetch; run:" >&2
  echo "git -C $PWD submodule update --init -- ${paths[*]}" >&2
  exit 1
fi
