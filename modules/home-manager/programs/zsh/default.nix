{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };
    shellAliases = {
      nfu = "nix flake update";
    };
    initExtra = ''
      nrs() { sudo nixos-rebuild switch --flake ~/nixos-config#"$(hostname)" "$@"; }
    '';
  };
}
