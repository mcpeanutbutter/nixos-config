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
            marginHorizontal = 16;
            useSeparateOpacity = true;
            widgets = {
              center = [
                {
                  characterCount = 2;
                  colorizeIcons = false;
                  emptyColor = "secondary";
                  enableScrollWheel = true;
                  focusedColor = "primary";
                  followFocusedScreen = false;
                  fontWeight = "bold";
                  groupedBorderOpacity = 1;
                  hideUnoccupied = false;
                  iconScale = 0.8;
                  id = "Workspace";
                  labelMode = "index";
                  occupiedColor = "secondary";
                  pillSize = 0.6;
                  showApplications = false;
                  showApplicationsHover = false;
                  showBadge = true;
                  showLabelsOnlyWhenOccupied = true;
                  unfocusedIconsOpacity = 1;
                }
              ];
              left = [
                {
                  colorizeSystemIcon = "none";
                  colorizeSystemText = "none";
                  customIconPath = "";
                  enableColorization = false;
                  icon = "rocket";
                  iconColor = "none";
                  id = "Launcher";
                  useDistroLogo = true;
                }
                {
                  clockColor = "none";
                  customFont = "";
                  formatHorizontal = "HH:mm ddd, MMM dd";
                  formatVertical = "HH mm - dd MM";
                  id = "Clock";
                  tooltipFormat = "HH:mm ddd, MMM dd";
                  useCustomFont = false;
                }
                {
                  compactMode = false;
                  diskPath = "/";
                  iconColor = "none";
                  id = "SystemMonitor";
                  showCpuCores = false;
                  showCpuFreq = false;
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskAvailable = false;
                  showDiskUsage = false;
                  showDiskUsageAsPercent = false;
                  showGpuTemp = false;
                  showLoadAverage = false;
                  showMemoryAsPercent = false;
                  showMemoryUsage = true;
                  showNetworkStats = true;
                  showSwapUsage = false;
                  textColor = "none";
                  useMonospaceFont = true;
                  usePadding = false;
                }
                {
                  compactMode = false;
                  hideMode = "hidden";
                  hideWhenIdle = false;
                  id = "MediaMini";
                  maxWidth = 145;
                  panelShowAlbumArt = true;
                  scrollingMode = "hover";
                  showAlbumArt = true;
                  showArtistFirst = true;
                  showProgressRing = true;
                  showVisualizer = false;
                  textColor = "none";
                  useFixedWidth = false;
                  visualizerType = "linear";
                }
              ];
              right = [
                {
                  blacklist = [ ];
                  chevronColor = "none";
                  colorizeIcons = false;
                  drawerEnabled = false;
                  hidePassive = false;
                  id = "Tray";
                  pinned = [ ];
                }
                {
                  hideWhenZero = false;
                  hideWhenZeroUnread = false;
                  iconColor = "none";
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                  unreadBadgeColor = "primary";
                }
                {
                  deviceNativePath = "__default__";
                  displayMode = "graphic";
                  hideIfIdle = false;
                  hideIfNotDetected = true;
                  id = "Battery";
                  showNoctaliaPerformance = false;
                  showPowerProfiles = true;
                }
                {
                  displayMode = "alwaysShow";
                  iconColor = "none";
                  id = "Volume";
                  middleClickCommand = "pwvucontrol || pavucontrol";
                  textColor = "none";
                }
                {
                  applyToAllMonitors = false;
                  displayMode = "alwaysShow";
                  iconColor = "none";
                  id = "Brightness";
                  textColor = "none";
                }
                {
                  iconColor = "none";
                  id = "NightLight";
                }
                {
                  colorizeDistroLogo = false;
                  colorizeSystemIcon = "none";
                  colorizeSystemText = "none";
                  customIconPath = "";
                  enableColorization = false;
                  icon = "noctalia";
                  id = "ControlCenter";
                  useDistroLogo = false;
                }
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
            lockScreenBlur = 0.3;
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
