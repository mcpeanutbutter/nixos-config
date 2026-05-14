{ config, ... }:
{
  configurations.nixos.selenitic.module.home-manager.users.${config.user.username}.programs.niri.settings.outputs =
    {
      "eDP-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.006;
        };
        scale = 1.1;
      };
    };
}
