{
  flake.modules.homeManager.base.imports = [
    (
      { pkgs, lib, ... }:
      {
        programs.ghostty = {
          enable = true;
          package = pkgs.ghostty;
          systemd.enable = true;
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
          };
          # Stylix's ghostty target hard-codes selection-background/foreground
          # in themes.stylix, which makes selection-invert-fg-bg a no-op.
          # Override those two leaves with ghostty's cell-foreground / cell-background
          # keywords to invert per cell instead.
          themes.stylix = {
            selection-background = lib.mkForce "cell-foreground";
            selection-foreground = lib.mkForce "cell-background";
          };
        };
      }
    )
  ];
}
