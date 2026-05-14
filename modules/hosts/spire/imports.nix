{ config, ... }:
{
  configurations.nixos.spire.module = {
    imports =
      (with config.flake.modules.nixos; [
        base
        noctalia
      ])
      ++ [
        config.hosts.spire.hardwareModule
      ];
  };
}
