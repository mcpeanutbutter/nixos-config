{
  flake.modules.homeManager.base.imports = [
    (
      { config, pkgs, ... }:
      let
        lockCmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock &";
        powerOffCmd = "${config.programs.niri.package}/bin/niri msg action power-off-monitors";

        # Suspend if on battery (battery exists and AC not online) and the
        # screen is locked. Desktops have no BAT* entries, so this is a no-op
        # for them.
        batterySuspendCmd = pkgs.writeShellScript "idle-battery-suspend" ''
          if ls /sys/class/power_supply/BAT* >/dev/null 2>&1 && \
             ! grep -q 1 /sys/class/power_supply/A*/online 2>/dev/null; then
            pidof hyprlock && systemctl suspend
          fi
        '';
      in
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

        # Idle management and auto-lock
        services.swayidle = {
          enable = true;
          events = [
            {
              event = "before-sleep";
              command = lockCmd;
            }
            {
              event = "lock";
              command = lockCmd;
            }
          ];
          timeouts = [
            {
              timeout = 300; # 5 min — auto-lock
              command = lockCmd;
            }
            {
              timeout = 600; # 10 min — suspend on battery (no-op on AC / desktops)
              command = toString batterySuspendCmd;
            }
            {
              timeout = 900; # 15 min — power off monitors
              command = powerOffCmd;
              resumeCommand = "${pkgs.systemd}/bin/systemctl --user restart waybar.service";
            }
          ];
        };

        programs.niri.settings = {
          input.keyboard.xkb = {
            layout = "us";
            variant = "altgr-intl";
            options = "caps:escape";
          };

          # waybar and mako are started via systemd services. Waybar may exceed
          # the default systemd restart limit, so reset it on startup.
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

          # Wallpaper placement: backdrop wallpaper goes behind the overview.
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
