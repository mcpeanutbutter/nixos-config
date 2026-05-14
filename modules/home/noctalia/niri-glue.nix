{
  flake.modules.homeManager.noctalia.imports = [
    (
      { lib, ... }:
      {
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

          # Keybinding parity with the waybar bucket. base/keybindings.nix
          # binds Mod+D to "fuzzel", which lives in the waybar bucket and
          # isn't installed when noctalia is active — override to noctalia's
          # launcher IPC. Niri requires spawn args as a list of strings.
          binds = {
            "Mod+D" = lib.mkForce {
              action.spawn = [
                "noctalia-shell"
                "ipc"
                "call"
                "launcher"
                "toggle"
              ];
              hotkey-overlay.title = "Noctalia launcher";
            };

            # base/keybindings.nix Mod+X spawns `loginctl lock-session`, which
            # fires the logind Lock signal. On waybar hosts swayidle bridges
            # that to hyprlock — noctalia doesn't listen for the signal, so
            # we route the keybind directly through its lockScreen IPC.
            "Mod+X" = lib.mkForce {
              action.spawn = [
                "noctalia-shell"
                "ipc"
                "call"
                "lockScreen"
                "lock"
              ];
              hotkey-overlay.title = "Lock screen";
            };

            # Mod+Alt+X is only bound inside the waybar bucket, so on a
            # noctalia host the key is free — no mkForce needed.
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
