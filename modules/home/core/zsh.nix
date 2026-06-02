{
  flake.modules.homeManager.base.programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    shellAliases = {
      nfu = "nix flake update";
    };

    initContent = ''
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word

      autoload -Uz add-zsh-hook
      _onefetch_last_root=""
      _onefetch_chpwd() {
        local root
        root="$(git rev-parse --show-toplevel 2>/dev/null)" || { _onefetch_last_root=""; return; }
        [[ "$root" == "$_onefetch_last_root" ]] && return
        _onefetch_last_root="$root"
        onefetch 2>/dev/null
      }
      add-zsh-hook chpwd _onefetch_chpwd

      nrs() {
        local host="$(hostname)"
        local newSys
        newSys="$(nix build --no-link --print-out-paths "$HOME/nixos-config#nixosConfigurations.$host.config.system.build.toplevel")" || return
        local cmd=switch
        if [ "$(readlink -f "$newSys/kernel")" != "$(readlink -f /run/booted-system/kernel)" ]; then
          cmd=boot
          echo "kernel changed; using 'boot' — reboot to activate"
        fi
        sudo nixos-rebuild "$cmd" --flake ~/nixos-config#"$host" "$@"
      }
      workdir() {
        if [ -z "$1" ]; then
          echo "Usage: workdir <title>" >&2
          return 1
        fi
        local dir=~/data/work/"$(date +%Y%m%d) $*"
        mkdir -p "$dir"
        cd "$dir"
      }
    '';
  };
}
