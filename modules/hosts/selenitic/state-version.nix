{ config, ... }:
{
  configurations.nixos.selenitic.module.system.stateVersion = config.hosts.selenitic.stateVersion;
}
