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

  # Monitor configuration for spire
  # TODO: Configure on first boot
  programs.niri.settings.outputs = { };

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = hostConfig.stateVersion;
}
