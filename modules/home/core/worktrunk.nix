{
  flake.modules.homeManager.base.imports = [
    (
      { pkgs, ... }:
      let
        wt-submodules = pkgs.writeShellApplication {
          name = "wt-submodules";
          runtimeInputs = [ pkgs.git ];
          text = builtins.readFile ./wt-submodules.sh;
        };
      in
      {
        home.packages = [ pkgs.worktrunk ];

        # Linked worktrees get their own submodule clones, which would need a
        # network fetch; mirror them from the primary checkout instead.
        xdg.configFile."worktrunk/config.toml".source =
          (pkgs.formats.toml { }).generate "worktrunk-config.toml"
            {
              pre-start = [ { submodules = "${wt-submodules}/bin/wt-submodules"; } ];
            };
      }
    )
  ];
}
