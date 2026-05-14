{ config, ... }:
{
  configurations.nixos.spire.module.home-manager.users.${config.user.username}.programs.niri.settings.outputs =
    {
      "HDMI-A-2" = {
        mode = {
          width = 3840;
          height = 2160;
          refresh = 120.000;
        };
        scale = 1.1;
      };
    };
}
