{ config, ... }:
let
  workPrivateKey = config.user.ssh.workPrivateKey;
in
{
  flake.modules.homeManager.work.imports = [
    (
      { config, ... }:
      {
        # The bastion block in secrets/ssh.yaml carries ControlMaster auto +
        # ControlPath /run/user/%i/ssh-%C + ControlPersist 4h. Multiplexing is
        # scoped to the jump host on purpose: it amortizes the jump-key
        # passphrase across VM logins and gitlab fetch/push, while the second
        # hop stays un-multiplexed so every VM/gitlab connection still requires
        # the work key's passphrase by hand.
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
