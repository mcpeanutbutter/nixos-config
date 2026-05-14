{ config, ... }:
{
  flake.modules.nixos.base = {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    # Module-system list merge with users.nix's extraGroups setting.
    users.users.${config.user.username}.extraGroups = [ "docker" ];
  };
}
