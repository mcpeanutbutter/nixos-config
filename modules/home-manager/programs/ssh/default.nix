{ userConfig, ... }:
let
  sshSettings = userConfig.ssh;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*".forwardAgent = true;
      "*".compression = true;
      github = {
        host = "github.com";
        identityFile = sshSettings.personalPrivateKey;
        identitiesOnly = true;
      };
    };
  };
}
