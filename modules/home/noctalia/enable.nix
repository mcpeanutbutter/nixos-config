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
          appLauncher = {
            density = "comfortable";
            iconMode = "native";
          };
          bar = {
            barType = "floating";
            density = "comfortable";
            marginVertical = 16;
            marginHorizontal = 128;
            useSeparateOpacity = true;
            widgets = {
              center = [ { id = "Workspace"; } ];
              left = [
                {
                  id = "Launcher";
                  useDistroLogo = true;
                }
                { id = "Clock"; }
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
              ];
              right = [
                {
                  colorizeIcons = false;
                  drawerEnabled = false;
                  hidePassive = false;
                  id = "Tray";
                }
                { id = "NotificationHistory"; }
                { id = "Battery"; }
                { id = "Volume"; }
                { id = "Brightness"; }
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
            clockStyle = "analog";
            enableLockScreenCountdown = false;
            enableLockScreenMediaControls = true;
            lockScreenAnimations = true;
            lockScreenBlur = 0.5;
            passwordChars = true;
            # shadowDirection = "bottom";
            # shadowOffsetX = 0;
            # telemetryEnabled = true;
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
            randomIntervalSec = 3600;
            transitionType = [ "fade" ];
            overviewEnabled = true;
            # overviewBlur = 0.4;
            # overviewTint = 0.6;
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
