{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;
    installBatSyntax = true;
    settings = {
      command = "zsh";
      window-padding-x = 16;
      window-padding-y = 16;
      window-decoration = "auto";
      window-save-state = "never";
      clipboard-read = "allow";
      clipboard-write = "allow";
      shell-integration = "zsh";
      background-opacity = 0.9;
    };
  };
}
