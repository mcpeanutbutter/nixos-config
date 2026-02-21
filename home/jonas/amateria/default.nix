{
  lib,
  nhModules,
  hostConfig,
  ...
}:
{
  imports =
    [
      "${nhModules}/common"
    ]
    ++ lib.optionals (hostConfig.desktopEnvironment == "niri") [
      "${nhModules}/desktop/niri"
      "${nhModules}/desktop/waybar"
      "${nhModules}/desktop/mako"
      "${nhModules}/desktop/swww"
    ];

  # Monitor configuration for amateria (Framework 16 laptop + external display)
  programs.niri.settings.outputs = {
    "eDP-1" = {
      mode = {
        width = 2560;
        height = 1600;
        refresh = 165.0;
      };
      scale = 1.1;
    };
    "DP-3" = {
      mode = {
        width = 3840;
        height = 2160;
        refresh = 120.0;
      };
      position = {
        x = 1707;
        y = 0;
      };
      scale = 1.1;
    };
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = hostConfig.stateVersion;
}
