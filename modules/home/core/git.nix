{ config, lib, ... }:
let
  user = config.user;
  gitPrefix = "users/${user.username}/git";
in
{
  flake.modules.homeManager.base.imports = [
    (
      { config, ... }:
      {
        programs.git = {
          enable = true;
          # Name + email come from the sops-decrypted default-identity include,
          # so the actual address never appears in the Nix source tree.
          includes = [
            { path = config.sops.secrets."${gitPrefix}/default-identity".path; }
          ]
          ++ (lib.mapAttrsToList (name: gitdir: {
            path = config.sops.secrets."${gitPrefix}/${name}".path;
            condition = "gitdir:${gitdir}/";
          }) (user.git.emailOverrides or { }));
        };
      }
    )
  ];
}
