{
  flake.modules.homeManager.base.imports = [
    (
      { config, pkgs, ... }:
      {
        # Disable XDG autostart for blueman-applet (it races Waybar and loses
        # the tray icon). The systemd service below restarts it in order.
        xdg.configFile."autostart/blueman-applet.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';

        # System tray applets
        systemd.user.services.nm-applet = {
          Unit = {
            Description = "Network Manager Applet";
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        systemd.user.services.blueman-applet = {
          Unit = {
            Description = "Blueman Applet";
            After = [
              "graphical-session.target"
              "waybar.service"
            ];
          };
          Service = {
            # Wait for Waybar's StatusNotifierWatcher to be available on D-Bus.
            ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in $(seq 1 50); do ${pkgs.dbus}/bin/dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.GetNameOwner string:org.kde.StatusNotifierWatcher >/dev/null 2>&1 && exit 0; sleep 0.1; done; echo \"StatusNotifierWatcher not found, starting anyway\"; exit 0'";
            ExecStart = "${pkgs.blueman}/bin/blueman-applet";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        programs.niri.settings = {
          input.keyboard.xkb = {
            layout = "us";
            variant = "altgr-intl";
            options = "caps:escape";
          };

          # Disable client-side decorations for a cleaner look.
          prefer-no-csd = true;

          # Rounded corners on every window.
          window-rules = [
            {
              geometry-corner-radius = {
                top-left = 8.0;
                top-right = 8.0;
                bottom-right = 8.0;
                bottom-left = 8.0;
              };
              clip-to-geometry = true;
            }
          ];

          layout = {
            gaps = 16;

            preset-column-widths = [
              { proportion = 1.0 / 4.0; }
              { proportion = 1.0 / 3.0; }
              { proportion = 1.0 / 2.0; }
              { proportion = 2.0 / 3.0; }
            ];

            default-column-width.proportion = 1.0 / 3.0;

            # Transparent so the backdrop wallpaper shows through.
            background-color = "transparent";

            struts = {
              left = 24;
              right = 24;
              top = 0;
              bottom = 24;
            };

            border = {
              width = 4;
              active.gradient = {
                from = "#${config.lib.stylix.colors.base0D}"; # Blue accent
                to = "#${config.lib.stylix.colors.base0B}"; # Green accent
                angle = -45;
                in' = "oklch longer hue";
              };
              inactive.color = "#${config.lib.stylix.colors.base03}";
            };

            shadow = {
              enable = true;
              softness = 8;
              offset = {
                x = 0;
                y = 6;
              };
              color = "#00000040";
            };
          };

          # Electron apps under Wayland.
          environment.NIXOS_OZONE_WL = "1";
        };

        # Helper script to toggle the laptop screen on/off for docking.
        home.packages = [
          (pkgs.writeShellScriptBin "niri-toggle-laptop-screen" ''
            #!/usr/bin/env bash
            if niri msg outputs | grep -q "eDP-1.*disabled"; then
              niri msg output eDP-1 on
              echo "Laptop screen enabled"
            else
              niri msg output eDP-1 off
              echo "Laptop screen disabled"
            fi
          '')
        ];
      }
    )
  ];
}
