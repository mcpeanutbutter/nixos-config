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
        programs.ssh.settings."gitlab.bbf-it.at" = {
          IdentityFile = workPrivateKey;
          IdentitiesOnly = true;
        };
      }
    )
  ];
}
