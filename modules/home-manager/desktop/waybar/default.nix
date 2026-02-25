{
  config,
  lib,
  pkgs,
  hostConfig,
  ...
}:
let
  colors = config.lib.stylix.colors;
  battery-icons = [
    "󰁺"
    "󰁻"
    "󰁼"
    "󰁽"
    "󰁾"
    "󰁿"
    "󰂀"
    "󰂁"
    "󰂂"
    "󰁹"
  ];
  wifi-icons = [
    "󰤯"
    "󰤟"
    "󰤢"
    "󰤥"
    "󰤨"
  ];
  audio-icons = [
    ""
    ""
    ""
    ""
  ];
  generic-percent-icons = [
    "▁"
    "▂"
    "▃"
    "▄"
    "▅"
    "▆"
    "▇"
    "█"
  ];
  temperature-icons = [
    ""
    ""
    ""
    ""
  ];
  brightness-icons = [
    "󰃞"
    "󰃟"
    "󰃠"
  ];
in
{
  stylix.targets.waybar = {
    enable = true;
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 0; # Auto-height allows border-radius to work
        margin = "8 8 0 8"; # top right bottom left

        modules-left = [
          "custom/launcher"
          "clock#date"
          "clock#time"
          "cpu"
          "memory"
          "temperature"
        ];

        modules-center = [
          "niri/workspaces"
        ];

        modules-right = [
          "tray"
          "pulseaudio"
          "privacy"
          "battery"
          "power-profiles-daemon"
          "backlight"
          "custom/night-light"
          "custom/BSC"
          "custom/power"
        ];

        # Niri-specific modules
        "niri/workspaces" = {
          format = "{index}";
          all-outputs = true;
        };

        "custom/launcher" = {
          format = "";
          on-click = "${pkgs.fuzzel}/bin/fuzzel";
          tooltip = false;
        };

        "clock#date" = {
          format = "{:%A, %d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "clock#time" = {
          format = "{:%H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          interval = 1;
          format = " {usage}%";
          format-icons = generic-percent-icons;
          tooltip-format = "usage: {usage}%\nload: {load}";
        };

        memory = {
          interval = 1;
          format = "  {percentage}%";
          format-icons = generic-percent-icons;
          tooltip-format = "{used} GiB / {total} GiB";
        };

        temperature = {
          interval = 1;
          critical-threshold = 80;
          format = "{icon} {temperatureC}°C";
          format-icons = temperature-icons;
        } // lib.optionalAttrs (hostConfig.thermalZone != null) {
          thermal-zone = hostConfig.thermalZone;
        } // lib.optionalAttrs (hostConfig.hwmon != null) {
          hwmon-path-abs = hostConfig.hwmon.path;
          input-filename = hostConfig.hwmon.input;
        };

        backlight = {
          format = "{icon}";
          format-icons = brightness-icons;
          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
          tooltip-format = "{percent}%";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄";
          format-plugged = "󰚥";
          format-icons = battery-icons;
          tooltip-format = "{time}, {cycles} cycles, {health}% health";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 {volume}%";
          format-icons.default = audio-icons;
          on-click = "pavucontrol";
        };

        privacy = {
          icon-spacing = 4;
          icon-size = 16;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-out";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 24;
            }
          ];
          ignore-monitor = true;
          ignore = [
            {
              type = "audio-in";
              name = "cava";
            }
            {
              type = "screenshare";
              name = "obs";
            }
          ];
        };

        tray = {
          icon-size = 16;
          show-passive-items = true;
          spacing = 5;
        };

        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };

        "custom/night-light" = {
          format = "󰖔";
          on-click = "${pkgs.writeShellScript "night-light-toggle" ''
            if ${pkgs.procps}/bin/pgrep gammastep > /dev/null; then
              ${pkgs.procps}/bin/pkill gammastep
            else
              ${pkgs.gammastep}/bin/gammastep -O 4000 &
            fi
          ''}";
          tooltip = false;
        };

        "custom/BSC" = {
          exec = "${pkgs.writeShellScript "BSC-status" ''
            if ${pkgs.systemd}/bin/systemctl is-active --quiet podman-BSC.service; then
              echo '{"text": "󰒃", "class": "active", "tooltip": "BitDefender: Running"}'
            else
              echo '{"text": "󰒃", "class": "inactive", "tooltip": "BitDefender: Stopped"}'
            fi
          ''}";
          return-type = "json";
          interval = 5;
          on-click = "${pkgs.writeShellScript "BSC-toggle" ''
            if ${pkgs.systemd}/bin/systemctl is-active --quiet podman-BSC.service; then
              ${pkgs.systemd}/bin/busctl call --system org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager StopUnit ss "podman-BSC.service" "replace"
            else
              ${pkgs.systemd}/bin/busctl call --system org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager StartUnit ss "podman-BSC.service" "replace"
            fi
          ''}";
          tooltip = true;
        };

        "custom/power" = {
          format = "⏻";
          on-click = "${pkgs.writeShellScript "power-menu" ''
            choice=$(echo -e "💤 Sleep\n🚪 Logout\n🔄 Reboot\n⏻ Shutdown" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Power: ")
            case "$choice" in
              "💤 Sleep")
                systemctl suspend
                ;;
              "🚪 Logout")
                ${pkgs.niri}/bin/niri msg action quit
                ;;
              "🔄 Reboot")
                systemctl reboot
                ;;
              "⏻ Shutdown")
                systemctl poweroff
                ;;
            esac
          ''}";
          tooltip = false;
        };
      };
    };

    style = lib.mkAfter (builtins.readFile ./style.css);
  };

}
