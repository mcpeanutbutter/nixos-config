{ config, ... }:
{
  configurations.nixos.spire.module.system.stateVersion = config.hosts.spire.stateVersion;
}
