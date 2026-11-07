# PermissionRequest hook for EnterWorktree: approve entering a path only if it
# is a registered worktree of the repo the session is in. Anything else falls
# through to the normal permission prompt (no output = no decision).

input=$(cat)
path=$(jq -r '.tool_input.path // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
[ -n "$path" ] && [ -n "$cwd" ] || exit 0

case "$path" in
  /*) ;;
  *) path="$cwd/$path" ;;
esac
target=$(realpath -e -- "$path" 2>/dev/null) || exit 0

while IFS= read -r line; do
  case "$line" in
    "worktree "*)
      wt=$(realpath -e -- "${line#worktree }" 2>/dev/null) || continue
      if [ "$wt" = "$target" ]; then
        jq -n '{hookSpecificOutput: {hookEventName: "PermissionRequest", decision: {behavior: "allow"}}}'
        exit 0
      fi
      ;;
  esac
done < <(git -C "$cwd" worktree list --porcelain 2>/dev/null)

exit 0
