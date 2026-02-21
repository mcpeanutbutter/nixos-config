{ config, ... }:
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
      "my-nix-update" = "nix flake update --flake ${config.xdg.configHome}/home-manager";
      "my-nix-switch" = "home-manager switch --flake ${config.xdg.configHome}/home-manager";
    };
    initContent = ''
      my-openfortivpn() {
        sudo "$(which openfortivpn)" -c ${config.xdg.configHome}/openfortivpn/config "$@"
      }
    '';
  };
}
