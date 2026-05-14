{ config, ... }:
{
  configurations.nixos.amateria.module = {
    imports = (with config.flake.modules.nixos; [ base ]) ++ [
      config.hosts.amateria.hardwareModule
    ];
  };
}
