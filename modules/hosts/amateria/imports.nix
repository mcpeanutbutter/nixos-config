{ config, ... }:
{
  configurations.nixos.amateria.module = {
    imports =
      (with config.flake.modules.nixos; [
        base
        work
        waybar
      ])
      ++ [
        config.hosts.amateria.hardwareModule
      ];
  };
}
