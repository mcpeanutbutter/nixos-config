{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    shellAliases = {
      nfu = "nix flake update";
    };
    initContent = ''
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
