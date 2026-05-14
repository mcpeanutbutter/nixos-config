{ config, ... }:
let
  workEmailSecret = "users/${config.user.username}/git/work";
in
{
  flake.modules.homeManager.work = {
    # SSH host include comes from a separate sops file (ssh.yaml at the repo
    # root) — keeps SSH-secret rotation independent of git emails.
    sops.secrets."work-config" = {
      sopsFile = ../../../secrets/ssh.yaml;
    };
    sops.secrets.${workEmailSecret} = { };
  };
}
