{ pkgs, ... }:
{
  # Enable fuzzel so stylix can theme it automatically
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        # Set terminal for terminal applications like btop
        terminal = "${pkgs.ghostty}/bin/ghostty -e";

        # Display settings
        show-actions = true;
        dpi-aware = "no"; # Disable automatic DPI scaling to ensure consistent font size

        # Window appearance
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
