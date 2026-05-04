{ config, userConfig, ... }:
let
  username = userConfig.username;
  workEmailSecret = "users/${username}/git/work";
in
{
  sops.secrets."work-config" = {
    sopsFile = ../../../secrets/ssh.yaml;
  };
  sops.secrets."${workEmailSecret}" = { };

  programs.ssh.includes = [
    config.sops.secrets."work-config".path
  ];
  programs.ssh.matchBlocks.gitlab-work = {
    host = "gitlab.bbf-it.at";
    identityFile = userConfig.ssh.workPrivateKey;
    identitiesOnly = true;
  };

  programs.git.includes = [
    {
      path = config.sops.secrets."${workEmailSecret}".path;
      condition = "gitdir:~/projects/work/";
    }
  ];
}
