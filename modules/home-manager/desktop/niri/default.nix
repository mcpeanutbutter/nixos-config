{
  config,
  pkgs,
  inputs,
  ...
}:
let
  lockCmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock &";
  powerOffCmd = "${config.programs.niri.package}/bin/niri msg action power-off-monitors";

  # Suspend if on battery (battery exists and AC not online) and screen is locked.
  # Desktops have no BAT* entries, so this is a no-op for them.
  batterySuspendCmd = pkgs.writeShellScript "idle-battery-suspend" ''
    if ls /sys/class/power_supply/BAT* >/dev/null 2>&1 && \
       ! grep -q 1 /sys/class/power_supply/A*/online 2>/dev/null; then
      pidof hyprlock && systemctl suspend
    fi
  '';
in
{
  imports = [
    ./keybindings.nix
    ./xdg.nix
  ];

  # Note: niri.homeModules.niri is automatically imported by the NixOS module
  # when home-manager is detected, so we don't need to import it here

  # Disable XDG autostart for blueman-applet (it races Waybar and loses the tray icon)
  # We use our own systemd service below with proper ordering instead
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
      After = [ "graphical-session.target" "waybar.service" ];
    };
    Service = {
      # Wait for Waybar's StatusNotifierWatcher to be available on D-Bus
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in $(seq 1 50); do ${pkgs.dbus}/bin/dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.GetNameOwner string:org.kde.StatusNotifierWatcher >/dev/null 2>&1 && exit 0; sleep 0.1; done; echo \"StatusNotifierWatcher not found, starting anyway\"; exit 0'";
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Idle management and auto-lock (optional)
  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = lockCmd; }
      { event = "lock"; command = lockCmd; }
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
        timeout = 900; # 15 min — power off monitors (only reached when plugged in)
        command = powerOffCmd;
      }
    ];
  };

  programs.niri.settings = {
    input.keyboard.xkb = {
      layout = "us";
      variant = "altgr-intl";
      options = "caps:escape";
    };

    # Note: waybar and mako are started via systemd services (see their configs)
    # Waybar may exceed the default systemd restart limit, so reset it on startup
    spawn-at-startup = [
      {
        command = [
          "systemctl"
          "--user"
          "reset-failed"
          "waybar.service"
        ];
      }
      {
        command = [
          "systemctl"
          "--user"
          "start"
          "thunar.service"
        ];
      }
    ];

    # Disable client-side decorations (title bars) for a cleaner look
    # Niri handles window management, so app title bars are redundant
    prefer-no-csd = true;

    # Window rules for rounded corners
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

    # Layer rules for wallpaper placement
    # Place the backdrop namespace wallpaper behind the overview
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

    # Layout configuration
    layout = {
      gaps = 16; # Gaps between windows

      # Transparent background allows backdrop wallpaper to show through
      background-color = "transparent";

      # Outer gaps to screen edges (4x larger)
      struts = {
        left = 16;
        right = 16;
        top = 16;
        bottom = 16;
      };

      border = {
        width = 6; # 2x larger border
        active.gradient = {
          from = "#${config.lib.stylix.colors.base0D}"; # Blue accent
          to = "#${config.lib.stylix.colors.base0B}"; # Green accent
          angle = -45;
        };
        inactive.color = "#${config.lib.stylix.colors.base03}"; # Dimmed color for inactive
      };

      shadow = {
        enable = true;
        softness = 8; # Sharp shadow (minimal blur)
        offset = {
          x = 0;
          y = 6; # 6px vertical offset
        };
        color = "#00000040"; # Semi-transparent black
      };
    };

    # Enable Ozone Wayland support for Electron apps
    environment.NIXOS_OZONE_WL = "1";
  };

  # Helper script to toggle laptop screen for docking
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
