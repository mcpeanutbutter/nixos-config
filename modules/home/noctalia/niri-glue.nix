{
  flake.modules.homeManager.noctalia.imports = [
    (
      {
        config,
        pkgs,
        ...
      }:
      let
        baseSettings = config.xdg.configFile."noctalia/settings.json".source;
        mkBarVariant =
          name: mv: mh: density: barType:
          pkgs.runCommand "noctalia-${name}.json" { } ''
            ${pkgs.gnused}/bin/sed \
              -e 's/"marginVertical": [0-9]\+/"marginVertical": ${toString mv}/' \
              -e 's/"marginHorizontal": [0-9]\+/"marginHorizontal": ${toString mh}/' \
              -e '/^  "bar": {/,/^  }/{
                    s/"density": "[a-z]\+"/"density": "${density}"/
                    s/"barType": "[a-z]\+"/"barType": "${barType}"/
                  }' \
              ${baseSettings} > $out
          '';
        tightSettings = mkBarVariant "tight" 0 0 "compact" "simple";
        looseSettings = mkBarVariant "loose" 40 192 "spacious" "floating";
      in
      {
        # The cycle script repoints settings.json to a /nix/store path outside
        # home-manager's managed files dir, which HM otherwise refuses to
        # clobber on the next activation. Force HM to overwrite — every rebuild
        # resets the symlink to the medium baseline anyway.
        xdg.configFile."noctalia/settings.json".force = true;

        # Bar-margin variant of niri-cycle-gaps: swaps the symlink at
        # ~/.config/noctalia/settings.json to one of three pre-built nix-store
        # JSONs. Noctalia's Settings.qml uses FileView with watchChanges=true
        # and explicitly handles symlink/store-path swaps, so the bar reflows
        # without restarting noctalia.
        home.packages = [
          (pkgs.writeShellScriptBin "noctalia-cycle-gaps" ''
            #!/usr/bin/env bash
            preset="''${1:-medium}"
            case "$preset" in
              tight)  path="${tightSettings}" ;;
              medium) path="${baseSettings}"  ;;
              loose)  path="${looseSettings}" ;;
              *) echo "noctalia-cycle-gaps: unknown preset '$preset'" >&2; exit 1 ;;
            esac
            ln -sfn "$path" "$HOME/.config/noctalia/settings.json"
          '')
        ];

        programs.niri.settings = {
          # Spawn noctalia at session start. The HM module installs a
          # `noctalia-shell` wrapper that invokes `qs -c noctalia-shell`
          # internally; quickshell's bare `qs` is not on the user PATH.
          spawn-at-startup = [
            { command = [ "noctalia-shell" ]; }
          ];

          # Noctalia reads NOCTALIA_PAM_SERVICE to pick the PAM service for
          # its lock screen. Niri propagates environment to spawn-at-startup
          # processes, so the noctalia-shell process inherits this.
          environment.NOCTALIA_PAM_SERVICE = "noctalia-lock";

          # Force Quickshell's icon theme directly. Bypasses the QPlatformTheme
          # plugin chain (qt5ct/qt6ct) which doesn't reliably propagate
          # qt6ct.conf's icon_theme to Qt6 apps. See:
          # https://docs.noctalia.dev/v4/getting-started/faq/#configuration
          environment.QS_ICON_THEME = "Hatter-kde-dark";

          # Set the overview wallpaper on the backdrop.
          layer-rules = [
            {
              matches = [ { namespace = "^noctalia-overview*"; } ];
              place-within-backdrop = true;
            }
          ];

          overview = {
            workspace-shadow.enable = true;
          };

          debug = {
            # Noctalia sends xdg-activation tokens with an "invalid" serial
            # that niri rejects by default — accept them so notification
            # actions and window activation from noctalia work.
            honor-xdg-activation-with-invalid-serial = true;
          };

          # Noctalia owns the launcher, lock, and session-menu keybinds.
          # Niri requires spawn args as a list of strings.
          binds = {
            "Mod+D" = {
              action.spawn = [
                "noctalia-shell"
                "ipc"
                "call"
                "launcher"
                "toggle"
              ];
              hotkey-overlay.title = "Noctalia launcher";
            };

            "Mod+X" = {
              action.spawn = [
                "noctalia-shell"
                "ipc"
                "call"
                "lockScreen"
                "lock"
              ];
              hotkey-overlay.title = "Lock screen";
            };

            "Mod+Alt+X" = {
              action.spawn = [
                "noctalia-shell"
                "ipc"
                "call"
                "sessionMenu"
                "toggle"
              ];
              hotkey-overlay.title = "Session menu";
            };
          };
        };
      }
    )
  ];
}
