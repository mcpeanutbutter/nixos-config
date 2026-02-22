{ config, userConfig, ... }:
let
  sshSettings = userConfig.ssh;
in
{
  sops.secrets."work-config" = {
    sopsFile = ../../../../secrets/ssh.yaml;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      config.sops.secrets."work-config".path
    ];
    matchBlocks = {
      "*".forwardAgent = true;
      "*".compression = true;
      github = {
        host = "github.com";
        identityFile = sshSettings.personalPrivateKey;
        identitiesOnly = true;
      };
      gitlab-work = {
        host = "gitlab.bbf-it.at";
        identityFile = sshSettings.workPrivateKey;
        identitiesOnly = true;
      };
    };
  };
}
