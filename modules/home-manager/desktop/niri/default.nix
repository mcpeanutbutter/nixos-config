{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # Note: niri.homeModules.niri is automatically imported by the NixOS module
  # when home-manager is detected, so we don't need to import it here

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
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Idle management and auto-lock (optional)
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.brightnessctl}/bin/brightnessctl set 10%";
        resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl set 100%";
      }
      {
        timeout = 600;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 900;
        command = "${config.programs.niri.package}/bin/niri msg action power-off-monitors";
      }
    ];
  };

  programs.niri.settings = {
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
          y = 6; # 8px vertical offset
        };
        color = "#00000040"; # Semi-transparent black
      };
    };

    # Keybindings
    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
      # Application shortcuts
      "Mod+T" = {
        action.spawn = [ "ghostty" ];
        hotkey-overlay.title = "Spawn GhosTTY Terminal";
      };
      "Mod+D" = {
        action.spawn = [ "fuzzel" ];
        hotkey-overlay.title = "Spawn fuzzel launcher";
      };
      "Super+Alt+L".action.spawn = [ "swaylock" ];

      # Media keys
      "XF86AudioRaiseVolume" = {
        action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "0.05+"
        ];
        allow-when-locked = true;
      };
      "XF86AudioLowerVolume" = {
        action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "0.05-"
        ];
        allow-when-locked = true;
      };
      "XF86AudioMute" = {
        action.spawn = [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SINK@"
          "toggle"
        ];
        allow-when-locked = true;
      };
      "XF86AudioMicMute" = {
        action.spawn = [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SOURCE@"
          "toggle"
        ];
        allow-when-locked = true;
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "play-pause"
        ];
      };
      "XF86AudioStop" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "stop"
        ];
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "previous"
        ];
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn = [
          "playerctl"
          "next"
        ];
      };

      # Brightness
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "--class=backlight"
          "set"
          "5%+"
        ];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "--class=backlight"
          "set"
          "5%-"
        ];
      };

      # Overview
      "Mod+O".action.toggle-overview = [ ];

      "Mod+Q".action.close-window = [ ];

      # Window navigation
      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+J".action.focus-window-down = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+L".action.focus-column-right = [ ];
      "Mod+Home".action.focus-column-first = [ ];
      "Mod+End".action.focus-column-last = [ ];
      "Mod+Shift+WheelScrollDown" = {
        action.focus-column-left = [ ];
        cooldown-ms = 150;
      };
      "Mod+Shift+WheelScrollUp" = {
        action.focus-column-right = [ ];
        cooldown-ms = 150;
      };

      # Window movement
      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+H".action.move-column-left = [ ];
      "Mod+Ctrl+J".action.move-window-down = [ ];
      "Mod+Ctrl+K".action.move-window-up = [ ];
      "Mod+Ctrl+L".action.move-column-right = [ ];
      "Mod+Ctrl+Home".action.move-column-to-first = [ ];
      "Mod+Ctrl+End".action.move-column-to-last = [ ];
      "Mod+Ctrl+Shift+WheelScrollDown" = {
        action.move-column-left = [ ];
        cooldown-ms = 150;
      };
      "Mod+Ctrl+Shift+WheelScrollUp" = {
        action.move-column-right = [ ];
        cooldown-ms = 150;
      };

      # Monitor navigation
      "Mod+Shift+Left".action.focus-monitor-left = [ ];
      "Mod+Shift+Down".action.focus-monitor-down = [ ];
      "Mod+Shift+Up".action.focus-monitor-up = [ ];
      "Mod+Shift+Right".action.focus-monitor-right = [ ];
      "Mod+Shift+H".action.focus-monitor-left = [ ];
      "Mod+Shift+J".action.focus-monitor-down = [ ];
      "Mod+Shift+K".action.focus-monitor-up = [ ];
      "Mod+Shift+L".action.focus-monitor-right = [ ];

      # Monitor window movement
      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

      # Workspace navigation
      "Mod+Page_Down".action.focus-workspace-down = [ ];
      "Mod+Page_Up".action.focus-workspace-up = [ ];
      "Mod+U".action.focus-workspace-down = [ ];
      "Mod+I".action.focus-workspace-up = [ ];
      "Mod+WheelScrollDown" = {
        action.focus-workspace-down = [ ];
        cooldown-ms = 150;
      };
      "Mod+WheelScrollUp" = {
        action.focus-workspace-up = [ ];
        cooldown-ms = 150;
      };

      # Workspace window movement
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
      "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];
      "Mod+Ctrl+WheelScrollDown" = {
        action.move-column-to-workspace-down = [ ];
        cooldown-ms = 150;
      };
      "Mod+Ctrl+WheelScrollUp" = {
        action.move-column-to-workspace-up = [ ];
        cooldown-ms = 150;
      };

      # Workspace movement
      "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
      "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
      "Mod+Shift+U".action.move-workspace-down = [ ];
      "Mod+Shift+I".action.move-workspace-up = [ ];

      # Index Workspace navigation
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;

      # Index window movement
      "Mod+Ctrl+1".action.move-column-to-workspace = 1;
      "Mod+Ctrl+2".action.move-column-to-workspace = 2;
      "Mod+Ctrl+3".action.move-column-to-workspace = 3;
      "Mod+Ctrl+4".action.move-column-to-workspace = 4;
      "Mod+Ctrl+5".action.move-column-to-workspace = 5;
      "Mod+Ctrl+6".action.move-column-to-workspace = 6;
      "Mod+Ctrl+7".action.move-column-to-workspace = 7;
      "Mod+Ctrl+8".action.move-column-to-workspace = 8;
      "Mod+Ctrl+9".action.move-column-to-workspace = 9;

      # Switches focus between the current and the previous workspace.
      "Mod+Tab".action.focus-workspace-previous = [ ];

      # Move the focused window in and out of a column.
      "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
      "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

      # Consume/expel one window from the right to the bottom of the focused column and vice-versa.
      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+Period".action.expel-window-from-column = [ ];

      # Window sizing
      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Shift+R".action.switch-preset-window-height = [ ];
      "Mod+Ctrl+R".action.reset-window-height = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];

      "Mod+C".action.center-column = [ ];
      "Mod+Ctrl+C".action.center-visible-columns = [ ];

      # Move the focused window between the floating and the tiling layout.
      "Mod+V".action.toggle-window-floating = [ ];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

      #Toggle tabbed column display mode.
      "Mod+W".action.toggle-column-tabbed-display = [ ];

      # Screenshots
      "Print".action.screenshot = [ ];
      "Ctrl+Print".action.screenshot-screen = [ ];
      "Alt+Print".action.screenshot-window = [ ];

      # Other
      "Mod+Escape".action.toggle-keyboard-shortcuts-inhibit = [ ];
      "Mod+Shift+E".action.quit = [ ];
      "Mod+Shift+P".action.power-off-monitors = [ ];
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
