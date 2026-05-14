{
  # Defines the fuzzel-based power menu script as a module arg so waybar's
  # custom/power widget can spawn it, and wires the Mod+Alt+X keybinding
  # to the same script. Both live together so they vanish as one when the
  # waybar bucket is off (noctalia bucket will provide its own session menu).
  flake.modules.homeManager.waybar.imports = [
    (
      { pkgs, ... }:
      let
        powerMenuScript = pkgs.writeShellScript "power-menu" ''
          choice=$(printf "Sleep\0icon\x1fsuspend\nLogout\0icon\x1flog-out\nReboot\0icon\x1freboot\nShutdown\0icon\x1fshutdown\n" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --lines=4)
          case "$choice" in
            "Sleep") systemctl suspend ;;
            "Logout") ${pkgs.niri}/bin/niri msg action quit ;;
            "Reboot") systemctl reboot ;;
            "Shutdown") systemctl poweroff ;;
          esac
        '';
      in
      {
        _module.args.powerMenuScript = powerMenuScript;

        programs.niri.settings.binds."Mod+Alt+X" = {
          action.spawn = [ "${powerMenuScript}" ];
          hotkey-overlay.title = "Power menu";
        };
      }
    )
  ];
}
