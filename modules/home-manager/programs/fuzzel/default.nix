{ pkgs, lib, ... }:
{
  # Enable fuzzel so stylix can theme it automatically
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        # Set terminal for terminal applications like btop
        terminal = "${pkgs.ghostty}/bin/ghostty +new-window -e";

        # Display settings
        show-actions = true;
        dpi-aware = "no"; # Disable automatic DPI scaling to ensure consistent font size
        icon-theme = "Hatter-kde-dark";

        # Window appearance
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
    };
  };
}
