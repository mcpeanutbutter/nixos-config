{ config, ... }:
{
  configurations.nixos.spire.module = {
    imports = (with config.flake.modules.nixos; [ base ]) ++ [
      config.hosts.spire.hardwareModule
    ];
  };
}
