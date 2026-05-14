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
            # mkForce overrides stylix's ghostty target (which sets
            # background-opacity = stylix.opacity.terminal, default 1.0).
            # Without mkForce, pkgs.formats.keyValue merges both as duplicate
            # keys and ghostty's last-wins parsing picks stylix's 1.0.
            background-opacity = lib.mkForce 0.95;
          };
        };
      }
    )
  ];
}
