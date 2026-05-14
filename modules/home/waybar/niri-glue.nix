{
  # Niri config bits that only matter when the waybar shell stack is active:
  # - reset waybar's systemd restart counter on session start (waybar can
  #   exceed the default restart limit during early D-Bus bring-up)
  # - layer-rules for the waybar surface (corner radius + shadow) and the
  #   swww backdrop namespace (place behind the overview)
  flake.modules.homeManager.waybar.imports = [
    {
      programs.niri.settings = {
        spawn-at-startup = [
          {
            command = [
              "systemctl"
              "--user"
              "reset-failed"
              "waybar.service"
            ];
          }
        ];

        layer-rules = [
          {
            matches = [ { namespace = "^swww-daemonbackdrop$"; } ];
            place-within-backdrop = true;
          }
          {
            matches = [ { namespace = "waybar"; } ];

            geometry-corner-radius = {
              top-left = 8.0;
              top-right = 8.0;
              bottom-right = 8.0;
              bottom-left = 8.0;
            };
            shadow = {
              enable = true;
              softness = 8.0;
              spread = 0.0;
              offset = {
                x = 0.0;
                y = 6.0;
              };
              draw-behind-window = true;
              color = "#00000040";
            };
          }
        ];

        layout = {
          # Transparent so swww's backdrop wallpaper shows through the niri
          # overview — paired with the swww-daemonbackdrop layer-rule above.
          background-color = "transparent";
        };
      };
    }
  ];
}
