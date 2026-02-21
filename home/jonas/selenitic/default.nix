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

  # Monitor configuration for selenitic
  programs.niri.settings.outputs = {
    "eDP-1" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 60.006;
      };
      scale = 1.1;
    };
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = hostConfig.stateVersion;
}
