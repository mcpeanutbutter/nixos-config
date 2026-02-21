{ config, lib, userConfig, ... }:
let
  username = userConfig.username;
  gitPrefix = "users/${username}/git";
in
{
  programs.git = {
    enable = true;
    # Name and email come from the sops default-identity include
    includes = [
      { path = config.sops.secrets."${gitPrefix}/default-identity".path; }
    ] ++ (lib.mapAttrsToList (name: gitdir: {
      path = config.sops.secrets."${gitPrefix}/${name}".path;
      condition = "gitdir:${gitdir}/";
    }) (userConfig.git.emailOverrides or { }));
  };
}
