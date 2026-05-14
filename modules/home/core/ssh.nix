{ config, ... }:
{
  flake.modules.homeManager.base.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*".forwardAgent = true;
      "*".compression = true;
      github = {
        host = "github.com";
        identityFile = config.user.ssh.personalPrivateKey;
        identitiesOnly = true;
      };
    };
  };
}
