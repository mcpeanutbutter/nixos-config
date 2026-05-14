{ config, ... }:
let
  workPrivateKey = config.user.ssh.workPrivateKey;
in
{
  flake.modules.homeManager.work.imports = [
    (
      { config, ... }:
      {
        programs.ssh.includes = [
          config.sops.secrets."work-config".path
        ];
        programs.ssh.matchBlocks.gitlab-work = {
          host = "gitlab.bbf-it.at";
          identityFile = workPrivateKey;
          identitiesOnly = true;
        };
      }
    )
  ];
}
