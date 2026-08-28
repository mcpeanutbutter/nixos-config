{ config, ... }:
{
  configurations.nixos.amateria.module.home-manager.users.${config.user.username}.programs.niri.settings =
    {
      outputs = {
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

      # Pin the hub workspace (declared in modules/home/desktop/niri/workspaces.nix)
      # to the external panel. With open-on-output unset niri picks an output
      # itself, and it picks eDP-1 — observed after a reboot with both outputs
      # connected. Safe while undocked: niri migrates a named workspace to a live
      # output and moves it back when DP-3 returns.
      workspaces.hub.open-on-output = "DP-3";
    };
}
