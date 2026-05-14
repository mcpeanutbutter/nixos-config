{ config, ... }:
{
  configurations.nixos.amateria.module.home-manager.users.${config.user.username}.programs.niri.settings.outputs =
    {
      "eDP-1" = {
        mode = {
          width = 2560;
          height = 1600;
          refresh = 165.0;
        };
        scale = 1.25;
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
}
