{
  lib,
  nhModules,
  hostConfig,
  ...
}:
{
  imports = [
    "${nhModules}/common"
  ]
  ++ lib.optionals (hostConfig.desktopEnvironment == "niri") [
    "${nhModules}/desktop/niri"
    "${nhModules}/desktop/waybar"
    "${nhModules}/desktop/mako"
    "${nhModules}/desktop/swww"
  ];

  # Monitor configuration for spire
  programs.niri.settings.outputs = {
    "HDMI-A-2" = {
      mode = {
        width = 3840;
        height = 2160;
        refresh = 120.000;
      };
      scale = 1.1;
    };
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = hostConfig.stateVersion;
}
