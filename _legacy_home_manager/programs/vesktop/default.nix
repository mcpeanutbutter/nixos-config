{ config, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  programs.vesktop = {
    enable = true;

    settings = {
      # Window management — let Niri handle decorations
      customTitleBar = false;
      staticTitle = true;
      disableMinSize = true;

      # Tray integration with Waybar
      tray = true;
      minimizeToTray = false;
      clickTrayToShowHide = true;

      # System integration
      checkUpdates = false;
      appBadge = false;
      enableTaskbarFlashing = false;
      arRPC = true;
      hardwareAcceleration = true;

      # Splash theming from Stylix
      splashTheming = true;
      splashBackground = "#${colors.base01}";
      splashColor = "#${colors.base0D}";

      # Branch
      discordBranch = "stable";
    };

    # Wider, always-visible scrollbars themed with Stylix colors
    vencord.settings = {
      useQuickCss = true;
      enabledThemes = [ "scrollbars.css" ];
    };

    vencord.themes.scrollbars = ''
      /* Wider, always-visible scrollbars — grey default, blue on hover */
      * {
        scrollbar-width: auto !important;
        scrollbar-color: #${colors.base03} transparent !important;
      }
      *:hover {
        scrollbar-color: #${colors.base0D} transparent !important;
      }
    '';
  };
}
