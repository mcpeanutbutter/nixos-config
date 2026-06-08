{ inputs, ... }:
{
  flake.modules.homeManager.noctalia.imports = [
    inputs.noctalia.homeModules.default
    {
      programs.noctalia-shell = {
        enable = true;

        # Diff against the upstream defaults documented at
        # https://docs.noctalia.dev/v4/getting-started/nixos/ (the
        # "Configuration defaults" block). Trim further as you settle on
        # what you actually want vs. what was just-in-the-export.
        settings = {
          # Pin the schema version so noctalia's migration loop is a
          # no-op on first read. Without this, settingsVersion defaults
          # to 0 and every migration runs — Migration45 in particular
          # rewrites `bar.barType` to "simple" because it expects a
          # legacy `bar.floating` boolean that's not in our JSON. The
          # corrected adapter then tries to save back, but our
          # settings.json is a read-only nix-store symlink, so the bug
          # recurs every fresh login. Bump this when noctalia ships
          # a new schema version (Commons/Settings.qml:28).
          settingsVersion = 59;

          appLauncher = {
            density = "comfortable";
            iconMode = "native";
          };
          bar = {
            barType = "floating";
            position = "top";
            density = "comfortable";
            marginVertical = 24;
            marginHorizontal = 128;
            useSeparateOpacity = true;
            widgets = {

              left = [
                {
                  id = "Launcher";
                  useDistroLogo = true;
                }
                {
                  compactMode = false;
                  id = "SystemMonitor";
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskAvailable = false;
                  showDiskUsage = false;
                  showDiskUsageAsPercent = false;
                  showGpuTemp = false;
                  showMemoryUsage = true;
                  showNetworkStats = true;
                }
                {
                  compactMode = false;
                  id = "MediaMini";
                }
                { id = "Spacer"; }
                {
                  id = "Taskbar";
                  iconScale = 0.9;
                  colorizeIcons = false;
                  hideMode = "hidden";
                }
              ];

              center = [ { id = "Clock"; } ];

              right = [
                { id = "Workspace"; }
                { id = "Spacer"; }
                { id = "NotificationHistory"; }
                {
                  colorizeIcons = false;
                  drawerEnabled = true;
                  hidePassive = false;
                  id = "Tray";
                }

                {
                  id = "Volume";
                  displayMode = "alwaysShow";
                }
                {
                  id = "Microphone";
                  displayMode = "alwaysShow";
                }
                {
                  id = "Brightness";
                  displayMode = "alwaysShow";
                }
                {
                  id = "Battery";
                  displayMode = "icon-always";
                }
                {
                  id = "Network";
                  displayMode = "alwaysShow";
                }
                {
                  id = "VPN";
                  displayMode = "alwaysShow";
                }
                {
                  id = "Bluetooth";
                  displayMode = "alwaysShow";
                }

                { id = "NightLight"; }
                { id = "ControlCenter"; }
              ];
            };
          };
          controlCenter = {
            position = "center";
          };
          dock = {
            enabled = false;
          };
          general = {
            avatarImage = "/home/jonas/.face";
            clockFormat = "hh\nmm";
            clockStyle = "digital";
            enableLockScreenCountdown = false;
            enableLockScreenMediaControls = true;
            lockScreenAnimations = true;
            # lockScreenBlur = 1;
            lockScreenBlur = 0;
            passwordChars = true;
            telemetryEnabled = false;
          };
          idle = {
            enabled = true;
            screenOffTimeout = 300;
          };
          location = {
            name = "Vienna";
            weatherShowEffects = false;
          };
          nightLight = {
            enabled = true;
            autoSchedule = true;
            manualSunrise = "07:00";
            manualSunset = "20:00";
          };
          notifications = {
            sounds = {
              enabled = true;
            };
          };
          sessionMenu = {
            countdownDuration = 5000;
          };
          ui = {
            boxBorderEnabled = true;
            translucentWidgets = true;
          };
          wallpaper = {
            automationEnabled = true;
            directory = "/home/jonas/Pictures/Wallpapers";
            randomIntervalSec = 1800;
            transitionType = [ "fade" ];
            overviewEnabled = true;
          };
        };
      };

      # Stylix's noctalia target auto-enables via stylix.autoEnable (true
      # in modules/nixos/services/stylix.nix), but we set it explicitly so
      # the wiring is grep-able.
      stylix.targets.noctalia-shell.enable = true;
    }
  ];
}
