{ config, ... }:
let
  workEmailSecret = "users/${config.user.username}/git/work";
in
{
  flake.modules.homeManager.work.imports = [
    (
      { config, ... }:
      {
        programs.git.includes = [
          {
            path = config.sops.secrets.${workEmailSecret}.path;
            condition = "gitdir:~/projects/work/";
          }
        ];
      }
    )
  ];
}
