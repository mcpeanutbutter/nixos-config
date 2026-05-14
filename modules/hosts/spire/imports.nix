{ config, ... }:
{
  configurations.nixos.spire.module = {
    imports =
      (with config.flake.modules.nixos; [
        base
        waybar
      ])
      ++ [
        config.hosts.spire.hardwareModule
      ];
  };
}
