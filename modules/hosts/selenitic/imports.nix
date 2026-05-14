{ config, ... }:
{
  configurations.nixos.selenitic.module = {
    imports =
      (with config.flake.modules.nixos; [
        base
        waybar
      ])
      ++ [
        config.hosts.selenitic.hardwareModule
      ];
  };
}
