{
  flake.modules.homeManager.noctalia.imports = [
    (
      { pkgs, ... }:
      {
        # Bar-margin companion of niri-cycle-gaps (modules/home/desktop/niri/enable.nix).
        # Noctalia merges ~/.config/noctalia/*.toml alphabetically and hot-reloads
        # on write, so a drop-in sorted after config.toml overrides the bar
        # geometry. Always write a file — deletions aren't picked up live, so the
        # medium preset repeats the config.toml values instead of removing it.
        home.packages = [
          (pkgs.writeShellScriptBin "noctalia-cycle-gaps" ''
            f="''${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/zz-gaps.toml"
            case "''${1:-medium}" in
              tight)  edge=0;  ends=0;   thick=34 ;;
              medium) edge=24; ends=128; thick=40 ;;
              loose)  edge=40; ends=192; thick=46 ;;
              *) echo "noctalia-cycle-gaps: unknown preset '$1'" >&2; exit 1 ;;
            esac
            printf '[bar.default]\nmargin_edge = %s\nmargin_ends = %s\nthickness = %s\n' "$edge" "$ends" "$thick" > "$f"
          '')
        ];

        programs.niri.settings = {
          # Noctalia's blurred wallpaper copy becomes the overview backdrop.
          layer-rules = [
            {
              matches = [ { namespace = "^noctalia-backdrop"; } ];
              place-within-backdrop = true;
            }
          ];

          overview.workspace-shadow.enable = true;

          # Float the noctalia settings window.
          window-rules = [
            {
              matches = [ { app-id = "dev.noctalia.Noctalia"; } ];
              open-floating = true;
              default-column-width.fixed = 1080;
              default-window-height.fixed = 920;
            }
          ];

          debug = {
            # Noctalia sends xdg-activation tokens with an "invalid" serial
            # that niri rejects by default — accept them so notification
            # actions and window activation from noctalia work.
            honor-xdg-activation-with-invalid-serial = true;
          };

          # Noctalia owns the launcher, lock, and session-menu keybinds.
          binds = {
            "Mod+D" = {
              action.spawn = [
                "noctalia"
                "msg"
                "panel-toggle"
                "launcher"
              ];
              hotkey-overlay.title = "Noctalia launcher";
            };
            "Mod+X" = {
              action.spawn = [
                "noctalia"
                "msg"
                "session"
                "lock"
              ];
              hotkey-overlay.title = "Lock screen";
            };
            "Mod+Alt+X" = {
              action.spawn = [
                "noctalia"
                "msg"
                "panel-toggle"
                "session"
              ];
              hotkey-overlay.title = "Session menu";
            };
          };
        };
      }
    )
  ];
}
