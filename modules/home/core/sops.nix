{ config, lib, ... }:
let
  user = config.user;
  gitPrefix = "users/${user.username}/git";
  overrideSecrets = lib.mapAttrs' (name: _: {
    name = "${gitPrefix}/${name}";
    value = { };
  }) (user.git.emailOverrides or { });
in
{
  flake.modules.homeManager.base = {
    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
    sops.age.keyFile = "${user.homeDirectory}/.config/sops/age/keys.txt";

    sops.secrets = {
      "${gitPrefix}/default-identity" = { };
    }
    // overrideSecrets;
  };
}
