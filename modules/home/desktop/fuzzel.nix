{
  flake.modules.homeManager.base.imports = [
    (
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        programs.fuzzel = {
          enable = true;
          settings = {
            main = {
              terminal = "${pkgs.ghostty}/bin/ghostty +new-window -e";
              show-actions = true;
              dpi-aware = "no";
              keyboard-focus = "on-demand";
              icon-theme = "Hatter-kde-dark";
              # Override stylix-set font with a larger size for readability.
              font = lib.mkForce "monospace:size=20";
              image-size-ratio = 0.5;
              line-height = 35;
              width = 50;
              lines = 15;
            };
            border = {
              width = 2;
              radius = 8;
            };
            # Semi-transparent background so niri's blur shows through.
            colors.background = lib.mkForce "${config.lib.stylix.colors.base00}e6";
          };
        };
      }
    )
  ];
}
