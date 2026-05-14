{ pkgs, ... }:
{
  _module.args.powerMenuScript = pkgs.writeShellScript "power-menu" ''
    choice=$(printf "Sleep\0icon\x1fsuspend\nLogout\0icon\x1flog-out\nReboot\0icon\x1freboot\nShutdown\0icon\x1fshutdown\n" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --lines=4)
    case "$choice" in
      "Sleep") systemctl suspend ;;
      "Logout") ${pkgs.niri}/bin/niri msg action quit ;;
      "Reboot") systemctl reboot ;;
      "Shutdown") systemctl poweroff ;;
    esac
  '';
}
