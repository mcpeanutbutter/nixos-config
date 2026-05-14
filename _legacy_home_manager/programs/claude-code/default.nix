{
  config,
  pkgs,
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

    format_commas() {
        printf "%'d" "$1"
    }

    build_bar() {
        local pct=$1
        local width=$2
        [ "$pct" -lt 0 ] 2>/dev/null && pct=0
        [ "$pct" -gt 100 ] 2>/dev/null && pct=100

        local filled=$(( pct * width / 100 ))
        local empty=$(( width - filled ))

        local bar_color
        if [ "$pct" -ge 90 ]; then bar_color="$red"
        elif [ "$pct" -ge 70 ]; then bar_color="$yellow"
        elif [ "$pct" -ge 50 ]; then bar_color="$orange"
        else bar_color="$green"
        fi

        local filled_str="" empty_str=""
        for ((i=0; i<filled; i++)); do filled_str+="●"; done
        for ((i=0; i<empty; i++)); do empty_str+="○"; done

        printf "''${bar_color}''${filled_str}''${dim}''${empty_str}''${reset}"
    }

    model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')

    size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
    [ "$size" -eq 0 ] 2>/dev/null && size=200000

    input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
    cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
    cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
    current=$(( input_tokens + cache_create + cache_read ))

    used_tokens=$(format_tokens $current)
    total_tokens=$(format_tokens $size)

    if [ "$size" -gt 0 ]; then
        pct_used=$(( current * 100 / size ))
    else
        pct_used=0
    fi
    pct_remain=$(( 100 - pct_used ))

    used_comma=$(format_commas $current)
    remain_comma=$(format_commas $(( size - current )))

    thinking_on=false
    settings_path="$HOME/.claude/settings.json"
    if [ -f "$settings_path" ]; then
        thinking_val=$(jq -r '.alwaysThinkingEnabled // false' "$settings_path" 2>/dev/null)
        [ "$thinking_val" = "true" ] && thinking_on=true
    fi

    out=""
    out+="''${blue}''${model_name}''${reset}"

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
    out+=" ''${dim}|''${reset} "
    out+="''${green}''${pct_used}%''${reset} ''${dim}used''${reset}"
    out+=" ''${dim}|''${reset} "
    out+="thinking: "
    if $thinking_on; then
        out+="''${orange}On''${reset}"
    else
        out+="''${dim}Off''${reset}"
    fi

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
        local style="$2"
        [ -z "$iso_str" ] || [ "$iso_str" = "null" ] && return

        local epoch
        epoch=$(iso_to_epoch "$iso_str")
        [ -z "$epoch" ] && return

        case "$style" in
            time)
                date -j -r "$epoch" +"%l:%M%p" 2>/dev/null | sed 's/^ //' | tr '[:upper:]' '[:lower:]' || \
                date -d "@$epoch" +"%l:%M%P" 2>/dev/null | sed 's/^ //'
                ;;
            datetime)
                date -j -r "$epoch" +"%b %-d, %l:%M%p" 2>/dev/null | sed 's/  / /g; s/^ //' | tr '[:upper:]' '[:lower:]' || \
                date -d "@$epoch" +"%b %-d, %l:%M%P" 2>/dev/null | sed 's/  / /g; s/^ //'
                ;;
            *)
                date -j -r "$epoch" +"%b %-d" 2>/dev/null | tr '[:upper:]' '[:lower:]' || \
                date -d "@$epoch" +"%b %-d" 2>/dev/null
                ;;
        esac
    }

    sep=" ''${dim}|''${reset} "

    if [ -n "$usage_data" ] && echo "$usage_data" | jq -e . >/dev/null 2>&1; then
        bar_width=6

        five_hour_pct=$(echo "$usage_data" | jq -r '.five_hour.utilization // 0' | awk '{printf "%.0f", $1}')
        five_hour_reset_iso=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty')
        five_hour_reset=$(format_reset_time "$five_hour_reset_iso" "time")
        five_hour_bar=$(build_bar "$five_hour_pct" "$bar_width")

        out+="''${sep}''${white}5h''${reset} ''${five_hour_bar} ''${cyan}''${five_hour_pct}%''${reset}"
        [ -n "$five_hour_reset" ] && out+=" ''${dim}@''${five_hour_reset}''${reset}"

        seven_day_pct=$(echo "$usage_data" | jq -r '.seven_day.utilization // 0' | awk '{printf "%.0f", $1}')
        seven_day_reset_iso=$(echo "$usage_data" | jq -r '.seven_day.resets_at // empty')
        seven_day_reset=$(format_reset_time "$seven_day_reset_iso" "datetime")
        seven_day_bar=$(build_bar "$seven_day_pct" "$bar_width")

        out+="''${sep}''${white}7d''${reset} ''${seven_day_bar} ''${cyan}''${seven_day_pct}%''${reset}"
        [ -n "$seven_day_reset" ] && out+=" ''${dim}@''${seven_day_reset}''${reset}"

        extra_enabled=$(echo "$usage_data" | jq -r '.extra_usage.is_enabled // false')
        if [ "$extra_enabled" = "true" ]; then
            extra_pct=$(echo "$usage_data" | jq -r '.extra_usage.utilization // 0' | awk '{printf "%.0f", $1}')
            extra_used=$(echo "$usage_data" | jq -r '.extra_usage.used_credits // 0' | awk '{printf "%.2f", $1/100}')
            extra_limit=$(echo "$usage_data" | jq -r '.extra_usage.monthly_limit // 0' | awk '{printf "%.2f", $1/100}')
            extra_bar=$(build_bar "$extra_pct" "$bar_width")

            out+="''${sep}''${white}extra''${reset} ''${extra_bar} ''${cyan}\$''${extra_used}/\$''${extra_limit}''${reset}"
        fi
    fi

    printf "%b" "$out"

    exit 0
  '';
in
{
  home.file.".claude/skills/skill-creator" = {
    source = "${anthropics-skills}/skills/skill-creator";
    recursive = true;
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
    settings = {
      statusLine = {
        command = "${statuslineScript}";
        padding = 0;
        type = "command";
      };
    };
  };
}
