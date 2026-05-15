{ config, ... }:
{
  configurations.nixos.amateria.module = {
    imports =
      (with config.flake.modules.nixos; [
        base
        work
        noctalia
      ])
      ++ [
        config.hosts.amateria.hardwareModule
      ];
  };
}
