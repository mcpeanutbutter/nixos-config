{ userConfig, ... }:
{
  # Enable Docker with rootless mode
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Add user to docker group
  users.users.${userConfig.username}.extraGroups = [ "docker" ];
}
