{
  flake.modules.homeManager.base.imports = [
    (
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        colors = config.lib.stylix.colors;
        rgb =
          name:
          "\\033[38;2;${toString colors."${name}-rgb-r"};${toString colors."${name}-rgb-g"};${
            toString colors."${name}-rgb-b"
          }m";
        anthropics-skills = pkgs.fetchFromGitHub {
          owner = "anthropics";
          repo = "skills";
          rev = "7029232b9212482c0476da354b83364bd28fab2f";
          hash = "sha256-rQXOcZk0nF9ZqYK0CUelGoY4oj/gYZgcdh1qUdwvx2k=";
        };
        statuslineScript = pkgs.writeShellScript "claude-statusline" ''
          set -f

          export PATH="${
            pkgs.lib.makeBinPath [
              pkgs.jq
              pkgs.curl
              pkgs.git
              pkgs.gawk
              pkgs.coreutils
            ]
          }:$PATH"

          input=$(cat)

          if [ -z "$input" ]; then
              printf "Claude"
              exit 0
          fi

          # ANSI colors from Stylix base16 scheme
          blue='${rgb "base0D"}'
          orange='${rgb "base09"}'
          green='${rgb "base0B"}'
          cyan='${rgb "base0C"}'
          red='${rgb "base08"}'
          yellow='${rgb "base0A"}'
          white='${rgb "base05"}'
          dim='\033[2m'
          reset='\033[0m'

          format_tokens() {
              local num=$1
              if [ "$num" -ge 1000000 ]; then
                  awk "BEGIN {printf \"%.1fm\", $num / 1000000}"
              elif [ "$num" -ge 1000 ]; then
                  awk "BEGIN {printf \"%.0fk\", $num / 1000}"
              else
                  printf "%d" "$num"
              fi
          }

          pct_color() {
              local pct=$1
              if   [ "$pct" -ge 90 ]; then printf '%s' "$red"
              elif [ "$pct" -ge 70 ]; then printf '%s' "$yellow"
              elif [ "$pct" -ge 50 ]; then printf '%s' "$orange"
              else printf '%s' "$green"
              fi
          }

          model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
          # Only present for models that support effort levels (low|medium|high|xhigh|max).
          effort=$(echo "$input" | jq -r '.effort.level // empty')

          size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
          [ "$size" -eq 0 ] 2>/dev/null && size=200000

          input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
          cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
          cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
          current=$(( input_tokens + cache_create + cache_read ))

          used_tokens=$(format_tokens $current)
          total_tokens=$(format_tokens $size)

          out=""
          out+="''${blue}''${model_name}''${reset}"
          [ -n "$effort" ] && out+=" ''${dim}''${effort}''${reset}"

          cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
          if [ -n "$cwd" ]; then
              display_dir="''${cwd##*/}"
              git_branch=$(git -C "''${cwd}" rev-parse --abbrev-ref HEAD 2>/dev/null)
              out+=" ''${dim}|''${reset} "
              out+="''${cyan}''${display_dir}''${reset}"
              if [ -n "$git_branch" ]; then
                  out+="''${dim}@''${reset}''${green}''${git_branch}''${reset}"
              fi
          fi

          out+=" ''${dim}|''${reset} "
          out+="''${orange}''${used_tokens}/''${total_tokens}''${reset}"

          get_oauth_token() {
              local token=""

              if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
                  echo "$CLAUDE_CODE_OAUTH_TOKEN"
                  return 0
              fi

              if command -v security >/dev/null 2>&1; then
                  local blob
                  blob=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
                  if [ -n "$blob" ]; then
                      token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
                      if [ -n "$token" ] && [ "$token" != "null" ]; then
                          echo "$token"
                          return 0
                      fi
                  fi
              fi

              local creds_file="''${HOME}/.claude/.credentials.json"
              if [ -f "$creds_file" ]; then
                  token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_file" 2>/dev/null)
                  if [ -n "$token" ] && [ "$token" != "null" ]; then
                      echo "$token"
                      return 0
                  fi
              fi

              if command -v secret-tool >/dev/null 2>&1; then
                  local blob
                  blob=$(timeout 2 secret-tool lookup service "Claude Code-credentials" 2>/dev/null)
                  if [ -n "$blob" ]; then
                      token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
                      if [ -n "$token" ] && [ "$token" != "null" ]; then
                          echo "$token"
                          return 0
                      fi
                  fi
              fi

              echo ""
          }

          cache_file="/tmp/claude/statusline-usage-cache.json"
          cache_max_age=60
          mkdir -p /tmp/claude

          needs_refresh=true
          usage_data=""

          if [ -f "$cache_file" ]; then
              cache_mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
              now=$(date +%s)
              cache_age=$(( now - cache_mtime ))
              if [ "$cache_age" -lt "$cache_max_age" ]; then
                  needs_refresh=false
                  usage_data=$(cat "$cache_file" 2>/dev/null)
              fi
          fi

          if $needs_refresh; then
              token=$(get_oauth_token)
              if [ -n "$token" ] && [ "$token" != "null" ]; then
                  response=$(curl -s --max-time 10 \
                      -H "Accept: application/json" \
                      -H "Content-Type: application/json" \
                      -H "Authorization: Bearer $token" \
                      -H "anthropic-beta: oauth-2025-04-20" \
                      -H "User-Agent: claude-code/2.1.34" \
                      "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
                  if [ -n "$response" ] && echo "$response" | jq . >/dev/null 2>&1; then
                      usage_data="$response"
                      echo "$response" > "$cache_file"
                  fi
              fi
              if [ -z "$usage_data" ] && [ -f "$cache_file" ]; then
                  usage_data=$(cat "$cache_file" 2>/dev/null)
              fi
          fi

          iso_to_epoch() {
              local iso_str="$1"

              local epoch
              epoch=$(date -d "''${iso_str}" +%s 2>/dev/null)
              if [ -n "$epoch" ]; then
                  echo "$epoch"
                  return 0
              fi

              local stripped="''${iso_str%%.*}"
              stripped="''${stripped%%Z}"
              stripped="''${stripped%%+*}"
              stripped="''${stripped%%-[0-9][0-9]:[0-9][0-9]}"

              if [[ "$iso_str" == *"Z"* ]] || [[ "$iso_str" == *"+00:00"* ]] || [[ "$iso_str" == *"-00:00"* ]]; then
                  epoch=$(env TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
              else
                  epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
              fi

              if [ -n "$epoch" ]; then
                  echo "$epoch"
                  return 0
              fi

              return 1
          }

          format_reset_time() {
              local iso_str="$1"
              [ -z "$iso_str" ] || [ "$iso_str" = "null" ] && return

              local epoch
              epoch=$(iso_to_epoch "$iso_str")
              [ -z "$epoch" ] && return

              date -d "@$epoch" +"%l:%M%P" 2>/dev/null | sed 's/^ //' || \
              date -j -r "$epoch" +"%l:%M%p" 2>/dev/null | sed 's/^ //' | tr '[:upper:]' '[:lower:]'
          }

          sep=" ''${dim}|''${reset} "

          if [ -n "$usage_data" ] && echo "$usage_data" | jq -e . >/dev/null 2>&1; then
              five_hour_pct=$(echo "$usage_data" | jq -r '.five_hour.utilization // 0' | awk '{printf "%.0f", $1}')
              five_hour_reset_iso=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty')
              five_hour_reset=$(format_reset_time "$five_hour_reset_iso")

              out+="''${sep}''${white}5h''${reset} $(pct_color "$five_hour_pct")''${five_hour_pct}%''${reset}"
              [ -n "$five_hour_reset" ] && out+=" ''${dim}@''${five_hour_reset}''${reset}"

              # Weekly windows always reset on the same Sunday-night boundary, so no @reset.
              seven_day_pct=$(echo "$usage_data" | jq -r '.seven_day.utilization // 0' | awk '{printf "%.0f", $1}')
              out+="''${sep}''${white}7d all''${reset} $(pct_color "$seven_day_pct")''${seven_day_pct}%''${reset}"

              # Fable is metered against its own weekly limit, exposed only as a
              # model-scoped entry in .limits[] (the seven_day_* fields are all null).
              fable_pct=$(echo "$usage_data" | jq -r \
                  '[.limits[]? | select(.scope.model.display_name == "Fable") | .percent] | first // empty')
              if [ -n "$fable_pct" ]; then
                  fable_pct=$(echo "$fable_pct" | awk '{printf "%.0f", $1}')
                  out+="''${sep}''${white}7d fable''${reset} $(pct_color "$fable_pct")''${fable_pct}%''${reset}"
              fi

              extra_enabled=$(echo "$usage_data" | jq -r '.extra_usage.is_enabled // false')
              if [ "$extra_enabled" = "true" ]; then
                  extra_used=$(echo "$usage_data" | jq -r '.extra_usage.used_credits // 0' | awk '{printf "%.2f", $1/100}')
                  extra_limit=$(echo "$usage_data" | jq -r '.extra_usage.monthly_limit // 0' | awk '{printf "%.2f", $1/100}')

                  out+="''${sep}''${white}extra''${reset} ''${cyan}\$''${extra_used}/\$''${extra_limit}''${reset}"
              fi
          fi

          printf "%b" "$out"

          exit 0
        '';

        # Keys we manage declaratively. Merged into ~/.claude/settings.json at
        # activation time rather than symlinked, so Claude Code can still write
        # its own runtime prefs (effort, model, alwaysThinkingEnabled, …) to the
        # same file — a store symlink would make /effort fail with EROFS.
        managedSettings = (pkgs.formats.json { }).generate "claude-code-managed-settings.json" {
          statusLine = {
            command = "${statuslineScript}";
            padding = 0;
            type = "command";
          };
        };
      in
      {
        home.file.".claude/skills/skill-creator" = {
          source = "${anthropics-skills}/skills/skill-creator";
          recursive = true;
        };

        programs.claude-code = {
          enable = true;
          package = pkgs.claude-code;
          # settings intentionally unset — see managedSettings merge below.
        };

        home.activation.claudeCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          settings="$HOME/.claude/settings.json"
          run ${pkgs.coreutils}/bin/mkdir -p "$HOME/.claude"
          if [ -f "$settings" ]; then
            # Merge managed keys over the existing file; mv replaces a leftover
            # store symlink with a real, writable file on the first rebuild.
            tmp=$(${pkgs.coreutils}/bin/mktemp)
            run ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$settings" ${managedSettings} > "$tmp" \
              && run ${pkgs.coreutils}/bin/mv "$tmp" "$settings"
          else
            run ${pkgs.coreutils}/bin/install -m600 ${managedSettings} "$settings"
          fi
        '';
      }
    )
  ];
}
