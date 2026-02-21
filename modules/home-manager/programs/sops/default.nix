{ userConfig, lib, ... }:
let
  username = userConfig.username;
  gitPrefix = "users/${username}/git";
  overrideSecrets = lib.mapAttrs' (name: _: {
    name = "${gitPrefix}/${name}";
    value = { };
  }) (userConfig.git.emailOverrides or { });
in
{
  sops.defaultSopsFile = ../../../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/jonas/.config/sops/age/keys.txt";

  sops.secrets = {
    "${gitPrefix}/default-identity" = { };
  } // overrideSecrets;
}
