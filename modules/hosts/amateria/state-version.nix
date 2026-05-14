{ config, ... }:
{
  configurations.nixos.amateria.module.system.stateVersion = config.hosts.amateria.stateVersion;
}
