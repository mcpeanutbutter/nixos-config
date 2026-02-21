{ config, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        grace = 5;
      };

      background = {
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
        brightness = 0.7;
      };

      # input-field colors are set by niri-flake's Stylix integration
      # We only add layout/sizing properties here (merged as attrsets)
      input-field = {
        size = "300, 50";
        outline_thickness = 2;
        fade_on_empty = false;
        placeholder_text = "";
        rounding = 8;
        halign = "center";
        valign = "center";
        position = "0, -50";
      };

      label = [
        {
          text = "$TIME";
          color = "rgb(${colors.base05})";
          font_size = 72;
          font_family = "Maple Mono NF";
          halign = "center";
          valign = "center";
          position = "0, 120";
        }
        {
          text = "cmd[update:3600000] date '+%A, %B %d'";
          color = "rgb(${colors.base04})";
          font_size = 20;
          font_family = "DejaVu Sans";
          halign = "center";
          valign = "center";
          position = "0, 50";
        }
      ];
    };
  };
}
