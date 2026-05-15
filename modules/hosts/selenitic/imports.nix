{ config, ... }:
{
  configurations.nixos.selenitic.module = {
    imports =
      (with config.flake.modules.nixos; [
        base
        noctalia
      ])
      ++ [
        config.hosts.selenitic.hardwareModule
      ];
  };
}
