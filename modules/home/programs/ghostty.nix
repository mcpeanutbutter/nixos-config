{
  flake.modules.homeManager.base.imports = [
    (
      {
        pkgs,
        lib,
        config,
        ...
      }:
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
            # Absolute px, not a percentage: the bar thickness derives from the
            # font's sub-pixel underline metric, so a percentage bump rounds away.
            adjust-cursor-thickness = 5;
          };
          # Stylix's ghostty target hard-codes selection-background/foreground
          # in themes.stylix, which makes selection-invert-fg-bg a no-op.
          # Override those two leaves with ghostty's cell-foreground / cell-background
          # keywords to invert per cell instead.
          themes.stylix = {
            selection-background = lib.mkForce "cell-foreground";
            selection-foreground = lib.mkForce "cell-background";
            # Stylix defaults the cursor to base05, i.e. the same colour as the
            # text it sits next to. Accent it instead.
            cursor-color = lib.mkForce "#${config.lib.stylix.colors.base0A}";
          };
        };
      }
    )
  ];
}
