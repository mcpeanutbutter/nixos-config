{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    shellAliases = {
      nfu = "nix flake update";
    };
    initExtra = ''
      nrs() { sudo nixos-rebuild switch --flake ~/nixos-config#"$(hostname)" "$@"; }
    '';
  };
}
