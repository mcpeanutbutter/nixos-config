{ inputs, ... }:
{
  flake.modules.homeManager.base.imports = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      lib.mkIf (config.programs.niri.finalConfig != null) {
        # niri 26.04 introduced `background-effect`. niri-flake's typed settings
        # schema doesn't surface it yet (sodiboo/niri-flake#1721). Append raw
        # KDL via the maintainer-acknowledged escape hatch: override
        # `niri-config.source` and re-run the same build-time validator
        # niri-flake uses internally. Drop this once niri-flake exposes it.
        xdg.configFile.niri-config.source =
          let
            inherit (inputs.niri.lib.internal) validated-config-for;
            inherit (config.programs.niri) finalConfig package;
          in
          lib.mkForce (
            validated-config-for pkgs package ''
              ${finalConfig}

              window-rule {
                  match app-id="^com\\.mitchellh\\.ghostty$"
                  background-effect {
                      blur true
                  }
              }
            ''
          );
      }
    )
  ];
}
