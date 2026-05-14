{ config, ... }:
{
  configurations.nixos.selenitic.module = {
    imports = (with config.flake.modules.nixos; [ base ]) ++ [
      config.hosts.selenitic.hardwareModule
    ];
  };
}
