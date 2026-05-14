{ config, ... }:
{
  configurations.nixos.amateria.module = {
    imports =
      (with config.flake.modules.nixos; [
        base
        work
      ])
      ++ [
        config.hosts.amateria.hardwareModule
      ];
  };
}
