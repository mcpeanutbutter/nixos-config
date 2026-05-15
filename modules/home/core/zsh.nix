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

      nrs() { sudo nixos-rebuild switch --flake ~/nixos-config#"$(hostname)" "$@"; }
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
