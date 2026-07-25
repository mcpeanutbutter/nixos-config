{
  flake.modules.homeManager.base.imports = [
    (
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        baseCfg = config.xdg.configFile.niri-config.source;
        mkGapVariant =
          name: gaps: l: r: t: b:
          pkgs.runCommand "niri-${name}.kdl" { } ''
            ${pkgs.gnused}/bin/sed \
              -e 's/^    gaps [0-9][0-9]*/    gaps ${toString gaps}/' \
              -e '/^    struts {/,/^    }/{
                    s/^        left [0-9][0-9]*/        left ${toString l}/
                    s/^        right [0-9][0-9]*/        right ${toString r}/
                    s/^        top [0-9][0-9]*/        top ${toString t}/
                    s/^        bottom [0-9][0-9]*/        bottom ${toString b}/
                  }' \
              ${baseCfg} > $out
          '';
        tightCfg = mkGapVariant "tight" 4 0 0 0 0;
        looseCfg = mkGapVariant "loose" 24 48 48 16 32;
      in
      {
        # Disable XDG autostart for blueman-applet (it races the tray host and
        # loses the tray icon). The systemd service below restarts it in order.
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
            After = [ "graphical-session.target" ];
          };
          Service = {
            # Wait for the tray host's StatusNotifierWatcher to be available on
            # D-Bus (noctalia provides it).
            ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in $(seq 1 50); do ${pkgs.dbus}/bin/dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.GetNameOwner string:org.kde.StatusNotifierWatcher >/dev/null 2>&1 && exit 0; sleep 0.1; done; echo \"StatusNotifierWatcher not found, starting anyway\"; exit 0'";
            ExecStart = "${pkgs.blueman}/bin/blueman-applet";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        programs.niri.settings = {
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          input.keyboard.xkb = {
            layout = "us";
            variant = "altgr-intl";
            options = "caps:escape";
          };

          # Niri hardcodes XF86PowerOff -> suspend (and inhibits logind's own
          # power-key handling). The Shokz OpenMeet UC dongle emits phantom
          # power-key presses when the headset powers on, which suspended the
          # system mid-transition ("screens go black, LED solid, hard reset").
          # See the HandlePowerKey note in modules/nixos/services/power.nix.
          input.power-key-handling.enable = false;

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

          # Cycle the layout.gaps + layout.struts between tight / medium / loose
          # presets by atomically reloading niri with one of three nix-built
          # configs. Niri exposes no per-setting IPC for gaps/struts, so a full
          # config reload via `load-config-file` is the only available mechanism.
          # Note: any `nixos-rebuild switch` rewrites the watched config.kdl back
          # to the medium preset; press the bind again to re-apply.
          (pkgs.writeShellScriptBin "niri-cycle-gaps" ''
            #!/usr/bin/env bash
            state_file="''${XDG_RUNTIME_DIR:-/tmp}/niri-gap-preset"
            current=$(cat "$state_file" 2>/dev/null || echo medium)
            case "$current" in
              tight)  next=medium; path="${baseCfg}"  ;;
              medium) next=loose;  path="${looseCfg}" ;;
              loose)  next=tight;  path="${tightCfg}" ;;
              *)      next=medium; path="${baseCfg}"  ;;
            esac
            echo "$next" > "$state_file"
            niri msg action load-config-file --path "$path"
            if command -v noctalia-cycle-gaps >/dev/null 2>&1; then
              noctalia-cycle-gaps "$next"
            fi
          '')
        ];
      }
    )
  ];
}
